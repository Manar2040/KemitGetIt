import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/chat_service.dart';
import 'package:kemit_get_it/features/guide/screens/Chats%20list%20screen.dart';
import 'package:kemit_get_it/features/guide/screens/create_trip_screen.dart';
import 'package:kemit_get_it/features/guide/screens/guide_profile_screen.dart';
import 'package:kemit_get_it/features/guide/screens/home_screen.dart';
import 'package:kemit_get_it/features/guide/screens/mytrips.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // ✅ Fix — instance واحدة طول عمر الـ MainScreen
  //    بدل ما تتعمل ChatService() جديدة كل مرة بيتبنى الـ widget
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const MyTripsView(),
      CreateTripScreen(
        onTripCreated: () {
          setState(() => _currentIndex = 0);
        },
      ),
      ChatsListScreen(
        chatService: _chatService,   // ✅ نفس الـ instance دايمًا
      ),
      const GuideProfileView(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFB9975B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Trips'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create Trip'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}