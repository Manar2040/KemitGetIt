// lib/views/splash/splash_view.dart

import 'package:flutter/material.dart';
import '../../routes/app_routes.dart'; 

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Getting screen dimensions for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                  'lib/core/assets/images/logo.jpg', 
                  fit: BoxFit.contain,
                ),
              ),

              
              const Spacer(flex: 3),

              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9975B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), 
                  ),
                ),
                onPressed: () {
                  
                  Navigator.pushReplacementNamed(context, AppRoutes.authOptions);
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