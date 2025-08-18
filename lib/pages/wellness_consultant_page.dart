import 'package:flutter/material.dart';
import 'consultant_chatbot_page.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'chatbot_page.dart';
import 'voice_page.dart';

class WellnessConsultantPage extends StatefulWidget {
  const WellnessConsultantPage({Key? key}) : super(key: key);

  @override
  State<WellnessConsultantPage> createState() => _WellnessConsultantPageState();
}

class _WellnessConsultantPageState extends State<WellnessConsultantPage> {
  int _selectedTab = 2; // Set to 2 for Consultant tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dr. Swatantra AI'),
        backgroundColor: const Color(0xFF4A2B5C),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F1F8), // Light purple background like the image
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A2B5C).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.healing,
                          color: const Color(0xFF8B4C9B),
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Wellness Consultant',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF4A2B5C),
                                ),
                              ),
                              Text(
                                'Based on Dr. Swatantra Jain\'s expertise',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(
                                    0xFF4A2B5C,
                                  ).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Get personalized wellness advice for common health concerns. Select a category below to start your consultation.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories Header
              Text(
                'Select Your Concern',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A2B5C),
                ),
              ),

              const SizedBox(height: 16),

              // Category Cards Grid (ORIGINAL CARDS RESTORED)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2, // Increased from 1.1 to fix overflow
                children: [
                  _buildCategoryCard(
                    context,
                    'Child Problems',
                    Icons.child_care,
                    const Color(0xFF8B4C9B),
                    'Common issues in children\'s health and development',
                    'child_problems',
                  ),
                  _buildCategoryCard(
                    context,
                    'Depression',
                    Icons.psychology,
                    const Color(0xFF8B4C9B),
                    'Mental health support and guidance',
                    'depression',
                  ),
                  _buildCategoryCard(
                    context,
                    'Disability in Children',
                    Icons.accessibility,
                    const Color(0xFF8B4C9B),
                    'Special care for children with disabilities',
                    'disability_children',
                  ),
                  _buildCategoryCard(
                    context,
                    'Pregnancy Care',
                    Icons.pregnant_woman,
                    const Color(0xFF8B4C9B),
                    'Prenatal and postnatal wellness guidance',
                    'pregnancy_care',
                  ),
                  _buildCategoryCard(
                    context,
                    'Healthy Lifestyle',
                    Icons.fitness_center,
                    const Color(0xFF8B4C9B),
                    'Diet, exercise and wellness tips',
                    'healthy_lifestyle',
                  ),
                  _buildCategoryCard(
                    context,
                    'General Health',
                    Icons.health_and_safety,
                    const Color(0xFF8B4C9B),
                    'Common health concerns and preventive care',
                    'general_health',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B4C9B).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF4A2B5C),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This AI consultant provides general wellness guidance based on holistic health principles. For serious medical conditions, please consult a qualified healthcare professional.',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF4A2B5C).withOpacity(0.8),
                          height: 1.3,
                        ),
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
      bottomNavigationBar: Container(
        width: double.infinity,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                    MaterialPageRoute(
                      builder: (context) => const ExplorePage(),
                    ),
                  );
                },
              ),
              _buildTabItem(
                icon: Icons.healing,
                label: 'Consultant',
                isSelected: _selectedTab == 2,
                onTap: () => setState(() => _selectedTab = 2),
              ),
              _buildTabItem(
                icon: Icons.mic_outlined,
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
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isSelected: _selectedTab == 3,
                onTap: () {
                  setState(() => _selectedTab = 3);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatbotPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    String categoryId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ConsultantChatbotPage(
                  category: categoryId,
                  categoryTitle: title,
                  categoryColor: color,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
}
