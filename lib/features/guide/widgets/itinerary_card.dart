import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/models/trip_details_model.dart';

class ItineraryCard extends StatelessWidget {
  final ItineraryModel itinerary;

  const ItineraryCard({super.key, required this.itinerary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(itinerary.dayTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(itinerary.description),
      ),
    );
  }
}