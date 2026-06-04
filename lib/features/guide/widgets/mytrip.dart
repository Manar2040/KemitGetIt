import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/models/trip_details_model.dart';
import 'package:kemit_get_it/features/guide/screens/trip_details_view.dart';

class TripCard extends StatelessWidget {
  final TripDetailsModel trip;

  const TripCard({super.key, required this.trip});

  Color getStatusColor() {
    switch (trip.status) {
      case "Active":
        return Colors.green;
      case "Draft":
        return Colors.grey;
      case "Completed":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                Image.asset(
                  trip.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                /// STATUS
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trip.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE + PRICE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${trip.price}\$",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB9975B),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          "${trip.currentTourists}/${trip.maxTourists} Tourists",
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 5),
                        Text(trip.date),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${trip.startPoint} → ${trip.endPoint}",
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Edit"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripDetailsView(trip: trip),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFFB9975B),
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
