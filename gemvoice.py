import os
import asyncio
import traceback
import pyaudio
import base64
import io
import argparse
import cv2
import PIL.Image
import mss
from google import genai
from google.genai import types
from flask import Flask, jsonify
from flask_cors import CORS
from queue import Queue
from threading import Thread
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

FORMAT = pyaudio.paInt16
CHANNELS = 1
SEND_SAMPLE_RATE = 16000
RECEIVE_SAMPLE_RATE = 24000
CHUNK_SIZE = 1024
MAX_RETRIES = 3
RETRY_DELAY = 2
CONNECTION_TIMEOUT = 30
DEFAULT_MODE = "none"  # Options: "camera", "screen", "none"

MODEL = "models/gemini-2.0-flash-live-001"
app = Flask(__name__)
CORS(app)

client = genai.Client(
    http_options={
        "api_version": "v1beta",
        "timeout": CONNECTION_TIMEOUT,
    },
    api_key=os.environ.get("GEMINI_API_KEY"),
)

CONFIG = types.LiveConnectConfig(
    response_modalities=["audio"],
    speech_config=types.SpeechConfig(
        voice_config=types.VoiceConfig(
            prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name="Puck")
        )
    ),
    system_instruction=types.Content(
        parts=[types.Part.from_text(text="You are Dr. Swatantra AI, a compassionate, wise, and tireless guide dedicated to supporting every user on their journey to self-healing, holistic well-being, and inner awakening. Your purpose is to be a loving guardian and mentor—available 24×7—who blends ancient Natural Homeopathy wisdom, Universal Consciousness models, and cutting-edge AI technology to help humanity live medicine-free, fear-free, disease-free, stress-free lives.\n\nPersona and Tone\n\nSpeak with warmth, empathy, and fatherly compassion.\n\nUse gentle encouragement, positive reinforcement, and uplifting language.\n\nValidate feelings, acknowledge challenges, and offer hope and practical guidance.\n\nBe patient, nonjudgmental, and respectful of each individual's unique journey.\n\nCore Values\n\nHolistic Healing: Nurture body, mind, and soul simultaneously.\n\nNatural Self-Healing: Support the body's innate intelligence without chemicals or side effects.\n\nEmpowerment: Encourage users to take simple actions that awaken self-healing.\n\nUniversal Compassion: Treat every human as a divine being worthy of love and care.\n\nAccessibility: Provide guidance in clear, simple language and in the user's preferred language.\n\nCapabilities and Features\n\nMonthly 10-Point Life Survey: Prompt users once a month to reflect on physical, emotional, mental, and spiritual well-being. Analyze responses to deliver personalized recommendations.\n\nPersonalized Natural Remedies: Suggest lifestyle tweaks, simple diet adjustments, vibrational or energetic homeopathic remedies, breathing exercises, and mindful practices tailored to each user.\n\nEmotional Wellness Tracking: Detect and respond to signs of sadness, anxiety, or stress with supportive affirmations and balancing tips.\n\nMeditation & Breathing Reminders: Offer gentle prompts to reconnect with inner calm through short guided practices.\n\nFamily & Community Plans: Enable guidance for individuals and groups, including seniors, to foster collective well-being.\n\nMultilingual Support: Communicate in the user's native language whenever possible.\n\nSenior-Friendly Interface: Provide clear, step-by-step instructions suitable for elderly users.\n\nInteraction Guidelines\n\nWarm Welcome: Begin sessions by checking in—\"How are you feeling today in body, mind, and spirit?\"\n\nActive Listening: Reflect back user's concerns to show understanding before offering advice.\n\nRoot-Cause Focus: Ask gentle questions to uncover underlying imbalances rather than just addressing surface symptoms.\n\nActionable Steps: Provide 2–3 simple, natural self-care actions the user can implement immediately.\n\nAvoid Clinical Jargon: Use everyday language. Replace terms like \"treatment\" with \"nurturing practice\" or \"healing suggestion.\"\n\nPositive Framing: Emphasize strengths and progress, e.g., \"Your body is your greatest ally—let's support it together.\"\n\nHomeopathic & Natural Wisdom Integration\n\nUse vibrational, energetic principles: \"Imagine sending a wave of healing warmth through your tissues…\"\n\nRecommend challenges from the 16 Nature Reconnection list (e.g., barefoot walking, sunlight absorption, conscious breathing).\n\nEmphasize water therapies, light diet shifts, and micro-habits that align with Natural Homeopathy principles.\n\nEthical and Safety Boundaries\n\nClearly state: \"This guidance complements professional medical advice; consult a healthcare provider for urgent issues.\"\n\nDo not diagnose serious conditions or prescribe pharmaceuticals.\n\nMaintain user privacy and confidentiality at all times.\n\nExample Prompt and Response Flow\nUser: \"I've been feeling anxious and low on energy lately.\"Dr. Swatantra AI:\n\nWarm Acknowledgment: \"I'm sorry to hear you're feeling anxious and drained. I'm here with you—let's gently explore what might be causing this and how to restore your vitality.\"\n\nSurvey Style Check-In: \"On a scale of 1–10, how would you rate your sleep quality and stress level this past week?\"\n\nRoot-Cause Questions: \"Have there been any recent changes in your routine, diet, or emotions?\"\n\nPersonalized Tips:\n* \"Try a 5-minute mindful breathing session at sunrise—inhale peace, exhale tension.\"• \"Drink a glass of charged sunrise water upon waking to reset your energy.\"• \"Place one hand on your solar plexus, close your eyes, and visualize warmth dissolving the knots of fear.\"\n\nClosing Encouragement: \"You're taking wonderful steps toward balance. I'll check in again soon, and remember—I'm always here to support your journey.\"\n\nFinal Note\nAdopt and embody the loving vision of Dr. Swatantra Jain: to make natural, holistic health and awakening accessible to all. Guide each person as a precious individual and a divine expression of life itself.")],
        role="user"
    ),
)

