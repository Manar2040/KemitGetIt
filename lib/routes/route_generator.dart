// lib/routes/route_generator.dart
import 'package:flutter/material.dart';
import 'package:kemit_get_it/data/models/place.dart';
import 'package:kemit_get_it/features/auth/view/auth_options_view.dart';
import 'package:kemit_get_it/features/auth/view/role-selection-view.dart';
import 'package:kemit_get_it/features/guide/screens/profile_verification_screen.dart';
import 'package:kemit_get_it/features/tourist/view/place_details_view.dart';
import 'package:kemit_get_it/features/tourist/view/video_tour_view.dart';
import '../features/auth/view/splash_view.dart';
import '../features/tourist/view/home_view.dart';
import '../shared/models/user.dart';
import '../features/auth/view/profile_form_view.dart';
import '../features/auth/view/sign_up_view.dart';
import '../features/auth/view/login_view.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      case AppRoutes.authOptions:
        return MaterialPageRoute(builder: (_) => const AuthOptionsView());

      case AppRoutes.signUp:
      final role = settings.arguments as String? ?? 'tourist';
      return MaterialPageRoute(
      builder: (_) => SignupView(role: role),
      );


      case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginView());
      
      case AppRoutes.roleSelection:
      return MaterialPageRoute(builder: (_) => const RoleSelectionView());

      case AppRoutes.profileVerification:
      return MaterialPageRoute(builder: (_) => const ProfileVerificationScreen());

      case AppRoutes.placeDetails:
      final place = settings.arguments as Place;
      return MaterialPageRoute(
      builder: (_) => PlaceDetailsView(place: place),
      );

      case AppRoutes.videoTour:
      final title = settings.arguments as String?;
      return MaterialPageRoute(
      builder: (_) => VideoTourView(title: title ?? 'Virtual Tour'),
      );
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
