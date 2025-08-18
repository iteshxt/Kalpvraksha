import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'wellness_consultant_page.dart';
import 'chatbot_page.dart';

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

class _ConsultantChatbotPageState extends State<ConsultantChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _selectedTab = 2; // Set to 2 for Consultant tab

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

  Future<void> _sendMessage(String message) async {
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
      // Get category-specific prompt
      final systemPrompt =
          categoryPrompts[widget.category] ??
          categoryPrompts['general_health']!;

      // Create enhanced prompt with context
      final enhancedMessage = '''
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'AI Wellness Consultant',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4A2B5C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showCategoryInfo();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F1F8), // Consistent light purple background
        ),
        child: Column(
          children: [
            // Category Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A2B5C).withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(),
                    color: const Color(0xFF8B4C9B),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Specialized guidance for ${widget.categoryTitle.toLowerCase()}',
                      style: const TextStyle(
                        color: Color(0xFF4A2B5C),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingMessage();
                  }

                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Input Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F1F8), // Same as chatbot page
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF8B4C9B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(
                            color: Color(
                              0xFF4A2B5C,
                            ), // Dark purple text - clearly visible
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Describe your concern...',
                            hintStyle: TextStyle(
                              color: const Color(0xFF4A2B5C).withOpacity(0.5),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF8B4C9B),
                        radius: 24,
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed:
                              () => _sendMessage(_messageController.text),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabItem(
              icon: Icons.home_outlined,
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
            _buildTabItem(
              icon: Icons.healing,
              label: 'Consultant',
              isSelected: _selectedTab == 2,
              onTap: () {
                setState(() => _selectedTab = 2);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WellnessConsultantPage(),
                  ),
                );
              },
            ),
            _buildTabItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              isSelected: _selectedTab == 3,
              onTap: () {
                setState(() => _selectedTab = 3);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotPage()),
                );
              },
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

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF8B4C9B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A2B5C).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['message'],
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF4A2B5C),
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A2B5C).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF8B4C9B),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Consulting...',
              style: TextStyle(color: const Color(0xFF4A2B5C), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryInfo() {
    final categoryInfo = {
      'child_problems':
          'Get expert guidance on common childhood health issues, behavioral concerns, nutrition, and development using holistic wellness principles.',
      'depression':
          'Receive supportive mental health guidance with natural approaches, mindfulness techniques, and lifestyle strategies for emotional wellbeing.',
      'disability_children':
          'Find compassionate support and practical advice for caring for children with special needs and maximizing their potential.',
      'pregnancy_care':
          'Access comprehensive pregnancy wellness guidance covering nutrition, natural remedies, and holistic prenatal care.',
      'healthy_lifestyle':
          'Discover practical tips for balanced nutrition, fitness, stress management, and overall wellness optimization.',
      'general_health':
          'Get holistic health advice for common concerns, preventive care, and natural wellness approaches.',
    };

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              widget.categoryTitle,
              style: const TextStyle(
                color: Color(0xFF4A2B5C),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              categoryInfo[widget.category] ?? '',
              style: const TextStyle(color: Color(0xFF4A2B5C), fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    color: Color(0xFF8B4C9B),
                    fontWeight: FontWeight.w600,
                  ),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? _getFilledIcon(icon) : icon,
              size: 24,
              color: isSelected ? const Color(0xFF8B4C9B) : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? const Color(0xFF8B4C9B) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData outlinedIcon) {
    // Map outlined icons to their filled counterparts
    switch (outlinedIcon) {
      case Icons.home_outlined:
        return Icons.home;
      case Icons.water_drop:
        return Icons.water_drop;
      case Icons.healing:
        return Icons.healing;
      case Icons.chat_bubble_outline:
        return Icons.chat_bubble;
      default:
        return outlinedIcon;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
