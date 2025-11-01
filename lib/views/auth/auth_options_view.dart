import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AuthOptionsView extends StatelessWidget {
  const AuthOptionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05080D), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              
              Image.asset(
                'lib/core/assets/images/logo.jpg',
                height: MediaQuery.of(context).size.height * 0.4,
              ),

              const Spacer(flex: 3),

             
              ElevatedButton(
                onPressed: () {
                  
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9975B), 
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16), // Spacing between buttons

              // Signup Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Signup screen
                  Navigator.pushNamed(context, AppRoutes.signup);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5), 
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Signup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333), // Dark text color for contrast
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