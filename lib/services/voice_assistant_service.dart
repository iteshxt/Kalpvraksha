import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'gemini_service.dart';

/// Enhanced Voice Assistant Service with comprehensive TTS voice configuration
///
/// Features:
/// - Configurable voice pitch (0.5 to 2.0)
/// - Adjustable speech rate (0.0 to 1.0)
/// - Volume control (0.0 to 1.0)
/// - Language and voice selection
/// - Gender-based voice filtering
/// - Voice presets for different scenarios
///
/// Usage Examples:
/// ```dart
/// final voiceAssistant = VoiceAssistantService();
///
/// // Set custom voice parameters
/// await voiceAssistant.setPitch(1.3);
/// await voiceAssistant.setSpeechRate(0.4);
/// await voiceAssistant.setVoiceGender('female');
///
/// // Use voice presets
/// await voiceAssistant.setTherapeuticVoice(); // For counseling
/// await voiceAssistant.setEnergeticVoice(); // For motivation
///
/// // Configure advanced settings
/// await voiceAssistant.configureAdvancedVoice(
///   pitch: 1.2,
///   speechRate: 0.5,
///   volume: 0.8,
///   language: 'en-US',
///   gender: 'female',
/// );
///
/// // Get available voices
/// final voices = voiceAssistant.getAvailableVoices();
/// final femaleVoices = voiceAssistant.getVoicesByGender('female');
/// ```

