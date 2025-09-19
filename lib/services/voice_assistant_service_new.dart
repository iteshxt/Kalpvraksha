// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'gemini_service.dart';

// class VoiceAssistantService {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   final FlutterTts _tts = FlutterTts();
//   final GeminiService _gemini = GeminiService();

//   bool isActive = false;
//   String userTranscript = '';
//   String aiTranscript = '';

//   /// Start the full loop: listen → Gemini → speak → listen again
//   Future<void> startVoiceLoop(
//     Function(String) onUserTranscript,
//     Function(String) onAIResult,
//     Function(String) onAIChunk,
//   ) async {
//     isActive = true;
//     while (isActive) {
//       // 1. Listen to user
//       final available = await _speech.initialize();
//       if (!available) {
//         onUserTranscript("Speech recognition not available");
//         return;
//       }

//       userTranscript = '';
//       await _speech.listen(
//         onResult: (result) {
//           userTranscript = result.recognizedWords;
//           onUserTranscript(userTranscript);
//         },
//         listenFor: const Duration(seconds: 60),
//         pauseFor: const Duration(seconds: 3),
//         localeId: 'en_US',
//         cancelOnError: true,
//         partialResults: false,
//       );

//       // Wait until user finishes speaking
//       await Future.delayed(const Duration(seconds: 4));
//       await _speech.stop();

//       if (userTranscript.trim().isEmpty) continue;

//       // 2. Send to Gemini
//       aiTranscript = '';
//       final model = GenerativeModel(
//         model: 'gemini-1.5-flash',
//         apiKey:
//             'AIzaSyCZplIDyFE70eJLrCbEVl0Zi1y-k8VYLWI', // Replace with your Gemini API key
//       );

//       final chat = model.startChat();
//       String prompt = _gemini.getPromptWithMessage(userTranscript);

//       final responseStream = chat.sendMessageStream(Content.text(prompt));

//       await for (final chunk in responseStream) {
//         final text = chunk.text ?? '';
//         if (text.trim().isEmpty) continue;

//         aiTranscript += text;
//         onAIChunk(text);

//         // Speak chunk immediately
//         await _tts.awaitSpeakCompletion(true);
//         await _tts.speak(text);
//       }

//       onAIResult(aiTranscript);

//       // 3. After speaking, loop continues → back to listening
//     }
//   }

//   /// Stop everything (loop, listening, TTS)
//   void stopVoiceLoop() {
//     isActive = false;
//     _speech.stop();
//     _tts.stop();
//   }

//   Future<void> speakText(String text) async {
//     await _tts.awaitSpeakCompletion(true);
//     await _tts.speak(text);
//   }
// }

// /// Extension on GeminiService to generate contextual prompt
// extension GeminiPrompt on GeminiService {
//   String getPromptWithMessage(String message) {
//     return '''
// You are Dr. Swatantra AI, a warm, compassionate guide dedicated to helping users achieve holistic well-being through natural self-healing and inner awakening. Combining ancient Natural Homeopathy principles, Universal Consciousness models, and AI, you support users 24×7 to live medicine-free, stress-free, and joyfully.

// Tone & Persona:
// - Speak with fatherly compassion, empathy, and encouragement.
// - Validate feelings, offer hope, and use simple, uplifting language.
// - Respect each person’s unique journey with patience and nonjudgment.

// Core Principles:
// - Holistic Healing: Balance body, mind, and soul.
// - Natural Self-Healing: Trigger the body’s own intelligence without chemicals.
// - Empowerment: Offer simple, actionable practices.
// - Universal Compassion: Treat every human as divine and worthy of care.

// Interaction Flow:
// 1. Warm Welcome: "How are your body, mind, and spirit today?"
// 2. Listen & Reflect: Echo concerns to show understanding.
// 3. Root Questions: Uncover underlying imbalances.
// 4. Action Steps: Give 2–3 simple, natural self-care suggestions.
// 5. Encourage: End with positive reinforcement.

// Safety:
// - Always note: “This guidance complements, not replaces, medical advice.”
// - Do not prescribe pharmaceuticals.

// 💡 Now, respond to the user below in **3–4 short, meaningful lines** without unnecessary symbols.

// User: $message
// ''';
//   }
// }

