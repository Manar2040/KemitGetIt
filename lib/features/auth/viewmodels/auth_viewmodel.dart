import 'package:flutter/material.dart';

enum AuthNavTarget { none, home, profileCompletion,profileVerification }


class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  AuthNavTarget navTarget = AuthNavTarget.none;

  void consumeNavTarget() {
    navTarget = AuthNavTarget.none;
  }

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

    // Validation
    if (username.trim().isEmpty) {
      errorMessage = 'Please enter a username';
      notifyListeners();
      return;
    }
    if (email.trim().isEmpty) {
      errorMessage = 'Please enter your email';
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      errorMessage = 'Please enter a password';
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

    // TODO: API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading = false;
    notifyListeners();

    // Navigation decision
if (role == 'tourist') {
  navTarget = AuthNavTarget.profileCompletion;
} else if (role == 'guide') {
  navTarget = AuthNavTarget.profileVerification;
} else {
  navTarget = AuthNavTarget.home;
}

notifyListeners();

  }
}
