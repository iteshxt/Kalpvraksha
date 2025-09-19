import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../main_navigation.dart';

class ConsultantChatbotPage extends StatefulWidget {
  final String category;
  final String categoryTitle;
  final Color categoryColor;

  const ConsultantChatbotPage({
    Key? key,
    required this.category,
    required this.categoryTitle,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<ConsultantChatbotPage> createState() => _ConsultantChatbotPageState();
}

class _ConsultantChatbotPageState extends State<ConsultantChatbotPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _selectedTabIndex = 3; // Set to 3 for Chat tab
  late AnimationController _voiceAnimationController;
  late Animation<double> _voiceScaleAnimation;
  late Animation<double> _voicePulseAnimation;

  // Category-specific prompts based on Dr. Swatantra Jain's approach
  static const Map<String, String> categoryPrompts = {
    'child_problems': '''
You are an AI wellness consultant based on Dr. Swatantra Jain's holistic approach to child health.
Provide compassionate, practical advice for common childhood issues including:
- Behavioral problems, sleep issues, nutrition concerns
- Focus on natural remedies, parenting techniques, and holistic care
- Consider Ayurvedic principles suitable for children
- Always recommend consulting pediatricians for serious concerns
- Provide age-appropriate solutions and gentle interventions
''',
    'depression': '''
You are an AI wellness consultant following Dr. Swatantra Jain's approach to mental health.
Provide supportive, holistic guidance for depression and mental wellness:
- Focus on natural healing, meditation, breathing techniques
- Lifestyle modifications, diet, and exercise recommendations
- Ayurvedic approaches to mental balance
- Spiritual practices and mindfulness techniques
- Always emphasize professional mental health support when needed
- Provide hope and practical daily strategies
''',
    'disability_children': '''
You are an AI wellness consultant specializing in holistic care for children with disabilities.
Following Dr. Swatantra Jain's compassionate approach:
- Provide emotional support and practical guidance for families
- Focus on enhancing quality of life and maximizing potential
- Suggest therapies, nutrition, and supportive care
- Address physical, emotional, and spiritual needs
- Emphasize the child's strengths and possibilities
- Recommend appropriate professional interventions
''',
    'pregnancy_care': '''
You are an AI wellness consultant for pregnancy care based on Dr. Swatantra Jain's holistic approach.
Provide comprehensive guidance for expecting mothers:
- Prenatal nutrition, exercise, and wellness practices
- Natural remedies for common pregnancy discomforts
- Ayurvedic principles for healthy pregnancy
- Emotional and spiritual preparation for motherhood
- Postpartum care and recovery guidance
- Always emphasize regular prenatal medical checkups
''',
    'healthy_lifestyle': '''
You are an AI wellness consultant promoting healthy lifestyle based on Dr. Swatantra Jain's philosophy.
Provide practical guidance for overall wellness:
- Balanced nutrition and mindful eating practices
- Exercise routines and physical fitness
- Stress management and work-life balance
- Sleep hygiene and relaxation techniques
- Preventive health measures and natural remedies
- Spiritual practices for holistic well-being
''',
    'general_health': '''
You are an AI wellness consultant providing general health guidance following Dr. Swatantra Jain's holistic approach.
Address common health concerns with:
- Natural remedies and preventive care
- Ayurvedic principles for health maintenance
- Lifestyle modifications for better health
- Mind-body connection in healing
- Nutritional guidance and herbal solutions
- When to seek professional medical attention
''',
  };

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();

    _voiceAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _voiceScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _voiceAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _voicePulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _voiceAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _addWelcomeMessage() {
    final welcomeMessages = {
      'child_problems':
          'Hello! I\'m here to help with child health and development concerns. What would you like to discuss about your child\'s wellbeing?',
      'depression':
          'Welcome! I\'m here to provide supportive guidance for mental wellness. How can I help you on your journey to better mental health?',
      'disability_children':
          'Hello! I\'m here to support families caring for children with special needs. What guidance can I provide today?',
      'pregnancy_care':
          'Welcome! I\'m here to guide you through your pregnancy journey with holistic wellness advice. How can I assist you?',
      'healthy_lifestyle':
          'Hello! I\'m here to help you build healthy lifestyle habits. What aspect of wellness would you like to explore?',
      'general_health':
          'Welcome! I\'m here to provide holistic health guidance. What health concern would you like to discuss?',
    };

    setState(() {
      _messages.add({
        'message':
            welcomeMessages[widget.category] ??
            'Hello! How can I help you today?',
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _sendMessage([String? messageText]) async {
    final message = messageText ?? _messageController.text;
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'message': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final systemPrompt =
          categoryPrompts[widget.category] ??
          categoryPrompts['general_health']!;
      final enhancedMessage =
          '''
$systemPrompt

User's question/concern: $message

Please provide a helpful, compassionate response following Dr. Swatantra Jain's holistic wellness approach.
Structure your response with:
1. Understanding and validation
2. Practical immediate steps
3. Long-term wellness strategies
4. When to seek professional help (if applicable)

Keep the tone warm, supportive, and empowering.
''';

      final geminiService = GeminiService();
      final response = await geminiService.getChatResponse(enhancedMessage);

      setState(() {
        _messages.add({
          'message': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'message':
              'I apologize, but I\'m having trouble connecting right now. Please try again in a moment.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });

    if (index == 2) {
      _voiceAnimationController.forward().then((_) {
        _voiceAnimationController.reverse();
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainNavigation(initialIndex: 2),
        ),
        (route) => false, // Remove all previous routes
      );
    } else if (index != 3) {
      // Navigate to other pages through MainNavigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainNavigation(initialIndex: index),
        ),
        (route) => false, // Remove all previous routes
      );
    }
    // If index == 3 (Chat), stay on current page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text(
              'AI Wellness Consultant',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: widget.categoryColor,
              size: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: widget.categoryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Specialized guidance for ${widget.categoryTitle.toLowerCase()}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages area
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          // Enhanced Glassmorphism Navigation Bar
          Container(
            height: 85,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.8),
                        Colors.grey.shade50.withOpacity(0.85),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.03),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 10,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildTabItem(
                        icon: Icons.explore_rounded,
                        label: 'Explore',
                        index: 1,
                      ),
                      const SizedBox(
                        width: 70,
                      ), // Space for floating voice button
                      _buildTabItem(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Chat',
                        index: 3,
                      ),
                      _buildTabItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        index: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Voice Button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35,
            top: -15,
            child: AnimatedBuilder(
              animation: _voiceAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _selectedTabIndex == 2
                      ? _voicePulseAnimation.value
                      : _voiceScaleAnimation.value,
                  child: GestureDetector(
                    onTap: () => _onItemTapped(2),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _selectedTabIndex == 2
                              ? [
                                  const Color(0xFF6C63FF),
                                  const Color(0xFF8B5CF6),
                                ]
                              : [
                                  const Color(0xFF667EEA),
                                  const Color(0xFF764BA2),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_selectedTabIndex == 2
                                        ? const Color(0xFF6C63FF)
                                        : const Color(0xFF667EEA))
                                    .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Icon(
                              _selectedTabIndex == 2
                                  ? Icons.graphic_eq_rounded
                                  : Icons.radio_button_checked_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? Colors.black.withOpacity(0.8)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                size: isSelected ? 28 : 26,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.7),
                shadows: isSelected
                    ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case 'child_problems':
        return Icons.child_care;
      case 'depression':
        return Icons.psychology;
      case 'disability_children':
        return Icons.accessibility;
      case 'pregnancy_care':
        return Icons.pregnant_woman;
      case 'healthy_lifestyle':
        return Icons.fitness_center;
      case 'general_health':
        return Icons.health_and_safety;
      default:
        return Icons.healing;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getCategoryIcon(),
              size: 48,
              color: widget.categoryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.categoryTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your wellness consultation',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isUser = message['isUser'];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.healing, size: 16, color: widget.categoryColor),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message['message'],
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.healing, size: 16, color: widget.categoryColor),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AI is typing',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.categoryColor,
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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        85,
      ), // Added bottom padding for nav bar
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Ask about your wellness concern...',
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _voiceAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
