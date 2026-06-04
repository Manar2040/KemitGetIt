import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/models/trip_details_model.dart';
import 'package:kemit_get_it/features/guide/widgets/mytrip.dart';

class MyTripsView extends StatefulWidget {
  const MyTripsView({super.key});

  @override
  State<MyTripsView> createState() => _MyTripsViewState();
}

class _MyTripsViewState extends State<MyTripsView> {
  String selectedFilter = "All";

  List<TripDetailsModel> getFilteredTrips() {
    if (selectedFilter == "All") return tripDetails;
    return tripDetails.where((trip) => trip.status == selectedFilter).toList();
  }

  Widget buildFilter(String title) {
    bool isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFB9975B) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filteredTrips = getFilteredTrips();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Trips",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// FILTERS
            Row(
              children: [
                buildFilter("All"),
                buildFilter("Active"),
                buildFilter("Draft"),
                buildFilter("Completed"),
              ],
            ),

            const SizedBox(height: 16),

            
            Expanded(
              child: ListView.builder(
                itemCount: filteredTrips.length,
                itemBuilder: (context, index) {
                  return TripCard(trip: filteredTrips[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
