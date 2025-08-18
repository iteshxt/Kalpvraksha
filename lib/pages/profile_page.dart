import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../pages/welcome_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Get user's joined date
  String _getJoinedDate() {
    final user = _authService.currentUser;
    if (user != null && user.metadata.creationTime != null) {
      final joinDate = user.metadata.creationTime!;
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[joinDate.month - 1]} ${joinDate.year}';
    }
    return 'Recently';
  }

  // Get last sign in date
  String _getLastSignIn() {
    final user = _authService.currentUser;
    if (user != null && user.metadata.lastSignInTime != null) {
      final lastSignIn = user.metadata.lastSignInTime!;
      final now = DateTime.now();
      final difference = now.difference(lastSignIn);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    }
    return 'Recently';
  }

  // Get user verification status
  bool _isEmailVerified() {
    final user = _authService.currentUser;
    return user?.emailVerified ?? false;
  }

  // Get user's display name
  String _getUserName() {
    final user = _authService.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      }
      if (user.email != null) {
        return user.email!.split('@').first;
      }
      if (user.isAnonymous) {
        return 'Guest User';
      }
    }
    return 'Unknown User';
  }

  // Get user's email
  String _getUserEmail() {
    final user = _authService.currentUser;
    if (user != null && user.email != null) {
      return user.email!;
    }
    return 'No email available';
  }

  // Check if user is signed in with Google
  bool _isGoogleUser() {
    final user = _authService.currentUser;
    if (user != null) {
      for (var provider in user.providerData) {
        if (provider.providerId == 'google.com') {
          return true;
        }
      }
    }
    return false;
  }

  // Get profile image URL
  String? _getProfileImageUrl() {
    final user = _authService.currentUser;
    if (user != null && user.photoURL != null) {
      return user.photoURL;
    }
    return null;
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  // Show logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: const Color(0xFF4A2B5C),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: const Color(0xFF4A2B5C).withOpacity(0.8)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2B5C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to sign out. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGoogleUser = _isGoogleUser();
    final profileImageUrl = _getProfileImageUrl();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1F8),
      body: Column(
        children: [
          // Header section with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF4A2B5C), const Color(0xFF8B4C9B)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 48), // To balance the row
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Profile picture section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildProfileImage(
                                isGoogleUser,
                                profileImageUrl,
                              ),
                            ),
                          ),
                          if (!isGoogleUser)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF8B4C9B),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Color(0xFF8B4C9B),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User name
                    Center(
                      child: Text(
                        _getUserName(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User email
                    Center(
                      child: Text(
                        _getUserEmail(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // User Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Member Since',
                          _getJoinedDate(),
                          Icons.calendar_today,
                          const Color(0xFF4A2B5C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Last Active',
                          _getLastSignIn(),
                          Icons.access_time,
                          const Color(0xFF8B4C9B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Account Information Section
                  _buildSectionHeader('Account Information'),
                  const SizedBox(height: 12),

                  // Account type indicator
                  _buildInfoCard(
                    title: 'Account Type',
                    subtitle: isGoogleUser ? 'Google Account' : 'Local Account',
                    icon: isGoogleUser ? Icons.g_mobiledata : Icons.person,
                    trailing: _buildStatusBadge(
                      isGoogleUser ? 'Verified' : 'Local',
                      isGoogleUser ? Colors.green : Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Email verification status
                  _buildInfoCard(
                    title: 'Email Status',
                    subtitle: _getUserEmail(),
                    icon: Icons.email,
                    trailing: _buildStatusBadge(
                      _isEmailVerified() ? 'Verified' : 'Unverified',
                      _isEmailVerified() ? Colors.green : Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Settings Section
                  _buildSectionHeader('Settings & Preferences'),
                  const SizedBox(height: 12),

                  // Profile picture setting (only for non-Google users)
                  if (!isGoogleUser) ...[
                    _buildSettingCard(
                      title: 'Profile Picture',
                      subtitle: 'Upload or change your profile picture',
                      icon: Icons.photo_camera,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Wellness Journey
                  _buildSettingCard(
                    title: 'Wellness Journey',
                    subtitle: 'Track your progress and achievements',
                    icon: Icons.timeline,
                    onTap: () {
                      // TODO: Navigate to wellness journey page
                    },
                  ),

                  const SizedBox(height: 12),

                  // Notifications
                  _buildSettingCard(
                    title: 'Notifications',
                    subtitle: 'Manage your notification preferences',
                    icon: Icons.notifications,
                    onTap: () {
                      // TODO: Navigate to notifications settings
                    },
                  ),

                  const SizedBox(height: 12),

                  // Privacy & Security
                  _buildSettingCard(
                    title: 'Privacy & Security',
                    subtitle: 'Manage your privacy settings',
                    icon: Icons.security,
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),

                  const SizedBox(height: 30),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _showLogoutDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(bool isGoogleUser, String? profileImageUrl) {
    if (isGoogleUser && profileImageUrl != null) {
      // Show Google profile image
      return Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8B4C9B),
              ),
            ),
          );
        },
      );
    } else if (_profileImage != null) {
      // Show locally picked image
      return Image.file(_profileImage!, fit: BoxFit.cover);
    } else {
      // Show default avatar
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4A2B5C), const Color(0xFF8B4C9B)],
        ),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 60),
    );
  }

  // Professional helper widgets
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A2B5C),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A2B5C).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4C9B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF8B4C9B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF4A2B5C).withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A2B5C),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A2B5C).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF8B4C9B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF8B4C9B), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A2B5C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF4A2B5C).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF8B4C9B).withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
