import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart'; // Correctly importing your detailed SignupPage

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isAnimating = false;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      'title': 'We all need someone\nto talk to',
      'subtitle': 'Sometimes',
      'description': '',
      'illustration': 'assets/counselling.png',
    },
    {
      'title': 'Love Yourself',
      'subtitle': '',
      'description':
          'You yourself, as much as anybody in the entire universe, deserve your love and affection.',
      'illustration': 'assets/slide3.png',
    },
    {
      'title': 'Find Your Balance',
      'subtitle': '',
      'description':
          'Start your journey towards mindfulness\nand discover the peace within yourself\nthrough guided meditation practices.',
      'illustration': 'assets/Mental.png',
    },
    {
      'title': 'We\'re here.',
      'subtitle': 'Find your path.',
      'description': '',
      'illustration': 'assets/slide4.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_isAnimating) return;

    if (_currentPage < onboardingPages.length - 1) {
      if (_currentPage == 0) {
        // First slide-up animation
        setState(() {
          _isAnimating = true;
          _currentPage = 1;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        });
      } else {
        // Subsequent horizontal slides
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Widget _buildOnboardingPageContent(Map<String, dynamic> data, int index) {
    bool isLastPage = index == onboardingPages.length - 1;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF5F0E8)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (!isLastPage)
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              if (isLastPage) const SizedBox(height: 40),
              Expanded(
                child: Column(
                  children: [
                    Column(
                      children: [
                        if (data['subtitle'] != null &&
                            data['subtitle']!.isNotEmpty)
                          Text(
                            data['subtitle']!,
                            style: TextStyle(
                              fontSize: isLastPage ? 18 : 16,
                              color: const Color(0xFF999999),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        if (data['subtitle'] != null &&
                            data['subtitle']!.isNotEmpty)
                          SizedBox(height: isLastPage ? 12 : 8),
                        if (data['title'] != null && data['title']!.isNotEmpty)
                          Text(
                            data['title']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isLastPage ? 42 : 32,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C2C2C),
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: isLastPage ? 50 : 40),
                    Expanded(
                      child: Center(
                        child: data['illustration'] != null
                            ? Image.asset(
                                data['illustration']!,
                                width: MediaQuery.of(context).size.width *
                                    (isLastPage ? 0.8 : 1.1),
                                height: MediaQuery.of(context).size.height *
                                    (isLastPage ? 0.35 : 0.5),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width *
                                        (isLastPage ? 0.8 : 1.1),
                                    height: MediaQuery.of(context).size.height *
                                        (isLastPage ? 0.35 : 0.5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Image not found\n${data['illustration']}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : const SizedBox(),
                      ),
                    ),
                    if (data['description'] != null &&
                        data['description']!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          data['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                            height: 1.6,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    if (isLastPage) ...[
                      const SizedBox(height: 30),
                      _buildAuthButtons(),
                      const SizedBox(height: 30),
                    ] else
                      const SizedBox(height: 20),
                  ],
                ),
              ),
              if (!isLastPage) ...[
                Center(
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2C),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingPages.length,
                  (indicatorIndex) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == indicatorIndex ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == indicatorIndex
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFD0D0D0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2C2C),
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0x30000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'GET STARTED',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
        // Removed the SIGN UP button and its SizedBox
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: _currentPage == 0 ? 0 : -MediaQuery.of(context).size.height,
            bottom: _currentPage == 0 ? 0 : MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            child: _buildOnboardingPageContent(onboardingPages[0], 0),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: _currentPage > 0 ? 0 : MediaQuery.of(context).size.height,
            bottom: _currentPage > 0 ? 0 : -MediaQuery.of(context).size.height,
            left: 0,
            right: 0,
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingPages.length - 1,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page + 1;
                });
              },
              itemBuilder: (context, index) {
                return _buildOnboardingPageContent(
                    onboardingPages[index + 1], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}