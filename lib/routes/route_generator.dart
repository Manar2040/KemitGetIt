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
import '../data/models/tourist_models.dart';
import '../features/auth/view/profile_form_view.dart';
import '../features/auth/view/sign_up_view.dart';
import '../features/auth/view/login_view.dart';
import '../features/auth/view/forgot_password_view.dart';
import '../features/auth/view/reset_password_view.dart';
import '../features/tourist/view/profile_view.dart';
import '../features/tourist/view/edit_profile_view.dart';
import '../features/tourist/view/guide_profile_view.dart';
import '../features/tourist/view/chats_list_view.dart';
import '../features/tourist/view/guide_chat_view.dart';
import '../features/tourist/view/guide_call_view.dart';
import '../features/tourist/view/my_plan_view.dart';
import '../features/tourist/view/trip_request_form_view.dart';
import '../features/tourist/view/my_requests_view.dart';
import '../features/tourist/view/matched_guides_view.dart';
import '../features/tourist/view/payment_view.dart';
import '../features/tourist/view/trip_plan_details_view.dart';
import '../data/models/trip_models.dart';
import '../features/tourist/view/pyramids_3d_view.dart';
import '../features/tourist/view/unity_embed_view.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Check if it's a deep link url /reset-password?userId=...&token=...
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri != null && uri.path == AppRoutes.resetPassword) {
      final userId = uri.queryParameters['userId'] ?? '';
      final token = uri.queryParameters['token'] ?? '';
      return MaterialPageRoute(
        builder: (_) => ResetPasswordView(userId: userId, token: token),
      );
    }

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());

      case AppRoutes.guideProfile:
        final guideId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => GuideProfileView(guideId: guideId));
        
      case AppRoutes.chatsList:
        return MaterialPageRoute(builder: (_) => const ChatsListView());

      case AppRoutes.guideChat:
        final args = settings.arguments as Map<String, dynamic>;
        final status = args['status'] as String? ?? 'Active';
        
        // Global Route Guard: Prevent access to chat if payment is pending
        if (status.toLowerCase() == 'pendingpayment' || status.toLowerCase() == 'accepted') {
          return MaterialPageRoute(builder: (_) => const MyRequestsView());
        }

        return MaterialPageRoute(
          builder: (_) => GuideChatView(
            conversationId: args['conversationId'] as int,
            bookingId: args['bookingId'] as int,
            otherParticipantName: args['otherParticipantName'] as String,
            status: status,
          ),
        );

      case AppRoutes.guideCall:
        final guideName = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => GuideCallView(guideName: guideName));
        
      /*case AppRoutes.liveTracking:
        return MaterialPageRoute(builder: (_) => const LiveTrackingView());*/

      case AppRoutes.touristProfile:

        return MaterialPageRoute(builder: (_) => const ProfileView());

      case AppRoutes.editProfile:
        final profileArg = settings.arguments as TouristProfileResponse?;
        return MaterialPageRoute(builder: (_) => EditProfileView(profile: profileArg));

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordView());

      case AppRoutes.resetPassword: // Standard named route if args are passed
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordView(
            userId: args?['userId'] ?? '',
            token: args?['token'] ?? '',
          ),
        );

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
        return MaterialPageRoute(
          builder: (_) => const HomeView(),
        );

      case AppRoutes.profileForm:
        // ProfileFormView no longer requires a User argument.
        // It fetches interests and submits profile data via the API.
        return MaterialPageRoute(builder: (_) => const ProfileFormView());

      case AppRoutes.myPlan:
        return MaterialPageRoute(builder: (_) => const MyPlanView());

      case AppRoutes.tripRequestForm:
        final args = settings.arguments as Map<String, dynamic>?;
        final isFromTripPlan = args?['isFromTripPlan'] as bool? ?? false;
        final tripPlan = args?['tripPlan'] as TripDetails?;
        final place = args?['place'] as Place?;
        return MaterialPageRoute(
          builder: (_) => TripRequestFormView(
            isFromTripPlan: isFromTripPlan,
            tripPlan: tripPlan,
            place: place,
          ),
        );

      case AppRoutes.matchedGuides:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => MatchedGuidesView(requestData: args));

      case AppRoutes.payment:
        return MaterialPageRoute(builder: (_) => const PaymentView());

      case AppRoutes.tripPlanDetails:
        final args = settings.arguments as Map?;
        final tripId = args?['tripId'] as int? ?? 1;
        final requestStatus = args?['requestStatus'] as String?;
        final requestId = args?['requestId'] as int?;
        final requestGuideUserId = args?['requestGuideUserId'] as int?;
        return MaterialPageRoute(
          builder: (_) => TripPlanDetailsPage(
            tripId: tripId,
            requestStatus: requestStatus,
            requestId: requestId,
            requestGuideUserId: requestGuideUserId,
          ),
        );

      case AppRoutes.myRequests:
        return MaterialPageRoute(builder: (_) => const MyRequestsView());

      case AppRoutes.pyramids3d:
        return MaterialPageRoute(builder: (_) => const Pyramids3dView());

      case AppRoutes.unityEmbed:
        return MaterialPageRoute(builder: (_) => const UnityEmbedView());

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
