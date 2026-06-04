// lib/main.dart

import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  
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