class VoiceAssistantService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final GeminiService _gemini = GeminiService();

  bool isActive = false;
  String userTranscript = '';
  String aiTranscript = '';

  // TTS Voice Configuration Properties
  double _pitch = 1.0; // Range: 0.5 to 2.0
  double _speechRate = 0.5; // Range: 0.0 to 1.0
  double _volume = 0.8; // Range: 0.0 to 1.0
  String _language = 'en-US';
  String? _selectedVoice;
  List<Map<String, dynamic>> _availableVoices = [];

  // Advanced voice settings
  bool _useDeepVoice = false;
  double _voicePitch = 1.0; // Additional pitch control
  double _voiceTone = 1.0; // Tone adjustment (when supported)
  String _voiceGender = 'female'; // male, female, neutral

  // Constructor
  VoiceAssistantService() {
    _initializeTTS();
  }

  /// Initialize and configure TTS with voice parameters
  Future<void> _initializeTTS() async {
    try {
      // Get available voices
      _availableVoices = await _tts.getVoices;

      // Set language
      await _tts.setLanguage(_language);

      // Configure voice parameters
      await _tts.setPitch(_pitch);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setVolume(_volume);

      // Try to set a preferred voice based on gender
      await _setPreferredVoice();

      // Set the therapeutic voice preset as the default
      await setTherapeuticVoice();

      // Configure additional TTS settings
      await _tts.awaitSpeakCompletion(true);

      // Platform specific configurations
      await _configurePlatformSpecificSettings();
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  /// Configure platform-specific TTS settings
  Future<void> _configurePlatformSpecificSettings() async {
    try {
      // iOS specific settings
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );

      // Android specific settings
      await _tts.setEngine('com.google.android.tts');
    } catch (e) {
      print('Platform specific TTS configuration error: $e');
    }
  }

  /// Set preferred voice based on gender and language
  Future<void> _setPreferredVoice() async {
    if (_availableVoices.isEmpty) return;

    // Filter voices by language and gender preference
    final filteredVoices = _availableVoices.where((voice) {
      final name = (voice['name'] as String).toLowerCase();
      final locale = (voice['locale'] as String).toLowerCase();

      // Check if voice matches language
      final matchesLanguage =
          locale.contains(_language.toLowerCase().replaceAll('-', '_')) ||
          locale.contains(_language.toLowerCase().replaceAll('-', ''));

      // Check if voice matches gender preference
      bool matchesGender = true;
      if (_voiceGender == 'female') {
        matchesGender =
            name.contains('female') ||
            name.contains('woman') ||
            name.contains('girl') ||
            !name.contains('male');
      } else if (_voiceGender == 'male') {
        matchesGender =
            name.contains('male') ||
            name.contains('man') ||
            name.contains('boy');
      }

      return matchesLanguage && matchesGender;
    }).toList();

    if (filteredVoices.isNotEmpty) {
      _selectedVoice = filteredVoices.first['name'];
      await _tts.setVoice({
        'name': _selectedVoice!,
        'locale': filteredVoices.first['locale'],
      });
    }
  }

  // ===== Voice Configuration Methods =====

  /// Set voice pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _tts.setSpeechRate(_speechRate);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    _language = language;
    await _tts.setLanguage(_language);
    await _setPreferredVoice(); // Update voice based on new language
  }

  /// Set voice gender preference
  Future<void> setVoiceGender(String gender) async {
    if (['male', 'female', 'neutral'].contains(gender)) {
      _voiceGender = gender;
      await _setPreferredVoice();
    }
  }

  /// Set specific voice by name
  Future<void> setVoice(String voiceName) async {
    final voice = _availableVoices.firstWhere(
      (v) => v['name'] == voiceName,
      orElse: () => {},
    );

    if (voice.isNotEmpty) {
      _selectedVoice = voiceName;
      await _tts.setVoice({'name': voiceName, 'locale': voice['locale']});
    }
  }

  /// Configure advanced voice settings
  Future<void> configureAdvancedVoice({
    double? pitch,
    double? speechRate,
    double? volume,
    String? language,
    String? gender,
    bool? useDeepVoice,
  }) async {
    if (pitch != null) await setPitch(pitch);
    if (speechRate != null) await setSpeechRate(speechRate);
    if (volume != null) await setVolume(volume);
    if (language != null) await setLanguage(language);
    if (gender != null) await setVoiceGender(gender);
    if (useDeepVoice != null) _useDeepVoice = useDeepVoice;
  }

  // ===== Voice Information Getters =====

  /// Get available voices
  List<Map<String, dynamic>> getAvailableVoices() => _availableVoices;

  /// Get current voice settings
  Map<String, dynamic> getCurrentVoiceSettings() {
    return {
      'pitch': _pitch,
      'speechRate': _speechRate,
      'volume': _volume,
      'language': _language,
      'selectedVoice': _selectedVoice,
      'voiceGender': _voiceGender,
      'useDeepVoice': _useDeepVoice,
      'voicePitch': _voicePitch,
      'voiceTone': _voiceTone,
    };
  }

  /// Get voices filtered by language
  List<Map<String, dynamic>> getVoicesByLanguage(String language) {
    return _availableVoices.where((voice) {
      final locale = (voice['locale'] as String).toLowerCase();
      return locale.contains(language.toLowerCase().replaceAll('-', '_')) ||
          locale.contains(language.toLowerCase().replaceAll('-', ''));
    }).toList();
  }

  /// Get voices filtered by gender
  List<Map<String, dynamic>> getVoicesByGender(String gender) {
    return _availableVoices.where((voice) {
      final name = (voice['name'] as String).toLowerCase();

      if (gender == 'female') {
        return name.contains('female') ||
            name.contains('woman') ||
            name.contains('girl') ||
            !name.contains('male');
      } else if (gender == 'male') {
        return name.contains('male') ||
            name.contains('man') ||
            name.contains('boy');
      }
      return true; // neutral or any
    }).toList();
  }

  /// Reset voice settings to default
  Future<void> resetVoiceSettings() async {
    _pitch = 1.0;
    _speechRate = 0.5;
    _volume = 0.8;
    _language = 'en-US';
    _voiceGender = 'female';
    _useDeepVoice = false;
    _voicePitch = 1.0;
    _voiceTone = 1.0;

    await _initializeTTS();
  }

  // ===== Voice Presets =====

  /// Apply a gentle female voice preset
  Future<void> setGentleFemaleVoice() async {
    await configureAdvancedVoice(
      pitch: 1.2,
      speechRate: 0.4,
      volume: 0.7,
      gender: 'female',
    );
  }

  /// Apply a confident male voice preset
  Future<void> setConfidentMaleVoice() async {
    await configureAdvancedVoice(
      pitch: 0.8,
      speechRate: 0.5,
      volume: 0.9,
      gender: 'male',
    );
  }

  /// Apply a calm narrator voice preset
  Future<void> setCalmNarratorVoice() async {
    await configureAdvancedVoice(
      pitch: 1.0,
      speechRate: 0.4,
      volume: 0.8,
      gender: 'neutral',
    );
  }

  /// Apply an energetic voice preset
  Future<void> setEnergeticVoice() async {
    await configureAdvancedVoice(pitch: 1.3, speechRate: 0.6, volume: 0.9);
  }

  /// Apply a soothing therapeutic voice preset
  Future<void> setTherapeuticVoice() async {
    await configureAdvancedVoice(
      pitch: 1.1,
      speechRate: 0.3,
      volume: 0.7,
      gender: 'female',
    );
  }

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
      final responseStream = _gemini.chat.sendMessageStream(
        Content.text(userTranscript),
      );

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
