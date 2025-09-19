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
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_service.dart';

class VoiceAssistantService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GeminiService _gemini = GeminiService();

  bool isActive = false;
  String userTranscript = '';
  String aiTranscript = '';

  /// Start the full loop: listen → Gemini → speak → listen again
  Future<void> startVoiceLoop(
    Function(String) onUserTranscript,
    Function(String) onAIResult,
    Function(String) onAIChunk,
  ) async {
    isActive = true;
    while (isActive) {
      // 1. Listen to user
      final available = await _speech.initialize();
      if (!available) {
        onUserTranscript("Speech recognition not available");
        return;
      }

      userTranscript = '';
      await _speech.listen(
        onResult: (result) {
          userTranscript = result.recognizedWords;
          onUserTranscript(userTranscript);
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        cancelOnError: true,
        partialResults: false,
      );

      // Wait until user finishes speaking
      await Future.delayed(const Duration(seconds: 4));
      await _speech.stop();

      if (userTranscript.trim().isEmpty) continue;

      // 2. Send to Gemini
      aiTranscript = '';
      
      // Use the pre-configured chat session from GeminiService
      final responseStream = _gemini.chat.sendMessageStream(Content.text(userTranscript));

      await for (final chunk in responseStream) {
        final text = chunk.text ?? '';
        if (text.trim().isEmpty) continue;

        aiTranscript += text;
        onAIChunk(text);

        // Speak chunk immediately
        await _tts.awaitSpeakCompletion(true);
        await _tts.speak(text);
      }

      onAIResult(aiTranscript);

      // 3. After speaking, loop continues → back to listening
    }
  }

  /// Stop everything (loop, listening, TTS)
  void stopVoiceLoop() {
    isActive = false;
    _speech.stop();
    _tts.stop();
  }

  Future<void> speakText(String text) async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
  }
}
