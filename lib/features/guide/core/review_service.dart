import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/review_model.dart';

class ReviewService {
  /// GET /api/reviews/trip/{tripId}?page=&pageSize=
  static Future<ReviewsPageModel> getTripReviews(
    int tripId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await ApiService.get(
      '/api/reviews/trip/$tripId?page=$page&pageSize=$pageSize',
    );
    return ReviewsPageModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/reviews/guide/{guideUserId}?page=&pageSize=
  /// (سايباها هنا كمان لو احتجتيها لاحقًا في شاشة بروفايل الجايد)
  static Future<ReviewsPageModel> getGuideReviews(
    int guideUserId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await ApiService.get(
      '/api/reviews/guide/$guideUserId?page=$page&pageSize=$pageSize',
    );
    return ReviewsPageModel.fromJson(response.data as Map<String, dynamic>);
  }
}