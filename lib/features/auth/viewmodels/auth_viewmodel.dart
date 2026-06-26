import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/guide_profile_service.dart';
import '../../../data/models/auth_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/tourist_profile_service.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/services/push_notification_service.dart';

/// Navigation targets emitted after auth operations.
enum AuthNavTarget {
  none,
  emailVerificationPending,
  profileCompletion,
  profileVerification,
  home,
  guideHome,
}

/// ViewModel for Login and Sign-Up screens.
///
/// Uses [AuthService] for all API calls and [TokenStorage] for persistence.
/// Emits [AuthNavTarget] after successful login / registration so the view
/// can navigate without any business logic.
class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  AuthNavTarget navTarget = AuthNavTarget.none;

  /// Carries the registered email for the EmailVerificationPendingView.
  String lastRegisteredEmail = '';

  /// Carries the guide's verification status for ProfileVerificationScreen.
  String lastVerificationStatus = 'NotSubmitted';

  /// Carries the rejection reason if the guide was rejected.
  String? lastRejectionReason;

  void consumeNavTarget() {
    navTarget = AuthNavTarget.none;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // ── Sign-up ──────────────────────────────────────────────────────────────────

  Future<void> signup({
    required String role,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
  }) async {
    errorMessage = null;
    notifyListeners();

    // ── Client-side validation ────────────────────────────────────────────────
    if (username.trim().isEmpty) {
      errorMessage = 'Please enter a username';
      notifyListeners();
      return;
    }
    if (username.trim().length < 3) {
      errorMessage = 'Username must be at least 3 characters';
      notifyListeners();
      return;
    }
    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email';
      notifyListeners();
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
      errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      errorMessage = 'Please enter a password';
      notifyListeners();
      return;
    }
    if (password.length < 8) {
      errorMessage = 'Password must be at least 8 characters';
      notifyListeners();
      return;
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(password)) {
      errorMessage = 'Password must contain at least one digit';
      notifyListeners();
      return;
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      errorMessage = 'Password must contain at least one lowercase letter';
      notifyListeners();
      return;
    }
    if (password != confirmPassword) {
      errorMessage = 'Passwords do not match';
      notifyListeners();
      return;
    }
    if (!termsAccepted) {
      errorMessage = 'Please accept the terms and conditions';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await AuthService.instance.register(
        RegisterRequest(
          username: username.trim(),
          email: email.trim(),
          password: password,
          role: role, // 'tourist' or 'guide'
        ),
      );

      // Registration succeeded.
      // Backend requires email verification before login is allowed.
      // Navigate to the "check your inbox" screen for ALL roles.
      lastRegisteredEmail = email.trim();
      navTarget = AuthNavTarget.emailVerificationPending;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    errorMessage = null;
    notifyListeners();

    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email';
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      errorMessage = 'Please enter your password';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.instance.login(
        LoginRequest(email: email.trim(), password: password),
      );

      // Decide navigation based on role from JWT response
      final role = response.user.role.toLowerCase();

      debugPrint('LOGIN ROLE = $role');

      if (role == 'tourist') {
        try {
          final profile = await TouristProfileService.instance.getProfile();

          if (profile.phoneNumber == null || profile.phoneNumber!.isEmpty) {
            navTarget = AuthNavTarget.profileCompletion;
          } else {
            navTarget = AuthNavTarget.home;
          }
        } catch (_) {
          navTarget = AuthNavTarget.profileCompletion;
        }
      } else if (role == 'guide') {
        try {
          final guideProfile = await GuideProfileService.getProfile();
          lastVerificationStatus = guideProfile.verificationStatus;
          lastRejectionReason = guideProfile.rejectionReason;

          if (guideProfile.verificationStatus.toLowerCase() == 'notsubmitted') {
            navTarget = AuthNavTarget.profileVerification;
          } else {
            navTarget = AuthNavTarget.guideHome;
          }
        } catch (_) {
          lastVerificationStatus = 'NotSubmitted';
          navTarget = AuthNavTarget.profileVerification;
        }
      } else {
        debugPrint('UNKNOWN ROLE = $role');
        navTarget = AuthNavTarget.home;
      }

      // Send FCM token to backend after successful login
      PushNotificationService.instance.checkAndSendToken();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        errorMessage =
            e.detail.isNotEmpty
                ? e.detail
                : 'Invalid email or password. Please check your credentials and that your email is verified.';
      } else {
        errorMessage = e.userMessage;
      }
    } catch (e) {
      errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(ResetPasswordRequest req) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await AuthService.instance.resetPassword(req);
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Failed to reset password. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    try {
      await AuthService.instance.logout();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────────

  /// Requests a password-reset email from the backend.
  /// The backend always returns 200 to prevent user enumeration.
  Future<void> forgotPassword(String email) async {
    await AuthService.instance.forgotPassword(email);
  }

  // ── Session check ─────────────────────────────────────────────────────────────

  /// Returns true if there is a stored access token (for splash screen logic).
  Future<bool> hasActiveSession() => TokenStorage.instance.hasValidSession;
}
