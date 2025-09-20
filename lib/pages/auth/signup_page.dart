import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../main_navigation.dart';
import 'login_page.dart';
import 'google_user_details_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';

  Future<void> _signUpWithEmail() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print("🚀 Starting registration for: ${_emailController.text.trim()}");
      final result = await _authService.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        // Update the user's display name using robust method
        print("🔄 Setting display name to: ${_nameController.text.trim()}");
        await _authService.updateUserDisplayName(_nameController.text.trim());
        print("✅ Sign-up successful!");

        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      }
    } catch (e) {
      print("❌ Sign-up error: ${e.toString()}");

      // Check if this is a known Firebase plugin type casting error
      bool isTypeCastingError =
          e.toString().contains("List<Object?>") &&
          (e.toString().contains("PigeonUserDetails") ||
              e.toString().contains("PigeonUserInfo") ||
              e.toString().contains("subtype"));

      if (isTypeCastingError) {
        print("🔧 Handling Firebase plugin type casting error in sign-up page");
      }

      // Check if user was actually created despite the error
      await Future.delayed(const Duration(milliseconds: 500));
      final currentUser = _authService.currentUser;

      if (currentUser != null &&
          currentUser.email == _emailController.text.trim()) {
        print("✅ User found despite error - proceeding with sign-up");

        try {
          // Update the user's display name
          await currentUser.updateDisplayName(_nameController.text.trim());
        } catch (nameError) {
          print(
            "⚠️ Display name update error (non-critical): ${nameError.toString()}",
          );
          // Continue anyway - display name update is not critical
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
          return;
        }
      }

      // Only show error if user wasn't actually created AND it's not a type casting error
      if (!isTypeCastingError) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      } else {
        print(
          "🔧 Type casting error suppressed - user should be created successfully",
        );
        // For type casting errors, show a generic message or try to proceed
        setState(() {
          _errorMessage = 'Please wait, completing registration...';
        });

        // Try once more to check if user was created after a longer delay
        await Future.delayed(const Duration(milliseconds: 1500));
        final retryUser = _authService.currentUser;

        if (retryUser != null &&
            retryUser.email == _emailController.text.trim()) {
          print("✅ User confirmed on retry - proceeding");

          try {
            await retryUser.updateDisplayName(_nameController.text.trim());
          } catch (nameError) {
            print(
              "⚠️ Display name update error on retry (non-critical): ${nameError.toString()}",
            );
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
            );
            return;
          }
        } else {
          setState(() {
            _errorMessage = 'Registration may have failed. Please try again.';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _authService.signInWithGoogleEnhanced();
      if (result != null) {
        print("✅ Google sign-up successful!");

        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 100));

          if (result['isNewUser'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GoogleUserDetailsPage(user: result['user']),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigation()),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Changed to match app theme
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16), // Reduced from 40 to 20
              // Main Card Container with enhanced lighting
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24), // Reduced from 32 to 24
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    // Soft outer glow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                      spreadRadius: 5,
                    ),
                    // Inner light border effect
                    // The 'inset' property is not a valid parameter for BoxShadow
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                      spreadRadius: -10,
                    ),
                    // Subtle directional light
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 60,
                      offset: const Offset(-20, -20),
                      spreadRadius: 10,
                    ),
                    // Bottom shadow for depth
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black87, // Changed to match app theme
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.15,
                            ), // Updated shadow
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Welcome Text
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Changed to match app theme
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Sign Up, its free',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54, // Changed to match app theme
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(
                            0.2,
                          ), // Changed to match app theme
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87, // Changed to match app theme
                        ),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: const TextStyle(
                            color: Colors.black54, // Changed to match app theme
                            fontSize: 14,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.05,
                              ), // Changed to match app theme
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color:
                                  Colors.black87, // Changed to match app theme
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(
                            0.2,
                          ), // Changed to match app theme
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87, // Changed to match app theme
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(
                            color: Colors.black54, // Changed to match app theme
                            fontSize: 14,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.05,
                              ), // Changed to match app theme
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              color:
                                  Colors.black87, // Changed to match app theme
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(
                            0.2,
                          ), // Changed to match app theme
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87, // Changed to match app theme
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            color: Colors.black54, // Changed to match app theme
                            fontSize: 14,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.05,
                              ), // Changed to match app theme
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color:
                                  Colors.black87, // Changed to match app theme
                              size: 20,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color:
                                  Colors.black54, // Changed to match app theme
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(
                            0.2,
                          ), // Changed to match app theme
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87, // Changed to match app theme
                        ),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(
                            color: Colors.black54, // Changed to match app theme
                            fontSize: 14,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.05,
                              ), // Changed to match app theme
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color:
                                  Colors.black87, // Changed to match app theme
                              size: 20,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color:
                                  Colors.black54, // Changed to match app theme
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUpWithEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black87, // Changed to match app theme
                          foregroundColor: Colors.white,
                          elevation: 0, // Removed shadow to match app theme
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(
                              0.2,
                            ), // Changed to match app theme
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color:
                                  Colors.black54, // Changed to match app theme
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(
                              0.2,
                            ), // Changed to match app theme
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Google Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _signUpWithGoogle,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey.withOpacity(
                              0.2,
                            ), // Changed to match app theme
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google_icon.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors
                                      .black87, // Changed to match app theme
                                  size: 24,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors
                                    .black87, // Changed to match app theme
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.black54, // Changed to match app theme
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color:
                                  Colors.black87, // Changed to match app theme
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
