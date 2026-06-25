// ============================================================
// review_models.dart
// KemitGetit — Reviews API Models
// Endpoints:
//   GET /api/reviews/{id}
//   GET /api/reviews/guide/{guideUserId}?page=&pageSize=
//   GET /api/reviews/trip/{tripId}?page=&pageSize=
// ============================================================

// ============================================================
// 1. ReviewModel
//    بييجي من:
//      GET /api/reviews/{id}             (single)
//      GET /api/reviews/guide/{id}       (جوا items list)
//      GET /api/reviews/trip/{id}        (جوا items list)
// ============================================================
class ReviewModel {
  final int id;
  final int touristUserId;
  final int guideUserId;
  final int bookingId;
  final int tripId;
  final int guideRating;
  final int tripRating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewModel({
    required this.id,
    required this.touristUserId,
    required this.guideUserId,
    required this.bookingId,
    required this.tripId,
    required this.guideRating,
    required this.tripRating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      touristUserId: json['touristUserId'],
      guideUserId: json['guideUserId'],
      bookingId: json['bookingId'],
      tripId: json['tripId'],
      guideRating: json['guideRating'] ?? 0,
      tripRating: json['tripRating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'touristUserId': touristUserId,
    'guideUserId': guideUserId,
    'bookingId': bookingId,
    'tripId': tripId,
    'guideRating': guideRating,
    'tripRating': tripRating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

// ============================================================
// 2. ReviewsPageModel
//    بييجي من:
//      GET /api/reviews/guide/{guideUserId}?page=&pageSize=
//      GET /api/reviews/trip/{tripId}?page=&pageSize=
//    Response shape:
//      { totalCount, page, pageSize, items: [...] }
// ============================================================
class ReviewsPageModel {
  final int totalCount;
  final int page;
  final int pageSize;
  final List<ReviewModel> items;

  const ReviewsPageModel({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory ReviewsPageModel.fromJson(Map<String, dynamic> json) {
    return ReviewsPageModel(
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      items:
          (json['items'] as List? ?? [])
              .map((e) => ReviewModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCount': totalCount,
    'page': page,
    'pageSize': pageSize,
    'items': items.map((e) => e.toJson()).toList(),
  };

  /// هل في صفحات تانية بعد دي؟
  bool get hasMore => page * pageSize < totalCount;

  /// عدد الصفحات الكلي
  int get totalPages => (totalCount / pageSize).ceil();
}
