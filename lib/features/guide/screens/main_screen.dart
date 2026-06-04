import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/screens/home_screen.dart';
import 'package:kemit_get_it/features/guide/screens/mytrips.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const MyTripsView(),
    const Center(child: Text("Create Trip")),
    const Center(child: Text("Chats")),
    const Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,

        onTap: (index){
          setState(() {
            currentIndex = index;
          });
        },

        selectedItemColor: const Color(0xFFB9975B),
        unselectedItemColor: Colors.grey,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Trips",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Create Trip",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}