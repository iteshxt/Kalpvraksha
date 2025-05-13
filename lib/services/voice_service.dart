import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class VoiceService {
  static Process? _process;
  static const String _baseUrl = 'http://127.0.0.1:5000';
  static bool _isServerReady = false;

  static Future<bool> _checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_transcription'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<void> startVoiceProcess() async {
    if (_process != null) return;
    
    final scriptPath = path.join('c:', 'Android_Projects', 'muktiya_new', 'gemvoice.py');
    _process = await Process.start('python', [scriptPath]);
    
    // Wait for server to be ready with retries
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (await _checkServerConnection()) {
        _isServerReady = true;
        break;
      }
    }

    if (!_isServerReady) {
      throw Exception('Failed to start voice service');
    }
  }

  static Future<void> stopVoiceProcess() async {
    if (_process == null) return;

    try {
      if (_isServerReady) {
        await http.post(Uri.parse('$_baseUrl/stop_voice'))
            .timeout(const Duration(seconds: 2));
      }
    } catch (e) {
      print('Error stopping voice service: $e');
    } finally {
      _isServerReady = false;
      _process?.kill();
      _process = null;
    }
  }

  static Future<String?> getTranscription() async {
    if (!_isServerReady) return null;
    
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_transcription'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['transcription'];
      }
    } catch (e) {
      print('Error getting transcription: $e');
    }
    return null;
  }
}