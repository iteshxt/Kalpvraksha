import 'package:flutter/material.dart';
import 'package:muktiya_new/services/voice_assistant_service.dart';
import 'package:muktiya_new/pages/home_page.dart';
import 'package:muktiya_new/pages/explore_page.dart';
import 'package:muktiya_new/pages/chatbot_page.dart';
import 'package:muktiya_new/pages/profile_page.dart';
import 'package:muktiya_new/main_navigation.dart';
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
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  final VoiceAssistantService _assistantService = VoiceAssistantService();
  String _userTranscript = '';
  String _aiResponse = '';
  bool _isActive = false;

  // Chat messages list
  List<ChatMessage> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _rippleController;
  late AnimationController _floatingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _floatingAnimation;

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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _rippleController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667EEA).withOpacity(0.1),
                  Color(0xFF764BA2).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand,
              size: 40,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hello! I\'m Dr. Swatantra AI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the microphone to start our conversation about your wellness journey.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: message.isUser
                ? const BoxDecoration(
                    color: Color(0xFF667EEA),
                    shape: BoxShape.circle,
                  )
                : BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    shape: BoxShape.circle,
                  ),
            child: Icon(
              message.isUser ? Icons.person : Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Color(0xFF667EEA).withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: message.isUser
                      ? Radius.circular(4)
                      : Radius.circular(18),
                  topRight: message.isUser
                      ? Radius.circular(18)
                      : Radius.circular(4),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
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
        // Current user transcript (if any)
        if (_userTranscript.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF667EEA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      _userTranscript,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Current AI response (if any)
        if (_aiResponse.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      _aiResponse,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
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

  Future<void> _toggleVoiceChat() async {
    if (_isActive) {
      _assistantService.stopVoiceLoop();
      setState(() => _isActive = false);
      _pulseController.stop();
      _waveController.stop();
      _rippleController.stop();
    } else {
      setState(() {
        _userTranscript = '';
        _aiResponse = '';
        _isActive = true;
      });

      _pulseController.repeat(reverse: true);
      _waveController.repeat(reverse: true);
      _rippleController.repeat();

      _assistantService.startVoiceLoop(
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

            // Auto-scroll to bottom
            _scrollToBottom();
          });
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
      backgroundColor: Color(0xFFF8F9FF),
      body: Column(
        children: [
          // Enhanced header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: const [
                          Text(
                            'AI Voice Assistant',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Dr. Swatantra AI',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.circle,
                            color: Colors.greenAccent,
                            size: 8,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main content area
          Expanded(
            child: Stack(
              children: [
                // Floating background elements
                ...List.generate(6, (index) {
                  return AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      final offset =
                          math.sin(
                            _floatingAnimation.value * 2 * math.pi + index,
                          ) *
                          20;
                      return Positioned(
                        left:
                            50.0 +
                            (index * 80.0) %
                                (MediaQuery.of(context).size.width - 100),
                        top: 100.0 + offset + (index * 120.0) % 300,
                        child: Opacity(
                          opacity: 0.05,
                          child: Container(
                            width: 60 + (index % 3) * 20,
                            height: 60 + (index % 3) * 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF667EEA).withOpacity(0.3),
                                  Color(0xFF764BA2).withOpacity(0.2),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Conversation display area
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF667EEA).withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _chatMessages.isEmpty
                              ? _buildWelcomeMessage()
                              : ListView.builder(
                                  controller: _scrollController,
                                  itemCount:
                                      _chatMessages.length +
                                      (_userTranscript.isNotEmpty ||
                                              _aiResponse.isNotEmpty
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    if (index < _chatMessages.length) {
                                      return _buildChatMessage(
                                        _chatMessages[index],
                                      );
                                    } else {
                                      // Show current conversation in progress
                                      return _buildCurrentConversation();
                                    }
                                  },
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Enhanced microphone button with animations
                      Center(
                        child: GestureDetector(
                          onTap: _toggleVoiceChat,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _pulseAnimation,
                              _waveAnimation,
                              _rippleAnimation,
                            ]),
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outermost ripple effect
                                  if (_isActive) ...[
                                    Transform.scale(
                                      scale:
                                          1.0 + (_rippleAnimation.value * 0.8),
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Color(0xFF667EEA)
                                                .withOpacity(
                                                  0.3 *
                                                      (1 -
                                                          _rippleAnimation
                                                              .value),
                                                ),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale:
                                          1.0 + (_rippleAnimation.value * 0.5),
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Color(0xFF764BA2)
                                                .withOpacity(
                                                  0.4 *
                                                      (1 -
                                                          _rippleAnimation
                                                              .value),
                                                ),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Colored border rings
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isActive
                                            ? Color(0xFF667EEA).withOpacity(0.6)
                                            : Color(
                                                0xFF667EEA,
                                              ).withOpacity(0.2),
                                        width: 3,
                                      ),
                                    ),
                                  ),

                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isActive
                                            ? Color(0xFF764BA2).withOpacity(0.4)
                                            : Color(
                                                0xFF764BA2,
                                              ).withOpacity(0.15),
                                        width: 2,
                                      ),
                                    ),
                                  ),

                                  // Main microphone button
                                  Transform.scale(
                                    scale: _isActive
                                        ? _pulseAnimation.value
                                        : 1.0,
                                    child: Container(
                                      width: 76,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: _isActive
                                              ? [
                                                  Color(0xFF667EEA),
                                                  Color(0xFF764BA2),
                                                ]
                                              : [
                                                  Color(
                                                    0xFF667EEA,
                                                  ).withOpacity(0.8),
                                                  Color(
                                                    0xFF764BA2,
                                                  ).withOpacity(0.8),
                                                ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _isActive
                                                ? Color(
                                                    0xFF667EEA,
                                                  ).withOpacity(0.4)
                                                : Color(
                                                    0xFF667EEA,
                                                  ).withOpacity(0.2),
                                            blurRadius: _isActive ? 20 : 12,
                                            offset: const Offset(0, 6),
                                            spreadRadius: _isActive ? 2 : 0,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isActive
                                            ? Icons.stop_rounded
                                            : Icons.mic_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action indicator
                      AnimatedOpacity(
                        opacity: _isActive ? 1.0 : 0.7,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _isActive ? 'Tap to stop' : 'Tap to speak',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isActive
                                ? Color(0xFF667EEA)
                                : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
