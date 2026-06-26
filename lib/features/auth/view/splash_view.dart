// lib/features/auth/view/splash_view.dart

import 'package:flutter/material.dart';
import '../../../core/services/token_storage.dart';
import '../../../routes/app_routes.dart';

/// Splash screen: shown on app launch.
///
/// Behaviour:
///  - Checks [TokenStorage] for a stored access token.
///  - If a session exists → navigates directly to home (skip auth).
///  - If no session → shows the "Explore Now" button to begin auth flow.
class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final hasSession = await TokenStorage.instance.hasValidSession;
    if (!mounted) return;

    if (hasSession) {
      final role = (await TokenStorage.instance.role)?.toLowerCase();

      if (role == 'guide') {
        Navigator.pushReplacementNamed(context, AppRoutes.guideHome);
      } else {
        // tourist or unknown role → default to tourist home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      setState(() => _checkingSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF05080D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Container(
                height: screenHeight * 0.4,
                child: Image.asset(
                  'lib/core/assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(flex: 3),

              // Only show the button once we've confirmed there's no active session.
              if (_checkingSession)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFB9975B),
                    ),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB9975B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.authOptions,
                    );
                  },
                  child: const Text(
                    'Explore Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
