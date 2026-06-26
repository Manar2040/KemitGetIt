import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

class ItineraryCard extends StatelessWidget {
  final ItineraryDayModel itinerary;

  const ItineraryCard({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFB9975B),
          child: Text(
            '${itinerary.dayNumber}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          itinerary.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(itinerary.description),
      ),
    );
  }
}