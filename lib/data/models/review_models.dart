// lib/data/models/review_models.dart
// Mirrors the backend CreateReviewDto and Review entity

/// POST /api/reviews — request body
class CreateReviewRequest {
  final int bookingId;
  final int guideUserId;
  final int? tripId;
  final int guideRating;   // 1–5, required
  final int? tripRating;   // 1–5, optional
  final String? comment;   // max 1000 chars

  const CreateReviewRequest({
    required this.bookingId,
    required this.guideUserId,
    this.tripId,
    required this.guideRating,
    this.tripRating,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'guideUserId': guideUserId,
        if (tripId != null) 'tripId': tripId,
        'guideRating': guideRating,
        if (tripRating != null) 'tripRating': tripRating,
        if (comment != null && comment!.isNotEmpty) 'comment': comment,
      };
}

/// Response returned by POST /api/reviews (the created Review object)
class ReviewResponse {
  final int id;
  final int touristUserId;
  final int guideUserId;
  final int bookingId;
  final int? tripId;
  final int guideRating;
  final int? tripRating;
  final String? comment;
  final DateTime createdAt;

  const ReviewResponse({
    required this.id,
    required this.touristUserId,
    required this.guideUserId,
    required this.bookingId,
    this.tripId,
    required this.guideRating,
    this.tripRating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> j) => ReviewResponse(
        id: j['id'] as int,
        touristUserId: j['touristUserId'] as int,
        guideUserId: j['guideUserId'] as int,
        bookingId: j['bookingId'] as int,
        tripId: j['tripId'] as int?,
        guideRating: j['guideRating'] as int,
        tripRating: j['tripRating'] as int?,
        comment: j['comment'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
