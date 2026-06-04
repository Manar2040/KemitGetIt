import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/screens/hold_requests_screen.dart';
import 'package:kemit_get_it/features/guide/screens/mytrips.dart';
import 'package:kemit_get_it/features/guide/widgets/active_trips_list.dart';

import '../widgets/hold_requests_list.dart';

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
                  backgroundImage: AssetImage(
                    "lib/features/guide/images/person1 (1).jpg",
                  ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Active Trips",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyTripsView()),
                    );
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(fontSize: 15, color: Color(0xFFB9975B)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ActiveTripsList(),

            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hold Requests",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HoldRequestScreen()),
                    );
                  },
                  child: Text(
                    "See All",
                    style: TextStyle(fontSize: 15, color: Color(0xFFB9975B)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            HoldRequestsList(limit: 2,),

            SizedBox(height: 24),
           
          ],
        ),
      ),
    );
  }
}
