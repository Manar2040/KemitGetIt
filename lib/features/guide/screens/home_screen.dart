import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/widgets/active_trips_list.dart';

import '../widgets/hold_requests_list.dart';
import '../widgets/ai_suggest_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("lib/features/guide/images/person1 (1).jpg"),
                ),
                SizedBox(width: 8),
                Text(
                  "Welcome,Ahmed",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Active Trips",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ActiveTripsList(),

            SizedBox(height: 24),
            Text(
              "Hold Requests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            HoldRequestsList(),

            SizedBox(height: 24),
            Text(
              "AI Suggested Tourists",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            AiSuggestList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Color(0xFFB9975B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Trips"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create Trip"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