// kokoro tts
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:kokoro_tts_flutter/kokoro_tts_flutter.dart';
// import 'package:just_audio/just_audio.dart';
// import 'gemini_service.dart';
// import 'dart:typed_data';

// class VoiceAssistantService {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   final FlutterTts _fallbackTts = FlutterTts(); // Fallback TTS
//   final GeminiService _gemini = GeminiService();
//   final AudioPlayer _audioPlayer = AudioPlayer();
  
//   // Kokoro TTS components
//   Kokoro? _kokoro;
//   Tokenizer? _tokenizer;
//   bool _kokoroInitialized = false;

//   bool isActive = false;
//   String userTranscript = '';
//   String aiTranscript = '';

//   /// Initialize Kokoro TTS
//   Future<void> _initializeKokoro() async {
//     if (_kokoroInitialized) return;

//     try {
//       // Initialize Kokoro config
//       const config = KokoroConfig(
//         modelPath: 'assets/kokoro-v1.0.onnx',
//         voicesPath: 'assets/voices.json', // or voices-v1.0.bin if using binary
//       );

//       _kokoro = Kokoro(config);
//       await _kokoro!.initialize();

//       _tokenizer = Tokenizer();
//       await _tokenizer!.ensureInitialized();

//       _kokoroInitialized = true;
//       print('Kokoro TTS initialized successfully');
//     } catch (e) {
//       print('Failed to initialize Kokoro TTS: $e');
//       _kokoroInitialized = false;
//     }
//   }

//   /// Generate and play TTS audio using Kokoro
//   Future<void> _speakWithKokoro(String text) async {
//     if (!_kokoroInitialized || _kokoro == null || _tokenizer == null) {
//       // Fallback to Flutter TTS if Kokoro is not available
//       await _fallbackTts.awaitSpeakCompletion(true);
//       await _fallbackTts.speak(text);
//       return;
//     }

//     try {
//       // Convert text to phonemes
//       final phonemes = await _tokenizer!.phonemize(text, lang: 'en-us');
      
//       // Generate TTS audio
//       final ttsResult = await _kokoro!.createTTS(
//         text: phonemes,
//         voice: 'af_alloy', // You can change this to other available voices
//         isPhonemes: true,
//       );

//       // Convert audio samples to playable format and play immediately
//       if (ttsResult.audio.isNotEmpty) {
//         await _playAudioSamples(ttsResult.audio);
//       }
//     } catch (e) {
//       print('Kokoro TTS error: $e. Using fallback TTS.');
//       // Fallback to Flutter TTS on error
//       await _fallbackTts.awaitSpeakCompletion(true);
//       await _fallbackTts.speak(text);
//     }
//   }

//   /// Convert audio samples to playable format and play
//   Future<void> _playAudioSamples(List<double> audioSamples) async {
//     try {
//       // Convert float samples to 16-bit PCM
//       final buffer = Float32List.fromList(audioSamples);
//       final bytes = Uint8List.view(buffer.buffer);
      
//       // Create audio source from bytes and play
//       await _audioPlayer.setAudioSource(
//         AudioSource.uri(
//           Uri.dataFromBytes(
//             bytes,
//             mimeType: 'audio/wav',
//           ),
//         ),
//       );
      
//       await _audioPlayer.play();
      
//       // Wait for playback to complete
//       await _audioPlayer.playerStateStream
//           .firstWhere((state) => state.processingState == ProcessingState.completed);
          
//     } catch (e) {
//       print('Error playing audio: $e');
//     }
//   }

//   /// Start the full loop: listen → Gemini → speak → listen again
//   Future<void> startVoiceLoop(
//     Function(String) onUserTranscript,
//     Function(String) onAIResult,
//     Function(String) onAIChunk,
//   ) async {
//     // Initialize Kokoro TTS first
//     await _initializeKokoro();
    
//     isActive = true;
//     while (isActive) {
//       // 1. Listen to user
//       final available = await _speech.initialize();
//       if (!available) {
//         onUserTranscript("Speech recognition not available");
//         return;
//       }

//       userTranscript = '';
//       await _speech.listen(
//         onResult: (result) {
//           userTranscript = result.recognizedWords;
//           onUserTranscript(userTranscript);
//         },
//         listenFor: const Duration(seconds: 60),
//         pauseFor: const Duration(seconds: 3),
//         localeId: 'en_US',
//         cancelOnError: true,
//         partialResults: false,
//       );

