import 'dart:async';
import 'package:flutter/material.dart';
import 'package:muktiya_new/pages/chatbot_page.dart';
import 'package:muktiya_new/pages/explore_page.dart';
import 'package:muktiya_new/pages/wellness_consultant_page.dart';
import 'package:muktiya_new/pages/voice_page.dart';
import 'package:muktiya_new/pages/profile_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  Timer? _greetingTimer;
  int _currentPage = 0;
  int _selectedTab = 1; // Track selected tab
  final AuthService _authService = AuthService();

  // Method to get time-based greeting
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Method to get user's display name
  String _getUserName() {
    final user = _authService.currentUser;
    if (user != null) {
      // Check if user has a display name
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        String displayName = user.displayName!.trim();
        
        // If display name contains '@', it's likely an email, extract name from it
        if (displayName.contains('@')) {
          String emailName = displayName.split('@').first;
          return emailName[0].toUpperCase() + emailName.substring(1);
        }
        
        // Otherwise, get the first name from the display name
        String firstName = displayName.split(' ').first.trim();
        
        // Ensure first letter is capitalized
        if (firstName.isNotEmpty) {
          return firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
        }
      }
      
      // If no proper display name, extract name from email
      if (user.email != null) {
        String emailName = user.email!.split('@').first;
        // Capitalize first letter and convert rest to lowercase
        if (emailName.isNotEmpty) {
          return emailName[0].toUpperCase() + emailName.substring(1).toLowerCase();
        }
      }
      
      // For anonymous users
      if (user.isAnonymous) {
        return 'Guest';
      }
    }
    return 'Friend';
  }

  // Method to get full greeting text
  String _getFullGreeting() {
    final greeting = _getTimeBasedGreeting();
    final userName = _getUserName();
    return '$greeting, $userName!';
  }

  // Method to get personalized subtitle based on time and user status
  String _getPersonalizedSubtitle() {
    final hour = DateTime.now().hour;
    final user = _authService.currentUser;

    if (user != null && user.isAnonymous) {
      return 'Welcome to your wellness journey, Guest!';
    }

    if (hour >= 5 && hour < 12) {
      return 'Ready to start your day with wellness?';
    } else if (hour >= 12 && hour < 17) {
      return 'Hope your day is going well!';
    } else if (hour >= 17 && hour < 21) {
      return 'Time to unwind and relax.';
    } else {
      return 'Take a moment for yourself tonight.';
    }
  }

  @override
  void initState() {
    super.initState();
    // Start auto-sliding for quotes
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

    // Start greeting refresh timer (every minute to update time-based greetings)
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      if (mounted) {
        setState(() {}); // Refresh the greeting
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _greetingTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  final List<String> quotes = [
    "The greatest healing therapy is friendship and love.",
    "Healing takes courage, and we all have courage.",
    "The wound is the place where the Light enters you.",
  ];

  final List<String> authors = ["Hubert H. Humphrey", "Maya Angelou", "Rumi"];

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
                  Color(0xFFF0E6FF), // Light lavender
                  Color(0xFFE6D9FF), // Slightly darker lavender
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
                                Icon(
                                  Icons.sunny,
                                  size: 20,
                                  color: Color(0xFF4A2B5C),
                                ),
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
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.person,
                                color: Color(0xFF4A2B5C),
                              ),
                              tooltip: 'Profile',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _getFullGreeting(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF4A2B5C),
                            fontFamily: 'Serif',
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getPersonalizedSubtitle(),
                          style: TextStyle(
                            color: Color(0xFF4A2B5C).withOpacity(0.6),
                            fontSize: 16,
                            height: 1.3,
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(
                                        0xFF4A2B5C,
                                      ).withOpacity(0.05),
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
                                        color: Color(
                                          0xFF4A2B5C,
                                        ).withOpacity(0.6),
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
          Expanded(child: Container(color: Colors.white)),
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
                onTap: () {
                  setState(() => _selectedTab = 2);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WellnessConsultantPage(),
                    ),
                  );
                },
              ),
              _buildTabItem(
                icon: Icons.mic_outlined,
                label: 'Voice',
                isSelected: _selectedTab == 4,
                onTap: () {
                  setState(() => _selectedTab = 4);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoicePage(),
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
      case Icons.healing:
        return Icons.healing;
      case Icons.mic_outlined:
        return Icons.mic;
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
    final paint =
        Paint()
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
