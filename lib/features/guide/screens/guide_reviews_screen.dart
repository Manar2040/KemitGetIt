import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/review_service.dart';
import 'package:kemit_get_it/features/guide/models/review_model.dart';

class GuideReviewsScreen extends StatefulWidget {
  final int guideUserId;

  const GuideReviewsScreen({super.key, required this.guideUserId});

  @override
  State<GuideReviewsScreen> createState() => _GuideReviewsScreenState();
}

class _GuideReviewsScreenState extends State<GuideReviewsScreen> {
  bool _loading = true;
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ReviewService.getGuideReviews(
        widget.guideUserId,
        page: 1,
        pageSize: 100,
      );

      setState(() {
        _reviews = data.items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Reviews",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _reviews.isEmpty
              ? const Center(child: Text("No reviews yet"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tourist #${review.touristUserId}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                color:
                                    i < review.guideRating
                                        ? Colors.amber
                                        : Colors.grey,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(review.comment),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
