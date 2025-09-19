import 'package:flutter/material.dart';
import 'package:muktiya_new/services/voice_assistant_service.dart';
import 'dart:math' as math;

// Message class to store chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class VoicePage extends StatefulWidget {
  final VoiceAssistantService voiceService;
  final bool startListening;

  const VoicePage({
    super.key,
    required this.voiceService,
    this.startListening = false,
  });

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  String _userTranscript = '';
  String _aiResponse = '';
  bool _isActive = false;

  // Chat messages list
  List<ChatMessage> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();

  // Voice wave animations
  late AnimationController _waveController1;
  late AnimationController _waveController2;
  late AnimationController _waveController3;
  late AnimationController _pulseController;
  late AnimationController _orbController;
  late AnimationController _breatheController;

  late Animation<double> _wave1;
  late Animation<double> _wave2;
  late Animation<double> _wave3;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    if (widget.startListening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startVoiceAssistant();
      });
    }
  }

  void _setupAnimations() {
    // Voice wave animations
    _waveController1 = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _waveController2 = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _waveController3 = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _wave1 = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_waveController1);
    _wave2 = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_waveController2);
    _wave3 = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_waveController3);

    // Pulse animation for floating button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Orb movement animation
    _orbController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _orbAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.linear),
    );

    // Breathing animation for voice button
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _orbController.repeat();
    _breatheController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController1.dispose();
    _waveController2.dispose();
    _waveController3.dispose();
    _pulseController.dispose();
    _orbController.dispose();
    _breatheController.dispose();
    _scrollController.dispose();
    
    // Stop voice service when leaving the page
    if (_isActive) {
      widget.voiceService.stopVoiceLoop();
    }
    
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  void _startVoiceAssistant() async {
    if (_isActive) return;

    setState(() {
      _userTranscript = '';
      _aiResponse = '';
      _isActive = true;
    });

    // Start wave animations
    _waveController1.repeat();
    _waveController2.repeat();
    _waveController3.repeat();
    _pulseController.repeat(reverse: true);

    widget.voiceService.startVoiceLoop(
      (transcript) {
        setState(() => _userTranscript = transcript);
      },
      (finalResponse) {
        setState(() {
          _aiResponse = finalResponse;

          // Add user message to chat
          if (_userTranscript.isNotEmpty) {
            _chatMessages.add(
              ChatMessage(
                text: _userTranscript,
                isUser: true,
                timestamp: DateTime.now(),
              ),
            );
          }

          // Add AI response to chat
          if (finalResponse.isNotEmpty) {
            _chatMessages.add(
              ChatMessage(
                text: finalResponse,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          }

          // Clear current transcript and response for next interaction
          _userTranscript = '';
          _aiResponse = '';

          // Auto-scroll to bottom with delay
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        });
      },
      (chunk) {
        setState(() => _aiResponse += chunk);
        // Auto-scroll while receiving chunks
        _scrollToBottom();
      },
    );
  }

  void _stopVoiceAssistant() {
    if (!_isActive) return;

    widget.voiceService.stopVoiceLoop();
    setState(() => _isActive = false);

    // Stop animations
    _waveController1.stop();
    _waveController2.stop();
    _waveController3.stop();
    _pulseController.stop();
  }

  Widget _buildVoiceWaves() {
    if (!_isActive) return const SizedBox();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_wave1, _wave2, _wave3]),
        builder: (context, child) {
          return CustomPaint(
            painter: VoiceWavePainter(
              wave1Value: _wave1.value,
              wave2Value: _wave2.value,
              wave3Value: _wave3.value,
              isActive: _isActive,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingOrbs() {
    return AnimatedBuilder(
      animation: _orbAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(3, (index) {
            final angle = _orbAnimation.value + (index * 2 * math.pi / 3);
            final radius = 30.0 + (index * 15);
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x - 8,
              top: 200 + y,
              child: Container(
                width: 16 - (index * 2),
                height: 16 - (index * 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.8),
                      const Color(0xFF764BA2).withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 40), // Add some top spacing
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF667EEA).withOpacity(0.1),
                const Color(0xFF764BA2).withOpacity(0.05),
                Colors.transparent,
              ],
            ),
          ),
          child: const Icon(
            Icons.waving_hand,
            size: 60,
            color: Color(0xFF667EEA),
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Voice Assistant Ready',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF667EEA).withOpacity(0.2),
            ),
          ),
          child: const Text(
            'Tap the crystal to start conversation',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernChatMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with gradient and glow
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: message.isUser
                  ? const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    ),
              boxShadow: [
                BoxShadow(
                  color: message.isUser
                      ? const Color(0xFF667EEA).withOpacity(0.4)
                      : const Color(0xFF11998E).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              message.isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Message bubble with glassmorphism effect
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          const Color(0xFF667EEA).withOpacity(0.05),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[50]!.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: message.isUser
                      ? const Radius.circular(8)
                      : const Radius.circular(28),
                  topRight: message.isUser
                      ? const Radius.circular(28)
                      : const Radius.circular(8),
                  bottomLeft: const Radius.circular(28),
                  bottomRight: const Radius.circular(28),
                ),
                border: Border.all(
                  color: message.isUser
                      ? const Color(0xFF667EEA).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentConversation() {
    return Column(
      children: [
        // Current user transcript
        if (_userTranscript.isNotEmpty) ...[
          _buildModernChatMessage(ChatMessage(
            text: _userTranscript,
            isUser: true,
            timestamp: DateTime.now(),
          )),
        ],
        // Current AI response with typing indicator
        if (_aiResponse.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF11998E).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey[50]!.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                      border: Border.all(
                        color: const Color(0xFF11998E).withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _aiResponse,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Typing indicator
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF11998E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Typing...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF11998E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCrystalVoiceButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _breatheAnimation]),
      builder: (context, child) {
        return GestureDetector(
          onTap: _isActive ? _stopVoiceAssistant : _startVoiceAssistant,
          child: Transform.scale(
            scale: _isActive ? _pulseAnimation.value : _breatheAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: _isActive
                      ? [
                          const Color(0xFF667EEA),
                          const Color(0xFF764BA2),
                          const Color(0xFF667EEA).withOpacity(0.8),
                        ]
                      : [
                          const Color(0xFF667EEA).withOpacity(0.8),
                          const Color(0xFF764BA2).withOpacity(0.6),
                          Colors.transparent,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(_isActive ? 0.6 : 0.3),
                    blurRadius: _isActive ? 30 : 20,
                    offset: const Offset(0, 8),
                    spreadRadius: _isActive ? 5 : 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _isActive ? Icons.stop_rounded : Icons.diamond_rounded,
                  color: Colors.white,
                  size: _isActive ? 40 : 35,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Voice waves background
          _buildVoiceWaves(),
          
          // Floating orbs
          if (!_isActive) _buildFloatingOrbs(),
          
          Column(
            children: [
              // Minimal header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Spacer(),
                      Column(
                        children: [
                          const Text(
                            'Voice Assistant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isActive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: _isActive ? Colors.red : Colors.green,
                                  size: 8,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isActive ? 'Active' : 'Ready',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: _isActive ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // Main conversation area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _chatMessages.isEmpty && _userTranscript.isEmpty && _aiResponse.isEmpty
                      ? _buildWelcomeMessage()
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _chatMessages.length +
                              (_userTranscript.isNotEmpty || _aiResponse.isNotEmpty ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _chatMessages.length) {
                              return _buildModernChatMessage(_chatMessages[index]);
                            } else {
                              return _buildCurrentConversation();
                            }
                          },
                        ),
                ),
              ),

              // Crystal voice button
              Container(
                height: 140,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 100), // Add margin to stay above nav bar
                child: _buildCrystalVoiceButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for voice waves
class VoiceWavePainter extends CustomPainter {
  final double wave1Value;
  final double wave2Value;
  final double wave3Value;
  final bool isActive;

  VoiceWavePainter({
    required this.wave1Value,
    required this.wave2Value,
    required this.wave3Value,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint1 = Paint()
      ..color = const Color(0xFF667EEA).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = const Color(0xFF764BA2).withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint3 = Paint()
      ..color = const Color(0xFF667EEA).withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final width = size.width;

    // Draw animated waves
    _drawWave(canvas, size, paint1, wave1Value, centerY, width, 30);
    _drawWave(canvas, size, paint2, wave2Value, centerY, width, 20);
    _drawWave(canvas, size, paint3, wave3Value, centerY, width, 15);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, double waveValue,
      double centerY, double width, double amplitude) {
    final path = Path();
    path.moveTo(0, centerY);

    for (double x = 0; x <= width; x += 3) {
      final y = centerY +
          amplitude *
              math.sin((x / width * 3 * math.pi) + waveValue) *
              math.sin((x / width * 1.5 * math.pi) + waveValue * 0.7);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}