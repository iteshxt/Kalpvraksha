import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_page.dart';

class GoogleUserDetailsPage extends StatefulWidget {
  final User user;
  final String? googleDisplayName;

  const GoogleUserDetailsPage({
    super.key,
    required this.user,
    this.googleDisplayName,
  });

  @override
  State<GoogleUserDetailsPage> createState() => _GoogleUserDetailsPageState();
}

class _GoogleUserDetailsPageState extends State<GoogleUserDetailsPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Pre-fill names if Google provided a display name
    if (widget.googleDisplayName != null &&
        widget.googleDisplayName!.isNotEmpty) {
      final nameParts = widget.googleDisplayName!.split(' ');
      if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          _lastNameController.text = nameParts.sublist(1).join(' ');
        }
      }
    }
  }

  Future<void> _completeProfile() async {
    // Validation
    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your first name');
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your last name');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your phone number');
      return;
    }

    // Basic phone number validation
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
      setState(() => _errorMessage = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Update display name with the entered information
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      await widget.user.updateDisplayName(fullName);

      // Store additional user data in Firebase (you can extend this to use Firestore)
      // For now, we'll just use the display name
      print("Profile completed for: $fullName");
      print("Phone: ${_phoneController.text.trim()}");

      if (mounted) {
        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print("Error completing profile: $e");
      setState(
        () => _errorMessage = 'Failed to complete profile. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Title Section
              Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF4A2B5C),
                  fontFamily: 'Serif',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide some additional information to complete your account setup',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF4A2B5C).withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // User Email Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B4C9B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B4C9B).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined, color: const Color(0xFF8B4C9B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Signed in as: ${widget.user.email}',
                        style: TextStyle(
                          color: const Color(0xFF4A2B5C),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Name Fields
              Row(
                children: [
                  // First Name Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A2B5C).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _firstNameController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          color: Color(0xFF4A2B5C),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          hintStyle: TextStyle(
                            color: const Color(0xFF4A2B5C).withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: const Color(0xFF8B4C9B),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Last Name Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A2B5C).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          color: Color(0xFF4A2B5C),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          hintStyle: TextStyle(
                            color: const Color(0xFF4A2B5C).withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: const Color(0xFF8B4C9B),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Phone Number Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A2B5C).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: Color(0xFF4A2B5C),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(
                      color: const Color(0xFF4A2B5C).withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: const Color(0xFF8B4C9B),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Complete Profile Button
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2B5C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Complete Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Skip Button (optional)
              TextButton(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          // Navigate directly to home page if user wants to skip
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: const Color(0xFF8B4C9B),
                    fontSize: 14,
                  ),
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
