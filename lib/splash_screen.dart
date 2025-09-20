import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'auth_wrapper.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _leafController;
  late AnimationController _illustrationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _leafAnimation;
  late Animation<double> _illustrationAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar to transparent with dark icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _leafController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _illustrationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _leafAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _leafController, curve: Curves.easeInOut),
    );

    _illustrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _illustrationController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();

    // Navigate to main app after delay
    Timer(const Duration(milliseconds: 3500), () {
      _navigateToApp();
    });
  }

  void _startAnimations() async {
    // Start fade animation immediately
    _fadeController.forward();

    // Start scale animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();

    // Start pulse animation
    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);

    // Start leaf animation
    await Future.delayed(const Duration(milliseconds: 200));
    _leafController.forward();

    // Start illustration animation
    await Future.delayed(const Duration(milliseconds: 800));
    _illustrationController.forward();
  }

  void _navigateToApp() {
    // Navigate to AuthWrapper which will handle authentication state
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthWrapper(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _leafController.dispose();
    _illustrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Enhanced gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8F9FF), Color(0xFFF5F7FF)],
              ),
            ),
          ),

          // Animated background illustrations
          ...List.generate(
            8,
            (index) => AnimatedBuilder(
              animation: _illustrationAnimation,
              builder: (context, child) {
                final delay = index * 0.15;
                final animationValue = (_illustrationAnimation.value - delay)
                    .clamp(0.0, 1.0);
                return Positioned(
                  left:
                      30.0 +
                      (index * 60.0) % (MediaQuery.of(context).size.width - 60),
                  top:
                      80.0 +
                      (index * 100.0) %
                          (MediaQuery.of(context).size.height - 160),
                  child: Opacity(
                    opacity: (0.03 + (index % 4) * 0.015) * animationValue,
                    child: Transform.scale(
                      scale: 0.3 + (animationValue * 0.7),
                      child: Transform.rotate(
                        angle: (index * 0.5) + (animationValue * 0.3),
                        child: _buildFloatingIllustration(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating subtle elements (existing)
          ...List.generate(
            6,
            (index) => AnimatedBuilder(
              animation: _leafAnimation,
              builder: (context, child) {
                final delay = index * 0.2;
                final animationValue = (_leafAnimation.value - delay).clamp(
                  0.0,
                  1.0,
                );
                return Positioned(
                  left:
                      50.0 + (index * 80.0) % MediaQuery.of(context).size.width,
                  top:
                      100.0 +
                      (index * 120.0) %
                          (MediaQuery.of(context).size.height - 200),
                  child: Opacity(
                    opacity: (0.05 + (index % 3) * 0.02) * animationValue,
                    child: Transform.scale(
                      scale: 0.5 + (animationValue * 0.5),
                      child: Container(
                        width: 8 + (index % 3) * 4,
                        height: 16 + (index % 3) * 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF667EEA).withOpacity(0.6),
                              Color(0xFF764BA2).withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decorative top illustration
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _illustrationAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _illustrationAnimation.value * 0.1,
                        child: Transform.scale(
                          scale: 0.8 + (_illustrationAnimation.value * 0.2),
                          child: Container(
                            width: 200,
                            height: 80,
                            child: CustomPaint(
                              painter: WellnessIllustrationPainter(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Enhanced Animated Logo/Icon
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF667EEA,
                                      ).withOpacity(0.3),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFF764BA2,
                                      ).withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Inner glow effect
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.eco,
                                      color: Colors.white,
                                      size: 55,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 50),

                // Enhanced App Name with better styling
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ).createShader(bounds),
                              child: const Text(
                                'Dr.Swatantra AI',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: 3.0,
                                  fontFamily: 'Serif',
                                ),
                              ),
                            ),
                            // Subtle underline decoration
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              height: 2,
                              width: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Enhanced Tagline
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _leafAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _leafAnimation.value,
                        child: const Text(
                          'Your Wellness Journey Begins',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF667EEA),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 70),

                // Enhanced loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _leafAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _leafAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF667EEA),
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
          ),

          // Enhanced bottom decorative elements
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _illustrationAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _illustrationAnimation.value * 0.4,
                    child: Center(
                      child: Column(
                        children: [
                          // Decorative dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(
                                        0xFF667EEA,
                                      ).withOpacity(0.3 + (index * 0.2)),
                                      Color(
                                        0xFF764BA2,
                                      ).withOpacity(0.2 + (index * 0.15)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Wellness mantra
                          Text(
                            '✦ Heal • Grow • Transform ✦',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF667EEA).withOpacity(0.7),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIllustration(int index) {
    final icons = [
      Icons.local_florist,
      Icons.spa,
      Icons.self_improvement,
      Icons.healing,
      Icons.nature,
      Icons.favorite,
      Icons.brightness_7,
      Icons.water_drop,
    ];

    return Container(
      width: 40 + (index % 3) * 10,
      height: 40 + (index % 3) * 10,
      decoration: BoxDecoration(
        color: Color(0xFF667EEA).withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Color(0xFF764BA2).withOpacity(0.1), width: 1),
      ),
      child: Icon(
        icons[index % icons.length],
        size: 20 + (index % 3) * 5,
        color: Color(0xFF667EEA).withOpacity(0.3),
      ),
    );
  }
}

// Custom painter for wellness illustrations
class WellnessIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw flowing waves
    final path = Path();
    path.moveTo(0, size.height * 0.5);

    for (double x = 0; x <= size.width; x += 10) {
      final y =
          size.height * 0.5 + 15 * math.sin((x / size.width) * 4 * math.pi);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw second wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);

    for (double x = 0; x <= size.width; x += 10) {
      final y =
          size.height * 0.6 +
          10 * math.sin((x / size.width) * 6 * math.pi + math.pi / 3);
      path2.lineTo(x, y);
    }

    paint.strokeWidth = 1;
    paint.shader = LinearGradient(
      colors: [
        Color(0xFF667EEA).withOpacity(0.5),
        Color(0xFF764BA2).withOpacity(0.3),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Add this import at the top