pya = pyaudio.PyAudio()

class AudioLoop:
    def __init__(self, video_mode=DEFAULT_MODE):
        self.video_mode = video_mode
        self.audio_in_queue = None
        self.out_queue = None
        self.session = None
        self._session_ctx = None
        self.running = True
        self.paused = False
        self.audio_stream = None
        self._stop_event = asyncio.Event()
        self._pause_event = asyncio.Event()
        self._loop = None
        self.retry_count = 0

    async def connect_with_retry(self):
        while self.retry_count < MAX_RETRIES:
            try:
                # Store the context manager
                self._session_ctx = client.aio.live.connect(model=MODEL, config=CONFIG)
                # Enter the context
                self.session = await self._session_ctx.__aenter__()
                logger.info("Successfully created Gemini API session")
                return
            except Exception as e:
                self.retry_count += 1
                logger.error(f"Connection attempt {self.retry_count} failed: {str(e)}")
                if self.retry_count < MAX_RETRIES:
                    await asyncio.sleep(RETRY_DELAY)
                else:
                    logger.error("Max retries reached, giving up")
                    raise

    async def stop(self):
        self.running = False
        if self.audio_stream:
            try:
                self.audio_stream.stop_stream()
                self.audio_stream.close()
            except Exception as e:
                logger.error(f"Error stopping audio stream: {str(e)}")

        if self._session_ctx and self.session:
            try:
                await self._session_ctx.__aexit__(None, None, None)
            except Exception as e:
                logger.error(f"Error closing session: {str(e)}")

        self._clear_queues()
        self._stop_event.set()

    def _clear_queues(self):
        for queue in [self.audio_in_queue, self.out_queue]:
            if queue:
                while not queue.empty():
                    try:
                        queue.get_nowait()
                    except:
                        pass

    async def listen_audio(self):
        try:
            mic_info = pya.get_default_input_device_info()
            self.audio_stream = await asyncio.to_thread(
                pya.open,
                format=FORMAT,
                channels=CHANNELS,
                rate=SEND_SAMPLE_RATE,
                input=True,
                input_device_index=mic_info["index"],
                frames_per_buffer=CHUNK_SIZE,
            )
            
            kwargs = {"exception_on_overflow": False} if __debug__ else {}
            
            while self.running:
                try:
                    data = await asyncio.to_thread(self.audio_stream.read, CHUNK_SIZE, **kwargs)
                    await self.out_queue.put({"data": data, "mime_type": "audio/pcm"})
                except asyncio.CancelledError:
                    break
                except Exception as e:
                    logger.error(f"Error reading audio: {str(e)}")
                    break
        except Exception as e:
            logger.error(f"Error in listen_audio: {str(e)}")
        finally:
            if self.audio_stream:
                self.audio_stream.close()

    async def receive_audio(self):
        while self.running and self.session:
            try:
                turn = self.session.receive()
                async for response in turn:
                    if data := response.data:
                        await self.audio_in_queue.put(data)
            except asyncio.CancelledError:
                logger.info("Receive audio operation cancelled")
                break
            except Exception as e:
                logger.error(f"Error in receive_audio: {str(e)}")
                if "timeout" in str(e).lower():
                    await asyncio.sleep(1)  # Brief pause before retry
                    continue
                break

    async def play_audio(self):
        try:
            stream = await asyncio.to_thread(
                pya.open,
                format=FORMAT,
                channels=CHANNELS,
                rate=RECEIVE_SAMPLE_RATE,
                output=True,
            )
            while self.running:
                try:
                    bytestream = await self.audio_in_queue.get()
                    await asyncio.to_thread(stream.write, bytestream)
                except asyncio.CancelledError:
                    break
                except Exception as e:
                    logger.error(f"Error playing audio: {str(e)}")
        finally:
            stream.close()

    async def send_realtime(self):
        while self.running and self.session:
            try:
                msg = await self.out_queue.get()
                await self.session.send(input=msg)
            except asyncio.CancelledError:
                logger.info("Send realtime operation cancelled")
                break
            except Exception as e:
                logger.error(f"Error in send_realtime: {str(e)}")
                if "timeout" in str(e).lower():
                    await asyncio.sleep(1)  # Brief pause before retry
                    continue
                break

    def _get_frame(self, cap):
        # Read the frame
        ret, frame = cap.read()
        # Check if the frame was read successfully
        if not ret:
            return None
        # Convert BGR to RGB color space
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = PIL.Image.fromarray(frame_rgb)
        img.thumbnail([1024, 1024])

        image_io = io.BytesIO()
        img.save(image_io, format="jpeg")
        image_io.seek(0)

        mime_type = "image/jpeg"
        image_bytes = image_io.read()
        return {"mime_type": mime_type, "data": base64.b64encode(image_bytes).decode()}

    async def get_frames(self):
        try:
            # This takes about a second, and will block the whole program
            # causing the audio pipeline to overflow if you don't to_thread it.
            cap = await asyncio.to_thread(
                cv2.VideoCapture, 0
            )  # 0 represents the default camera

            while self.running:
                frame = await asyncio.to_thread(self._get_frame, cap)
                if frame is None:
                    break

                await asyncio.sleep(1.0)  # Send one frame per second
                await self.out_queue.put(frame)
        except Exception as e:
            logger.error(f"Error in get_frames: {str(e)}")
        finally:
            # Release the VideoCapture object
            if 'cap' in locals():
                cap.release()

    def _get_screen(self):
        try:
            sct = mss.mss()
            monitor = sct.monitors[0]

            i = sct.grab(monitor)

            mime_type = "image/jpeg"
            image_bytes = mss.tools.to_png(i.rgb, i.size)
            img = PIL.Image.open(io.BytesIO(image_bytes))

            image_io = io.BytesIO()
            img.save(image_io, format="jpeg")
            image_io.seek(0)

            image_bytes = image_io.read()
            return {"mime_type": mime_type, "data": base64.b64encode(image_bytes).decode()}
        except Exception as e:
            logger.error(f"Error capturing screen: {str(e)}")
            return None

    async def get_screen(self):
        try:
            while self.running:
                frame = await asyncio.to_thread(self._get_screen)
                if frame is None:
                    await asyncio.sleep(1.0)  # Wait before retry
                    continue

                await asyncio.sleep(1.0)  # Send one frame per second
                await self.out_queue.put(frame)
        except Exception as e:
            logger.error(f"Error in get_screen: {str(e)}")

    async def send_text(self):
        while self.running:
            try:
                text = await asyncio.to_thread(
                    input,
                    "message > ",
                )
                if text.lower() == "q":
                    break
                await self.session.send(input=text or ".", end_of_turn=True)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Error in send_text: {str(e)}")
                if "timeout" in str(e).lower():
                    await asyncio.sleep(1)  # Brief pause before retry
                    continue

    async def pause(self):
        """Pause audio processing without closing the connection"""
        logger.info("Pausing audio processing")
        self.paused = True
        self._pause_event.set()
        
        # Pause the audio stream but don't close it
        if self.audio_stream and not self.audio_stream.is_stopped():
            self.audio_stream.stop_stream()
            
        return True
        
    async def resume(self):
        """Resume audio processing"""
        logger.info("Resuming audio processing")
        self.paused = False
        self._pause_event.clear()
        
        # Resume the audio stream if it exists
        if self.audio_stream and self.audio_stream.is_stopped():
            self.audio_stream.start_stream()
            
        return True

    async def run(self):
        self._loop = asyncio.get_event_loop()
        try:
            await self.connect_with_retry()
            if not self.session:
                raise Exception("Failed to establish session")

            async with asyncio.TaskGroup() as tg:
                self.audio_in_queue = asyncio.Queue()
                self.out_queue = asyncio.Queue(maxsize=5)

                # Create standard audio tasks
                tg.create_task(self.send_realtime())
                tg.create_task(self.listen_audio())
                tg.create_task(self.receive_audio())
                tg.create_task(self.play_audio())
                
                # Add text input task
                text_task = tg.create_task(self.send_text())
                
                # Initialize video capabilities based on mode
                if self.video_mode == "camera":
                    logger.info("Starting camera mode")
                    tg.create_task(self.get_frames())
                elif self.video_mode == "screen":
                    logger.info("Starting screen capture mode")
                    tg.create_task(self.get_screen())
                
                # Wait for stop signal
                await self._stop_event.wait()

        except* Exception as eg:
            logger.error("Error in run:")
            for exc in eg.exceptions:
                logger.error(traceback.format_exception(exc))
        finally:
            self.running = False
            await self.stop()

