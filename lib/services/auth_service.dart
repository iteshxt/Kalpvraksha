import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

// Simple wrapper to handle plugin type casting issues
class SimpleUserCredential implements UserCredential {
  @override
  final User? user;

  @override
  final AdditionalUserInfo? additionalUserInfo = null;

  @override
  final AuthCredential? credential = null;

  SimpleUserCredential(this.user);
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Check if user is anonymous
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  // Sign in anonymously (for "Try AI Consultant" feature)
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result;
    } catch (e) {
      return null;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      // Special handling for the type casting error from Flutter plugin
      if (e.toString().contains("List<Object?>") &&
          e.toString().contains("PigeonUserDetails")) {
        // Wait a bit for Firebase to update
        await Future.delayed(const Duration(milliseconds: 800));

        // Check if user was actually created
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          // Return a working UserCredential wrapper
          return SimpleUserCredential(currentUser);
        } else {
          throw Exception("Registration failed: ${e.toString()}");
        }
      }

      // For other errors, check if user was still created
      await Future.delayed(const Duration(milliseconds: 500));
      if (_auth.currentUser != null && _auth.currentUser!.email == email) {
        return SimpleUserCredential(_auth.currentUser!);
      }

      throw e;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print("Attempting to sign in user: $email");
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Signed in successfully: ${result.user?.email}");
      return result;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Exception during sign-in: ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("Sign-in error: $e");

      // Special handling for the type casting error from Flutter plugin
      if (e.toString().contains("List<Object?>") &&
          e.toString().contains("PigeonUserDetails")) {
        print(
          "Detected Flutter plugin type casting error during sign-in - checking auth state",
        );

        // Wait a bit for Firebase to update
        await Future.delayed(const Duration(milliseconds: 800));

        // Check if user was actually signed in
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print("✅ User was signed in successfully despite plugin error");
          print("   User ID: ${currentUser.uid}");
          print("   Email: ${currentUser.email}");

          // Return a working UserCredential wrapper
          return SimpleUserCredential(currentUser);
        } else {
          print("❌ User was not signed in - the error was genuine");
          throw Exception("Sign-in failed: ${e.toString()}");
        }
      }

      // For other errors, check if user was still signed in
      await Future.delayed(const Duration(milliseconds: 500));
      if (_auth.currentUser != null && _auth.currentUser!.email == email) {
        print("User was signed in successfully despite error");
        return SimpleUserCredential(_auth.currentUser!);
      }

      throw e;
    }
  }

  // Convert anonymous account to permanent account
  Future<UserCredential?> linkAnonymousWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      if (!isAnonymous) {
        throw Exception("User is not anonymous");
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      UserCredential result = await currentUser!.linkWithCredential(credential);
      print("Anonymous account linked successfully: ${result.user?.email}");
      return result;
    } catch (e) {
      print("Account linking error: $e");
      return null;
    }
  }

  // Google Sign-In method
  Future<Map<String, dynamic>?> signInWithGoogleEnhanced() async {
    try {
      print("Starting Google Sign-In...");

      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Google sign-in was cancelled by user");
        return null;
      }

      print("Google user obtained: ${googleUser.email}");

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Google credential created, attempting Firebase sign-in...");

      // Check if this is a new user by trying to fetch sign-in methods first
      bool isNewUser = false;
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(
          googleUser.email,
        );
        isNewUser = methods.isEmpty;
        print(
          "User ${isNewUser ? 'is new' : 'already exists'} for email: ${googleUser.email}",
        );
      } catch (e) {
        print("Could not check existing user status: $e");
        // Assume new user if we can't check
        isNewUser = true;
      }

      // Once signed in, return to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print("✅ Google sign-in successful!");
      print("   User ID: ${userCredential.user?.uid}");
      print("   Email: ${userCredential.user?.email}");
      print("   Display Name: ${userCredential.user?.displayName}");

      // Ensure display name is set correctly for existing users
      if (!isNewUser && userCredential.user != null) {
        String? currentDisplayName = userCredential.user!.displayName;
        String? googleDisplayName = googleUser.displayName;

        // If the current display name is empty or just the email,
        // and Google provides a display name, update it
        if ((currentDisplayName == null ||
                currentDisplayName.isEmpty ||
                currentDisplayName.contains('@')) &&
            googleDisplayName != null &&
            googleDisplayName.isNotEmpty) {
          try {
            await userCredential.user!.updateDisplayName(googleDisplayName);
            print("Updated display name to: $googleDisplayName");
          } catch (e) {
            print("Warning: Could not update display name: $e");
          }
        }
      }

      return {
        'userCredential': userCredential,
        'isNewUser': isNewUser,
        'googleDisplayName': googleUser.displayName,
      };
    } catch (e) {
      print("Google sign-in error: $e");

      // Enhanced error handling for common Google Sign-In issues
      if (e is PlatformException) {
        if (e.code == 'sign_in_failed' || e.code == 'network_error') {
          throw Exception(
            'Google Sign-In failed. Please check:\n'
            '1. Your internet connection\n'
            '2. Google Play Services is updated\n'
            '3. App is properly configured in Firebase Console',
          );
        } else if (e.code == 'sign_in_canceled') {
          throw Exception('Sign-in was canceled by the user');
        } else {
          throw Exception('Sign-in error: ${e.message ?? e.code}');
        }
      }

      // Check if user was actually signed in despite the error
      await Future.delayed(const Duration(milliseconds: 500));

      if (_auth.currentUser != null) {
        print("✅ Google user was signed in successfully despite error!");

        // Try to get Google user info for display name
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = googleSignIn.currentUser;

        return {
          'userCredential': SimpleUserCredential(_auth.currentUser!),
          'isNewUser': false, // Assume existing user for error recovery
          'googleDisplayName':
              googleUser?.displayName ?? _auth.currentUser!.displayName,
        };
      }

      throw e;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent to: $email");
      return true;
    } on FirebaseAuthException catch (e) {
      print("Password reset error: ${e.code} - ${e.message}");
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email address.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is invalid.');
      } else {
        throw Exception('Failed to send password reset email: ${e.message}');
      }
    } catch (e) {
      print("Password reset error: $e");
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Sign-out error: $e");
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      await currentUser?.delete();
      print("Account deleted successfully");
      return true;
    } catch (e) {
      print("Account deletion error: $e");
      return false;
    }
  }

  // Get error message from Firebase Auth Exception
  String getErrorMessage(dynamic error) {
    String errorString = error.toString();

    // Handle the specific type casting error
    if (errorString.contains(
      'type \'List<Object?>\' is not a subtype of type \'PigeonUserDetails?\'',
    )) {
      return 'Authentication completed successfully. Please check if you are signed in.';
    }

    // Handle Google Sign-In specific errors
    if (errorString.contains('Network error')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (errorString.contains('Google sign-in failed')) {
      return 'Google sign-in failed. Please try again.';
    }
    if (errorString.contains('sign_in_canceled') ||
        errorString.contains('sign_in_cancelled')) {
      return 'Google sign-in was cancelled.';
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-not-found':
          return 'No user found for this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';
        case 'invalid-credential':
          return 'The credential is invalid. Please try again.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled. Please contact support.';
        default:
          return error.message ?? 'An error occurred. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
