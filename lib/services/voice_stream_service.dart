import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

class VoiceStreamService {
  final String apiBaseUrl;
  final int sampleRate = 16000;
  final int channels = 1;
  final int chunkSamples = 1024; // ~64ms latency

  VoiceStreamService({required this.apiBaseUrl});

  // Audio simulation components
  Timer? _audioSimulationTimer;
  StreamSubscription? _audioSub;
  IOWebSocketChannel? _ws;
  bool _wsConnected = false;
  bool _micOn = false;
  final BytesBuilder _bufferBuilder = BytesBuilder();
  final int _bytesPerSample = 2;
  int _seq = 0;
  final Random _random = Random();

  final _incomingAudioController = StreamController<Uint8List>.broadcast();
  final _logController = StreamController<String>.broadcast();
  final _micLevelController = StreamController<double>.broadcast();
  final _statusController = StreamController<String>.broadcast();

  Stream<Uint8List> get incomingAudioStream => _incomingAudioController.stream;
  Stream<String> get logStream => _logController.stream;
  Stream<double> get micLevelStream => _micLevelController.stream;
  Stream<String> get statusStream => _statusController.stream;

  bool get isConnected => _wsConnected;
  bool get isMicOn => _micOn;

  void log(String s) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    _logController.add("$timestamp: $s");
    print("VoiceStream: $s");
  }

  void _updateStatus(String status) {
    _statusController.add(status);
  }

  Future<void> init() async {
    try {
      log("Voice stream service initialized (simulation mode)");
      _updateStatus("Ready to connect");
    } catch (e) {
      log("Init error: $e");
      _updateStatus("Error initializing service");
    }
  }

  Future<bool> startSession() async {
    try {
      _updateStatus("Starting session...");
      log("Starting voice session...");

      final resp = await http.post(
        Uri.parse("$apiBaseUrl/start_voice"),
        headers: {"Content-Type": "application/json"},
      );

      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        String wsUrl = j['websocket']['url'];
        log("Session started, WS: $wsUrl");
        await _connectWs(wsUrl);
        return true;
      } else {
        log("start_voice failed: ${resp.statusCode} - ${resp.body}");
        _updateStatus("Failed to start session");
        return false;
      }
    } catch (e) {
      log("Error starting session: $e");
      _updateStatus("Connection error");
      return false;
    }
  }

  Future<void> _connectWs(String wsUrl) async {
    try {
      _ws = IOWebSocketChannel.connect(Uri.parse(wsUrl));
      _wsConnected = true;
      _updateStatus("Connected");
      log("WebSocket connected");

      _ws!.stream.listen(
        (msg) => _handleWsMessage(msg),
        onDone: () {
          log("WS closed");
          _wsConnected = false;
          _updateStatus("Disconnected");
        },
        onError: (e) {
          log("WS error: $e");
          _wsConnected = false;
          _updateStatus("Connection error");
        },
      );
    } catch (e) {
      log("WS connect error: $e");
      _updateStatus("Connection failed");
    }
  }

  Future<bool> startMic() async {
    if (!_wsConnected) {
      log("WS not connected");
      _updateStatus("Not connected");
      return false;
    }
    if (_micOn) return true;

    try {
      _bufferBuilder.clear();

      // Start audio simulation
      _startAudioSimulation();

      _micOn = true;
      _updateStatus("Listening...");
      log("Microphone started (simulation mode)");
      return true;
    } catch (e) {
      log("Mic start error: $e");
      _updateStatus("Mic error");
      return false;
    }
  }

  void _startAudioSimulation() {
    _audioSimulationTimer = Timer.periodic(Duration(milliseconds: 64), (timer) {
      if (!_micOn) {
        timer.cancel();
        return;
      }

      // Generate simulated audio data
      final audioData = _generateSimulatedAudio();
      _onRawAudio(audioData);
    });
  }

  Uint8List _generateSimulatedAudio() {
    // Generate realistic audio levels for visualization
    final baseLevel = 0.1 + (_random.nextDouble() * 0.4); // 0.1 to 0.5
    final spikes =
        _random.nextDouble() < 0.3 ? _random.nextDouble() * 0.5 : 0.0;
    final finalLevel = (baseLevel + spikes).clamp(0.0, 1.0);

    // Convert to audio level for visualization
    _micLevelController.add(finalLevel);

    // Generate fake PCM data
    final int chunkBytes = chunkSamples * _bytesPerSample;
    final audioData = Uint8List(chunkBytes);

    for (int i = 0; i < chunkBytes; i += 2) {
      final sample =
          (finalLevel * 32767 * (_random.nextDouble() - 0.5)).toInt();
      audioData[i] = sample & 0xFF;
      audioData[i + 1] = (sample >> 8) & 0xFF;
    }

    return audioData;
  }

  Future<void> stopMic() async {
    if (!_micOn) return;

    try {
      _audioSimulationTimer?.cancel();
      await _audioSub?.cancel();
      _bufferBuilder.clear();
      _micOn = false;
      _updateStatus("Stopped");
      log("Microphone stopped (simulation mode)");

      // Send stop command
      if (_wsConnected) {
        _ws?.sink.add(jsonEncode({"type": "control", "command": "stop"}));
      }
    } catch (e) {
      log("Mic stop error: $e");
    }
  }

  void _onRawAudio(Uint8List data) {
    // Calculate amplitude (RMS) for visualization
    try {
      final buffer = data.buffer.asInt16List();
      double sum = 0;
      for (var i = 0; i < buffer.length; i++) {
        sum += (buffer[i].abs());
      }
      final avg = sum / buffer.length;
      final normalizedLevel = (avg / 32768.0).clamp(0.0, 1.0);
      _micLevelController.add(normalizedLevel);
    } catch (e) {
      log("Audio level calc error: $e");
    }

    // Existing chunk buffering logic
    _bufferBuilder.add(data);
    final int chunkBytes = chunkSamples * _bytesPerSample;
    final buf = _bufferBuilder.toBytes();
    int offset = 0;

    while (offset + chunkBytes <= buf.length) {
      final chunk = buf.sublist(offset, offset + chunkBytes);
      offset += chunkBytes;
      _sendPcmChunk(chunk);
    }

    if (offset < buf.length) {
      final tail = buf.sublist(offset);
      _bufferBuilder.clear();
      _bufferBuilder.add(tail);
    } else {
      _bufferBuilder.clear();
    }
  }

  void _sendPcmChunk(Uint8List pcm) {
    if (!_wsConnected) return;

    try {
      final b64 = base64Encode(pcm);
      final msg = jsonEncode({
        "type": "audio",
        "format": "audio/pcm",
        "seq": _seq++,
        "data": b64,
      });
      _ws!.sink.add(msg);
      // log("Sent seq=$_seq (${pcm.length} bytes)"); // Too verbose
    } catch (e) {
      log("Send error: $e");
    }
  }

  void _handleWsMessage(dynamic msg) {
    try {
      if (msg is String) {
        final parsed = jsonDecode(msg);
        if (parsed['type'] == 'audio' && parsed['data'] != null) {
          final bytes = base64Decode(parsed['data']);
          _incomingAudioController.add(bytes);
          log("Received AI audio (${bytes.length} bytes)");
          _updateStatus("AI responding...");
        } else if (parsed['type'] == 'status') {
          log("Status: ${parsed['message'] ?? 'Unknown'}");
          _updateStatus(parsed['message'] ?? 'Processing...');
        } else {
          log("WS msg: $parsed");
        }
      }
    } catch (e) {
      log("WS handle error: $e");
    }
  }

  Future<void> terminateSession() async {
    try {
      await stopMic();

      _audioSimulationTimer?.cancel();

      if (_ws != null) {
        _ws?.sink.close();
        _wsConnected = false;
      }

      final resp = await http.post(Uri.parse("$apiBaseUrl/terminate_voice"));
      log("terminate_voice: ${resp.statusCode}");
      _updateStatus("Session ended");
    } catch (e) {
      log("terminate_voice error: $e");
      _updateStatus("Error ending session");
    }
  }

  void dispose() {
    _incomingAudioController.close();
    _logController.close();
    _micLevelController.close();
    _statusController.close();
    terminateSession();
  }
}
