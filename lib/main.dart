// lib/main.dart

import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/push_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize();
  } catch (e) {
    debugPrint("Firebase init failed (likely missing google-services.json): $e");
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KemitGetIt App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        // your app theme
      ),
      initialRoute: AppRoutes.splash, 
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}