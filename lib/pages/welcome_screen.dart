import 'package:flutter/material.dart';
import 'package:muktiya_new/pages/home_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF3E5FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Text(
                  'Welcome to\nKalpvraksha!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF4A2B5C),
                    fontFamily: 'Serif',
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Personalized\nWellness Trainer.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A2B5C).withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step towards\nTransformation',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A2B5C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            7,
                            (index) => Container(
                              width: 30,
                              height: 50.0 + (index * 15),
                              decoration: BoxDecoration(
                                color: Color(0xFF8B4C9B).withOpacity(0.3 + (index * 0.1)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A2B5C),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
}