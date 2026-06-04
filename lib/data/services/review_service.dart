// lib/data/services/review_service.dart
import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../models/review_models.dart';

/// Handles all Review API calls.
///
/// Endpoints used:
///   POST /api/reviews                      → [createReview]
///   GET  /api/reviews/{id}                 → [getReviewById]
///   GET  /api/reviews/guide/{guideUserId}  → [getGuideReviews]
///   GET  /api/reviews/trip/{tripId}        → [getTripReviews]
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();
  final _client = ApiClient.instance;

  // ── Create Review (Tourist only) ─────────────────────────────────────────────
  Future<ReviewResponse> createReview(CreateReviewRequest req) async {
    final data = await _client.post(
      ApiConstants.createReview,
      body: req.toJson(),
      auth: true,
    );
    return ReviewResponse.fromJson(data as Map<String, dynamic>);
  }

  // ── Get Review by ID ─────────────────────────────────────────────────────────
  Future<ReviewResponse?> getReviewById(int id) async {
    try {
      final data = await _client.get(
        ApiConstants.reviewById(id),
        auth: false,
      );
      return ReviewResponse.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Get Reviews for a Guide ───────────────────────────────────────────────────
  Future<List<ReviewResponse>> getGuideReviews(int guideUserId, {int page = 1, int pageSize = 10}) async {
    final data = await _client.get(
      '${ApiConstants.reviewsByGuide(guideUserId)}?page=$page&pageSize=$pageSize',
      auth: false,
    );
    if (data is List) {
      return data.map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>)).toList();
    }
    // Handle paginated wrapper if backend wraps in { items: [...] }
    final list = (data as Map<String, dynamic>)['items'] as List? ?? [];
    return list.map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Get Reviews for a Trip ────────────────────────────────────────────────────
  Future<List<ReviewResponse>> getTripReviews(int tripId, {int page = 1, int pageSize = 10}) async {
    final data = await _client.get(
      '${ApiConstants.reviewsByTrip(tripId)}?page=$page&pageSize=$pageSize',
      auth: false,
    );
    if (data is List) {
      return data.map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>)).toList();
    }
    final list = (data as Map<String, dynamic>)['items'] as List? ?? [];
    return list.map((e) => ReviewResponse.fromJson(e as Map<String, dynamic>)).toList();
  }
}
