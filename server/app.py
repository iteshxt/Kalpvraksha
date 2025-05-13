from flask import Flask, request, jsonify, Response
from flask_cors import CORS
import sys
import os
from dotenv import load_dotenv
import asyncio
import json
import threading

load_dotenv()
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from gemvoice import AudioLoop

app = Flask(__name__)
CORS(app)

# Global variables to manage state
current_audio_loop = None
audio_thread = None

def run_audio_loop():
    global current_audio_loop
    audio_loop = AudioLoop()  # Remove transcription_queue parameter
    current_audio_loop = audio_loop
    asyncio.run(audio_loop.run())

@app.route('/start_voice', methods=['POST'])
def start_voice():
    global current_audio_loop, audio_thread
    try:
        if current_audio_loop is None:
            audio_thread = threading.Thread(target=run_audio_loop)
            audio_thread.daemon = True  # This ensures the thread stops when the main process stops
            audio_thread.start()
            return jsonify({'status': 'success'})
        return jsonify({'status': 'error', 'message': 'Voice interaction already running'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/stop_voice', methods=['POST'])
def stop_voice():
    global current_audio_loop
    try:
        if current_audio_loop:
            asyncio.run(current_audio_loop.stop())  # Make sure to await the stop coroutine
            current_audio_loop = None
            return jsonify({'status': 'success'})
        return jsonify({'status': 'error', 'message': 'No voice interaction running'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

@app.route('/get_transcription', methods=['GET'])
def get_transcription():
    # Always return empty since transcription is disabled
    return jsonify({'status': 'success', 'text': ''})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, threaded=True)