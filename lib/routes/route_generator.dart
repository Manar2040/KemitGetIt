// lib/routes/route_generator.dart
import 'package:flutter/material.dart';
import 'package:kemit_get_it/views/auth/auth_options_view.dart';
import 'package:kemit_get_it/views/auth/role-selection-view.dart';
import '../views/splash/splash_view.dart';
import '../views/home/home_view.dart';
import '../data/models/user.dart';
import '../views/auth/profile_form_view.dart';
import '../views/auth/sign_up_view.dart';
import '../views/auth/login_view.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      case AppRoutes.authOptions:
        return MaterialPageRoute(builder: (_) => const AuthOptionsView());

      case AppRoutes.signUp:
      return MaterialPageRoute(builder: (_) => const SignupView());

      case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginView());

      case AppRoutes.roleSelection:
      return MaterialPageRoute(builder: (_) => const RoleSelectionView());

      case AppRoutes.home:
      
        return MaterialPageRoute(builder: (_) => HomeView(
                                                  user: User(
        
                                                  name: "Guest User",
      
                                                  phone: "",
                                                  age: 0,
                                                  country: "",
                                                  language: "",
                                                  interests: [],
    ),
  ),

  
);

      case AppRoutes.profileForm:
        final user = (settings.arguments is User)
    ? settings.arguments as User
    : User(
        name: '',
        phone: '',
        
      );
        return MaterialPageRoute(builder: (_) => ProfileFormView(user: user));

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