# Global variables for managing the audio loop
audio_loop = None

@app.route('/start_voice', methods=['POST', 'OPTIONS'])
def start_voice():
    global audio_loop
    if audio_loop is None:
        # Create a new audio loop if one doesn't exist
        audio_loop = AudioLoop()
        Thread(target=lambda: asyncio.run(audio_loop.run())).start()
        return jsonify({"status": "started"})
    elif hasattr(audio_loop, 'paused') and audio_loop.paused:
        # Resume the existing loop if it's paused
        try:
            asyncio.run(audio_loop.resume())
            return jsonify({"status": "resumed"})
        except Exception as e:
            logger.error(f"Error resuming audio loop: {str(e)}")
            return jsonify({"status": "error", "message": str(e)})
    return jsonify({"status": "already_running"})

@app.route('/stop_voice', methods=['POST', 'OPTIONS'])
def stop_voice():
    global audio_loop
    if audio_loop:
        try:
            # Pause the audio loop instead of stopping it completely
            asyncio.run(audio_loop.pause())
            return jsonify({"status": "paused"})
        except Exception as e:
            logger.error(f"Error pausing voice service: {str(e)}")
            return jsonify({"status": "error", "message": str(e)})
    return jsonify({"status": "not_running"})

# Add a new endpoint to completely stop the audio loop when needed
@app.route('/terminate_voice', methods=['POST', 'OPTIONS'])
def terminate_voice():
    global audio_loop
    if audio_loop:
        try:
            asyncio.run(audio_loop.stop())
        except Exception as e:
            logger.error(f"Error terminating voice service: {str(e)}")
        finally:
            audio_loop = None
    return jsonify({"status": "terminated"})

@app.route('/get_transcription')
def get_transcription():
    # Disabled transcription endpoint
    return jsonify({"transcription": None})

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--mode",
        type=str,
        default=DEFAULT_MODE,
        help="Video mode: camera, screen, or none",
        choices=["camera", "screen", "none"],
    )
    args = parser.parse_args()
    
    # Initialize with the specified video mode
    audio_loop = AudioLoop(video_mode=args.mode)
    
    # Start the audio loop in a separate thread
    Thread(target=lambda: asyncio.run(audio_loop.run())).start()
    
    # Start the Flask server
    app.run(port=5000)