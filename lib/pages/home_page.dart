import 'dart:async';
import 'package:flutter/material.dart';
import 'package:muktiya_new/pages/chatbot_page.dart';
import 'package:muktiya_new/pages/settings_page.dart';
import 'package:muktiya_new/pages/explore_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  int _selectedTab = 1; // Add this line to track selected tab

  @override
  void initState() {
    super.initState();
    // Start auto-sliding
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < quotes.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  final List<String> quotes = [
    "The greatest healing therapy is friendship and love.",
    "Healing takes courage, and we all have courage.",
    "The wound is the place where the Light enters you.",
  ];

  final List<String> authors = [
    "Hubert H. Humphrey",
    "Maya Angelou",
    "Rumi",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0E6FF),  // Light lavender
                  Color(0xFFE6D9FF),  // Slightly darker lavender
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.elliptical(200, 60),
              ),
            ),
            child: Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.sunny, size: 20, color: Color(0xFF4A2B5C)),
                                const SizedBox(width: 8),
                                Text(
                                  'Kalpvraksha',
                                  style: TextStyle(
                                    color: Color(0xFF4A2B5C),
                                    fontSize: 16,
                                    fontFamily: 'Serif',
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.notifications, color: Color(0xFF4A2B5C)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Good Morning!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF4A2B5C),
                            fontFamily: 'Serif',
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '',
                          style: TextStyle(
                            color: Color(0xFF4A2B5C).withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Dr. Swatantra Jain image with biographical text
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image in oval shape
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF8B4C9B).withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'hero.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $error');
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Biographical text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dr. Swatantra Jain",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2B5C),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Chairman of the Great Chyren Welfare Council and the International Human Rights Organization Indore, has spent over 20 years providing free natural homeopathic care, public-health initiatives, and human-rights advocacy through his Muktiya Trust.",
                                    style: TextStyle(
                                      color: Color(0xFF4A2B5C).withOpacity(0.8),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        // Quote slider
                        SizedBox(
                          height: 120,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: quotes.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width - 64,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF4A2B5C).withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quotes[index],
                                      style: TextStyle(
                                        color: Color(0xFF4A2B5C),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      authors[index],
                                      style: TextStyle(
                                        color: Color(0xFF4A2B5C).withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rest of the white background content will go here
          Expanded(
            child: Container(
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
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
                onTap: () => setState(() => _selectedTab = 1),
              ),
              _buildTabItem(
                icon: Icons.water_drop,
                label: 'Explore',
                isSelected: _selectedTab == 0,
                onTap: () {
                  setState(() => _selectedTab = 0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExplorePage()),
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
                    MaterialPageRoute(builder: (context) => const ChatbotPage()),
                  );
                },
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? _getFilledIcon(icon) : icon,
              color: isSelected ? const Color(0xFF8B4C9B) : Colors.grey,
              size: 24,
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
      case Icons.chat_bubble_outline:
        return Icons.chat_bubble;
      default:
        return outlinedIcon;
    }
  }
}

class CurvedLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 6; i++) {
      final path = Path();
      path.moveTo(0, size.height * (0.2 + i * 0.1));
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * (0.25 + i * 0.1),
        size.width,
        size.height * (0.2 + i * 0.1),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}