import 'package:flutter/material.dart';
import 'dart:ui';
import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/voice_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/profile_page.dart';
import 'services/voice_assistant_service.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _voiceAnimationController;
  late Animation<double> _voiceScaleAnimation;
  late Animation<double> _voicePulseAnimation;
  final VoiceAssistantService _voiceService = VoiceAssistantService();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

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

  @override
  void dispose() {
    _voiceAnimationController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
    const HomePage(),
    const ExplorePage(),
    VoicePage(voiceService: _voiceService),
    const ChatbotPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      _voiceAnimationController.forward().then((_) {
        _voiceAnimationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _selectedIndex, children: _pages),
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

          // Floating Voice Button (unchanged)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            top: -5,
            child: AnimatedBuilder(
              animation: _voiceAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _selectedIndex == 2
                      ? _voicePulseAnimation.value
                      : _voiceScaleAnimation.value,
                  child: GestureDetector(
                    onTap: () => _onItemTapped(2),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _selectedIndex == 2
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
                                (_selectedIndex == 2
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
                        borderRadius: BorderRadius.circular(30),
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
                              _selectedIndex == 2
                                  ? Icons.graphic_eq_rounded
                                  : Icons.radio_button_checked_rounded,
                              color: Colors.white,
                              size: 20,
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
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? const Color(0xFF6C63FF).withOpacity(0.12)
              : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  width: 1,
                )
              : null,
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
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade600,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.2),
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
}
