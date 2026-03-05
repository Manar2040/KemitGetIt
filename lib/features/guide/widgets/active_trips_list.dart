import 'package:flutter/material.dart';

import 'package:kemit_get_it/features/guide/data/active_trips_data.dart';


class ActiveTripsList extends StatelessWidget {
  const ActiveTripsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeTrips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final trip = activeTrips[index];
          return Container(
            width: 220,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:  Color.fromARGB(255, 250, 250, 250),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    trip.image,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  trip.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    Text(" ${trip.tourists} Tourists"),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 16),
                    Text(" ${trip.timeLeft}"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
