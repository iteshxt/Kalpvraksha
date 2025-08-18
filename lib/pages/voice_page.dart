import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:muktiya_new/services/voice_stream_service.dart';
import 'package:muktiya_new/widgets/waveform_painter.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  final VoiceStreamService _voiceService = VoiceStreamService(
    apiBaseUrl: "https://swatantra-ai.onrender.com"
  );
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isListening = false;
  bool _isConnected = false;
  String _status = "Ready to connect";
  final List<double> _amplitudes = List.filled(50, 0.0);
  final List<String> _logs = [];
  
  StreamSubscription<double>? _micLevelSub;
  StreamSubscription<String>? _statusSub;
  StreamSubscription<String>? _logSub;
  StreamSubscription<Uint8List>? _audioSub;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  void _initializeService() async {
    await _voiceService.init();
    
    // Listen to microphone levels for visualization
    _micLevelSub = _voiceService.micLevelStream.listen((level) {
      setState(() {
        _amplitudes.removeAt(0);
        _amplitudes.add(level);
      });
    });
    
    // Listen to status updates
    _statusSub = _voiceService.statusStream.listen((status) {
      setState(() {
        _status = status;
        _isConnected = _voiceService.isConnected;
      });
    });
    
    // Listen to logs
    _logSub = _voiceService.logStream.listen((log) {
      setState(() {
        _logs.insert(0, log);
        if (_logs.length > 100) _logs.removeLast();
      });
    });
    
    // Listen to incoming audio and play it
    _audioSub = _voiceService.incomingAudioStream.listen((audioBytes) async {
      try {
        await _audioPlayer.play(BytesSource(audioBytes));
      } catch (e) {
        print('Error playing audio: $e');
      }
    });
  }

  @override
  void dispose() {
    _micLevelSub?.cancel();
    _statusSub?.cancel();
    _logSub?.cancel();
    _audioSub?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _voiceService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceChat() async {
    if (_isListening) {
      await _voiceService.stopMic();
      _pulseController.stop();
      _waveController.stop();
      setState(() => _isListening = false);
    } else {
      if (!_isConnected) {
        bool connected = await _voiceService.startSession();
        if (!connected) return;
      }
      
      bool started = await _voiceService.startMic();
      if (started) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
        setState(() => _isListening = true);
      }
    }
  }

  void _showLogsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Connection Logs',
            style: TextStyle(
              color: const Color(0xFF4A2B5C),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _logs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: const Color(0xFF4A2B5C).withOpacity(0.8),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: const Color(0xFF8B4C9B)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header section with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF4A2B5C), const Color(0xFF8B4C9B)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Dr. Swatantra AI Voice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status indicator with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _isConnected 
                            ? const Color(0xFF8B4C9B).withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isListening ? _pulseAnimation.value : 1.0,
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_off,
                                  color: _isConnected 
                                      ? const Color(0xFF8B4C9B)
                                      : Colors.orange,
                                  size: 16,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _status,
                            style: TextStyle(
                              fontSize: 16,
                              color: _isConnected 
                                  ? const Color(0xFF8B4C9B)
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Waveform visualization
                    if (_isListening) ...[
                      Container(
                        height: 100,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4C9B).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF8B4C9B).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: CustomPaint(
                          size: const Size(double.infinity, 100),
                          painter: WaveformPainter(
                            amplitudes: _amplitudes,
                            waveColor: const Color(0xFF8B4C9B),
                            lineWidth: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ] else ...[
                      const SizedBox(height: 80),
                    ],
                    // Animated Voice button
                    GestureDetector(
                      onTap: _toggleVoiceChat,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isListening ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: _isListening 
                                      ? const Color(0xFF8B4C9B).withOpacity(0.5)
                                      : Colors.grey.shade300,
                                  width: _isListening ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isListening 
                                        ? const Color(0xFF8B4C9B).withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.3),
                                    blurRadius: _isListening ? 15 : 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF4A2B5C),
                                      const Color(0xFF8B4C9B),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _isListening ? 'AI is listening...' : 
                      _isConnected ? 'Tap to start talking' : 'Tap to connect',
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color(0xFF4A2B5C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    if (_isConnected) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Powered by Swatantra AI',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF4A2B5C).withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Connection status and logs toggle
                    if (_logs.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => _showLogsDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Connection Logs (${_logs.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_none,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Test Microphone',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
