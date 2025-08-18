import 'package:flutter/material.dart';
import 'package:muktiya_new/services/voice_assistant_service.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  final VoiceAssistantService _assistantService = VoiceAssistantService();
  String _userTranscript = '';
  String _aiResponse = '';
  bool _isActive = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceChat() async {
    if (_isActive) {
      _assistantService.stopVoiceLoop();
      setState(() => _isActive = false);
    } else {
      setState(() {
        _userTranscript = '';
        _aiResponse = '';
        _isActive = true;
      });

      _assistantService.startVoiceLoop(
        (transcript) {
          setState(() => _userTranscript = transcript);
        },
        (finalResponse) {
          setState(() => _aiResponse = finalResponse);
        },
        (chunk) {
          setState(() => _aiResponse += chunk);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A2B5C), Color(0xFF8B4C9B)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_back, color: Colors.white),
                    Text(
                      'Dr. Swatantra AI Voice',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // status indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isActive ? _pulseAnimation.value : 1.0,
                              child: Icon(
                                _isActive ? Icons.mic : Icons.mic_off,
                                color: Colors.orange,
                                size: 16,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isActive
                              ? 'Listening & Responding...'
                              : 'Ready to connect',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (_userTranscript.isNotEmpty)
                    Text(
                      'You: $_userTranscript',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                  if (_aiResponse.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'AI: $_aiResponse',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // mic button
                  GestureDetector(
                    onTap: _toggleVoiceChat,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isActive ? _pulseAnimation.value : 1.0,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A2B5C), Color(0xFF8B4C9B)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isActive
                                      ? const Color(0xFF8B4C9B).withOpacity(0.3)
                                      : Colors.grey.withOpacity(0.3),
                                  blurRadius: _isActive ? 15 : 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isActive ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