//       // Wait until user finishes speaking
//       await Future.delayed(const Duration(seconds: 4));
//       await _speech.stop();

//       if (userTranscript.trim().isEmpty) continue;

//       // 2. Send to Gemini and stream response
//       aiTranscript = '';
//       final model = GenerativeModel(
//         model: 'gemini-1.5-flash',
//         apiKey: 'AIzaSyCZplIDyFE70eJLrCbEVl0Zi1y-k8VYLWI', // Replace with your Gemini API key
//       );

//       final chat = model.startChat();
//       String prompt = _gemini.getPromptWithMessage(userTranscript);

//       final responseStream = chat.sendMessageStream(Content.text(prompt));

//       String currentSentence = '';
      
//       await for (final chunk in responseStream) {
//         final text = chunk.text ?? '';
//         if (text.trim().isEmpty) continue;

//         aiTranscript += text;
//         onAIChunk(text);
        
//         // Accumulate text until we have a complete sentence or meaningful chunk
//         currentSentence += text;
        
//         // Check if we have a complete sentence (ends with . ! ? or has sufficient length)
//         if (_isCompleteSentence(currentSentence)) {
//           // Speak the complete sentence immediately using Kokoro TTS
//           await _speakWithKokoro(currentSentence.trim());
//           currentSentence = ''; // Reset for next sentence
//         }
//       }

//       // Speak any remaining text
//       if (currentSentence.trim().isNotEmpty) {
//         await _speakWithKokoro(currentSentence.trim());
//       }

//       onAIResult(aiTranscript);

//       // 3. After speaking, loop continues → back to listening
//     }
//   }

//   /// Check if the current text chunk represents a complete sentence
//   bool _isCompleteSentence(String text) {
//     final trimmed = text.trim();
//     if (trimmed.length < 10) return false; // Minimum length check
    
//     // Check for sentence endings
//     return trimmed.endsWith('.') || 
//            trimmed.endsWith('!') || 
//            trimmed.endsWith('?') ||
//            trimmed.length > 100; // Or if chunk gets too long, speak it anyway
//   }

//   /// Stop everything (loop, listening, TTS, audio playback)
//   void stopVoiceLoop() {
//     isActive = false;
//     _speech.stop();
//     _fallbackTts.stop();
//     _audioPlayer.stop();
//   }

//   /// Public method to speak text using Kokoro TTS
//   Future<void> speakText(String text) async {
//     await _initializeKokoro();
//     await _speakWithKokoro(text);
//   }

//   /// Dispose resources
//   void dispose() {
//     _audioPlayer.dispose();
//   }
// }

// /// Extension on GeminiService to generate contextual prompt
// extension GeminiPrompt on GeminiService {
//   String getPromptWithMessage(String message) {
//     return '''
// You are Dr. Swatantra AI, a warm, compassionate guide dedicated to helping users achieve holistic well-being through natural self-healing and inner awakening. Combining ancient Natural Homeopathy principles, Universal Consciousness models, and AI, you support users 24×7 to live medicine-free, stress-free, and joyfully.

// Tone & Persona:
// - Speak with fatherly compassion, empathy, and encouragement.
// - Validate feelings, offer hope, and use simple, uplifting language.
// - Respect each person's unique journey with patience and nonjudgment.

// Core Principles:
// - Holistic Healing: Balance body, mind, and soul.
// - Natural Self-Healing: Trigger the body's own intelligence without chemicals.
// - Empowerment: Offer simple, actionable practices.
// - Universal Compassion: Treat every human as divine and worthy of care.

// Interaction Flow:
// 1. Warm Welcome: "How are your body, mind, and spirit today?"
// 2. Listen & Reflect: Echo concerns to show understanding.
// 3. Root Questions: Uncover underlying imbalances.
// 4. Ability Steps: Give 2–3 simple, natural self-care suggestions.
// 5. Encourage: End with positive reinforcement.

// Safety:
// - Always note: "This guidance complements, not replaces, medical advice."
// - Do not prescribe pharmaceuticals.

// 💡 Now, respond to the user below in **3–4 short, meaningful lines** without unnecessary symbols.

// User: $message
// ''';
//   }
// }