import 'package:flutter/material.dart';
import '../models/trip_details_model.dart';

class ReviewCard extends StatelessWidget {
  final TripReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEFEEEE),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 198, 197, 197),
            blurRadius: .5,
            spreadRadius: .5,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(review.image)),
        title: Text(review.name),
        subtitle: Text(review.review),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            review.rating.toInt(),
            (index) => const Icon(Icons.star, color: Colors.yellow, size: 16),
          ),
        ),
      ),
    );
  }
}
