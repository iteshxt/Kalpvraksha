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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // ✅ removes back button
        toolbarHeight: 0, // ✅ removes AppBar extra height
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Dr. Swatantra\'s ',
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

              // Disclaimer - moved here below the heading
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
                children: [
                  _buildModernCategoryCard(
                    context,
                    'Child Problems',
                    Icons.child_care,
                    Color(0xFFFFF2E6),
                    Color(0xFFFF9500),
                    'child_problems',
                  ),
                  _buildModernCategoryCard(
                    context,
                    'Depression',
                    Icons.psychology,
                    Color(0xFFE6F7FF),
                    Color(0xFF1890FF),
                    'depression',
                  ),
                  _buildModernCategoryCard(
                    context,
                    'Disability Care',
                    Icons.accessibility,
                    Color(0xFFF6FFED),
                    Color(0xFF52C41A),
                    'disability_children',
                  ),
                  _buildModernCategoryCard(
                    context,
                    'Pregnancy Care',
                    Icons.pregnant_woman,
                    Color(0xFFFFF0F6),
                    Color(0xFFEB2F96),
                    'pregnancy_care',
                  ),
                  _buildModernCategoryCard(
                    context,
                    'Lifestyle',
                    Icons.fitness_center,
                    Color(0xFFF9F0FF),
                    Color(0xFF722ED1),
                    'healthy_lifestyle',
                  ),
                  _buildModernCategoryCard(
                    context,
                    'General Health',
                    Icons.health_and_safety,
                    Color(0xFFE6FFFB),
                    Color(0xFF13C2C2),
                    'general_health',
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
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
            // Consultant icon to the right of Voice
            _buildTabItem(
              icon: Icons.healing,
              label: 'Consultant',
              isSelected: _selectedTab == 2,
              onTap: () => setState(() => _selectedTab = 2),
            ),
            _buildTabItem(
              icon: Icons.chat_bubble,
              label: 'Chat',
              isSelected: _selectedTab == 3,
              onTap: () {
                setState(() => _selectedTab = 3);
                Navigator.push(
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
}
