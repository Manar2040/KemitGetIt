// lib/routes/route_generator.dart
import 'package:flutter/material.dart';
import 'package:kemit_get_it/views/auth/auth_options_view.dart';
import '../views/splash/splash_view.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      case AppRoutes.authOptions:
        return MaterialPageRoute(builder: (_) => const AuthOptionsView()); 

      // ... other cases for your routes

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}