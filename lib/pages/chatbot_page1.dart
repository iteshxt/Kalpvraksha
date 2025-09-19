import 'package:flutter/material.dart';
import 'package:muktiya_new/services/gemini_service.dart';
import 'package:muktiya_new/services/voice_stream_service.dart';
import 'package:muktiya_new/services/auth_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final GeminiService _geminiService = GeminiService();
  final VoiceStreamService _voiceService = VoiceStreamService(
    apiBaseUrl: 'https://swatantra-ai.onrender.com',
  );
  final AuthService _authService = AuthService();

  bool _isListening = false;
  bool _isTyping = false;
  bool _conversationStarted = false; // Track if conversation has begun

  // Predefined prompts for the welcome screen
  final List<String> _predefinedPrompts = [
    "What are some natural remedies for stress relief?",
    "How can I improve my sleep quality naturally?",
    "What foods help boost immunity?",
    "Give me tips for mental wellness",
    "How to maintain work-life balance?",
    "What are some breathing exercises for anxiety?",
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize voice service
    await _voiceService.init();

    // Listen to voice service streams
    _voiceService.logStream.listen((log) {
      print('Voice Service Log: $log');
    });

    _voiceService.statusStream.listen((status) {
      print('Voice Service Status: $status');
    });
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Start conversation if not already started
    if (!_conversationStarted) {
      setState(() => _conversationStarted = true);
    }

    _textController.clear();
    _addMessage(text, isUser: true);

    setState(() => _isTyping = true);

    try {
      final response = await _geminiService.getChatResponse(text);
      _addMessage(response, isUser: false);
    } catch (e) {
      _addMessage(
        'Error: Unable to get response. Please try again.',
        isUser: false,
      );
    }
  }

  Future<void> _toggleVoiceChat() async {
    if (_isListening) {
      await _voiceService.stopMic();
      setState(() => _isListening = false);
    } else {
      // Start session first if not connected
      if (!_voiceService.isConnected) {
        final sessionStarted = await _voiceService.startSession();
        if (!sessionStarted) {
          _addMessage(
            '❌ Failed to start voice session. Please try again.',
            isUser: false,
          );
          return;
        }
      }

      final success = await _voiceService.startMic();
      if (success) {
        setState(() => _isListening = true);
        _addMessage(
          '🎤 Voice interaction started. Speak now...',
          isUser: false,
        );
      } else {
        _addMessage('❌ Failed to start voice interaction', isUser: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1F8),
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
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(Icons.info_outline, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Dr. Swatantra AI',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Your holistic wellness consultant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content area
          Expanded(
            child:
                _conversationStarted
                    ? _buildChatInterface()
                    : _buildWelcomeInterface(),
          ),
        ],
      ),
    );
  }

  // Welcome interface with predefined prompts
  Widget _buildWelcomeInterface() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Welcome message card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A2B5C).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              "Hello! I'm here to help with your wellness journey. I can provide guidance on natural healing, mental well-being, and holistic health. What would you like to discuss about your wellness?",
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF4A2B5C).withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Predefined prompts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Questions:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A2B5C),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 6,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _predefinedPrompts.length,
                    itemBuilder: (context, index) {
                      return _buildPromptCard(_predefinedPrompts[index]);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Begin Conversation button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _beginConversation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2B5C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Begin Conversation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build prompt card widget
  Widget _buildPromptCard(String prompt) {
    return GestureDetector(
      onTap: () => _selectPrompt(prompt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B4C9B).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A2B5C).withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: const Color(0xFF8B4C9B),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                prompt,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF4A2B5C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF8B4C9B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Select a predefined prompt
  void _selectPrompt(String prompt) {
    setState(() {
      _conversationStarted = true;
    });
    _sendTextMessage(prompt);
  }

  // Begin conversation without a prompt
  void _beginConversation() {
    setState(() {
      _conversationStarted = true;
    });
  }

  // Chat interface (existing chat UI)
  Widget _buildChatInterface() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2B5C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF4A2B5C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thinking...',
                          style: TextStyle(color: const Color(0xFF4A2B5C)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A2B5C).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice button
                GestureDetector(
                  onTap: _toggleVoiceChat,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _isListening
                              ? Colors.red
                              : const Color(0xFF8B4C9B).withOpacity(0.1),
                      border: Border.all(
                        color:
                            _isListening ? Colors.red : const Color(0xFF8B4C9B),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color:
                          _isListening ? Colors.white : const Color(0xFF8B4C9B),
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2B5C).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF8B4C9B).withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: const Color(0xFF4A2B5C)),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: const Color(0xFF4A2B5C).withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendTextMessage,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Send button
                GestureDetector(
                  onTap: () => _sendTextMessage(_textController.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4A2B5C),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF4A2B5C), const Color(0xFF8B4C9B)],
                ),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF4A2B5C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B5C).withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color:
                      message.isUser ? Colors.white : const Color(0xFF4A2B5C),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[const SizedBox(width: 8), _buildUserAvatar()],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper methods for user profile
  String? _getProfileImageUrl() {
    final user = _authService.currentUser;
    if (user != null && user.photoURL != null) {
      return user.photoURL;
    }
    return null;
  }

  bool _isGoogleUser() {
    final user = _authService.currentUser;
    if (user != null) {
      for (var provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          return true;
        }
      }
    }
    return false;
  }

  Widget _buildUserAvatar() {
    final isGoogleUser = _isGoogleUser();
    final profileImageUrl = _getProfileImageUrl();

    if (isGoogleUser && profileImageUrl != null) {
      // Show Google profile image
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF8B4C9B), width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            profileImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultUserAvatar();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFF8B4C9B).withOpacity(0.2),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B4C9B),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return _buildDefaultUserAvatar();
    }
  }

  Widget _buildDefaultUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF8B4C9B).withOpacity(0.2),
        border: Border.all(color: const Color(0xFF8B4C9B), width: 2),
      ),
      child: const Icon(Icons.person, color: Color(0xFF8B4C9B), size: 18),
    );
  }
}
