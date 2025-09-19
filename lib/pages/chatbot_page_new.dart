import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import 'voice_page.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'consultant_chatbot_page.dart';
import '../services/auth_service.dart';
import '../services/voice_stream_service.dart';

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
  bool _conversationStarted = false;
  int _selectedTab = 3; // Set to 3 for Chat tab
  String _selectedMode = 'Chatbot'; // Default selection

  // Predefined prompts for the welcome screen
  final List<String> _predefinedPrompts = [
    "What are some natural remedies for stress relief?",
    "How can I improve my sleep quality naturally?",
    "What foods help boost immunity?",
    "Give me tips for mental wellness",
    "How to maintain work-life balance?",
    "What are some breathing exercises for anxiety?",
  ];

  // Wellness categories
  final List<Map<String, dynamic>> _wellnessCategories = [
    {
      'title': 'Child Problems',
      'icon': Icons.child_care,
      'backgroundColor': Color(0xFFFFF2E6),
      'iconColor': Color(0xFFFF9500),
      'categoryId': 'child_problems',
    },
    {
      'title': 'Depression',
      'icon': Icons.psychology,
      'backgroundColor': Color(0xFFE6F7FF),
      'iconColor': Color(0xFF1890FF),
      'categoryId': 'depression',
    },
    {
      'title': 'Disability Care',
      'icon': Icons.accessibility,
      'backgroundColor': Color(0xFFF6FFED),
      'iconColor': Color(0xFF52C41A),
      'categoryId': 'disability_children',
    },
    {
      'title': 'Pregnancy Care',
      'icon': Icons.pregnant_woman,
      'backgroundColor': Color(0xFFFFF0F6),
      'iconColor': Color(0xFFEB2F96),
      'categoryId': 'pregnancy_care',
    },
    {
      'title': 'Lifestyle',
      'icon': Icons.fitness_center,
      'backgroundColor': Color(0xFFF9F0FF),
      'iconColor': Color(0xFF722ED1),
      'categoryId': 'healthy_lifestyle',
    },
    {
      'title': 'General Health',
      'icon': Icons.health_and_safety,
      'backgroundColor': Color(0xFFE6FFFB),
      'iconColor': Color(0xFF13C2C2),
      'categoryId': 'general_health',
    },
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
            'Failed to start voice session. Please try again.',
            isUser: false,
          );
          return;
        }
      }

      final success = await _voiceService.startMic();
      if (success) {
        setState(() => _isListening = true);
        _addMessage('Voice interaction started. Speak now...', isUser: false);
      } else {
        _addMessage('Failed to start voice interaction', isUser: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          // Dropdown header
          _buildDropdownHeader(),

          // Content area
          Expanded(
            child: _selectedMode == 'Chatbot'
                ? (_conversationStarted
                      ? _buildChatInterface()
                      : _buildWelcomeInterface())
                : _buildWellnessInterface(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: _selectedTab == 1,
              onTap: () {
                setState(() => _selectedTab = 1);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            _buildTabItem(
              icon: Icons.water_drop,
              label: 'Explore',
              isSelected: _selectedTab == 0,
              onTap: () {
                setState(() => _selectedTab = 0);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ExplorePage()),
                );
              },
            ),
            // Voice icon in center
            _buildTabItem(
              icon: Icons.mic,
              label: 'Voice',
              isSelected: _selectedTab == 4,
              onTap: () {
                setState(() => _selectedTab = 4);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VoicePage()),
                );
              },
            ),
            _buildTabItem(
              icon: Icons.chat_bubble,
              label: 'Chat',
              isSelected: _selectedTab == 3,
              onTap: () => setState(() => _selectedTab = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 2, color: Colors.transparent),
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFFFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedMode,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMode = newValue;
                    if (newValue == 'Chatbot') {
                      _conversationStarted = false;
                      _messages.clear();
                    }
                  });
                }
              },
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.black87),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              dropdownColor: Colors.white,
              items: [
                DropdownMenuItem(
                  value: 'Chatbot',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          color: Colors.black87,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text('AI Chatbot'),
                      ],
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Wellness Consultant',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.healing, color: Colors.black87, size: 20),
                        SizedBox(width: 12),
                        Text('Wellness Consultant'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessInterface() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Dr. Swatantra\'s',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Wellness Consultant',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFE6F7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Color(0xFF1890FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'This AI consultant provides general wellness guidance. For serious medical conditions, please consult a healthcare professional.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Categories section
            Text(
              'Consultation Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // Category Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: _wellnessCategories.map((category) {
                return _buildModernCategoryCard(
                  context,
                  category['title'],
                  category['icon'],
                  category['backgroundColor'],
                  category['iconColor'],
                  category['categoryId'],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    String categoryId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultantChatbotPage(
              category: categoryId,
              categoryTitle: title,
              categoryColor: iconColor,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Available',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Welcome interface with predefined prompts (for chatbot mode)
  Widget _buildWelcomeInterface() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Welcome message card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.chat_bubble,
                    size: 32,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Hello! I'm here to help with your wellness journey. I can provide guidance on natural healing, mental well-being, and holistic health. What would you like to discuss about your wellness?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: _predefinedPrompts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _buildPromptCard(_predefinedPrompts[index]),
                      );
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
                backgroundColor: Colors.black87,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.black54, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                prompt,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 16),
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

  // Chat interface
  Widget _buildChatInterface() {
    return Container(
      color: Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
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
                      color: _isListening
                          ? Colors.red
                          : Colors.black.withOpacity(0.05),
                      border: Border.all(
                        color: _isListening ? Colors.red : Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: _isListening ? Colors.white : Colors.black54,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
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
                      color: Colors.black87,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.chat_bubble, size: 48, color: Colors.black87),
          ),
          SizedBox(height: 24),
          Text(
            'AI Chat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start your conversation with Dr. Swatantra AI',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.psychology, size: 16, color: Colors.black87),
            ),
            SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[SizedBox(width: 12), _buildUserAvatar()],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.psychology, size: 16, color: Colors.black87),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI is typing',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
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
          border: Border.all(color: Colors.black87, width: 2),
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
                color: Colors.black.withOpacity(0.05),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.black87,
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
        color: Colors.black87,
        border: Border.all(color: Colors.black87, width: 2),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 16),
    );
  }
}
