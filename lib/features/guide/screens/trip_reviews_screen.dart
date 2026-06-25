import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/review_service.dart';
import 'package:kemit_get_it/features/guide/models/review_model.dart';
import 'package:kemit_get_it/features/guide/widgets/review_card.dart';

class TripReviewsScreen extends StatefulWidget {
  final int tripId;
  final String tripTitle;

  const TripReviewsScreen({
    super.key,
    required this.tripId,
    required this.tripTitle,
  });

  @override
  State<TripReviewsScreen> createState() => _TripReviewsScreenState();
}

class _TripReviewsScreenState extends State<TripReviewsScreen> {
  late Future<ReviewsPageModel> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = ReviewService.getTripReviews(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Column(
          children: [
            const Text(
              "Reviews",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              widget.tripTitle,
              style: const TextStyle(
                color: Color(0xFFB9975B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<ReviewsPageModel>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB9975B)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    "Failed to load reviews.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _reviewsFuture =
                          ReviewService.getTripReviews(widget.tripId);
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB9975B),
                    ),
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final reviews = snapshot.data?.items ?? [];

          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                "No reviews yet for this trip.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReviewCard(review: reviews[index]),
              );
            },
          );
        },
      ),
    );
  }
}