import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/notification.dart';

class NotificationService {
  // ── GET /api/notifications ────────────────────────────────
  static Future<NotificationsPageModel> getNotifications({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await ApiService.get(
      '/api/notifications?page=$page&pageSize=$pageSize',
    );

    final decoded = response.data;

    if (decoded is Map<String, dynamic>) {
      return NotificationsPageModel.fromJson(decoded);
    }
    if (decoded is List) {
      return NotificationsPageModel.fromList(
        decoded,
        page: page,
        pageSize: pageSize,
      );
    }

    throw Exception('Unexpected response format');
  }

  // ── PUT /api/notifications/{id}/read ─────────────────────
  static Future<void> markAsRead(int id) async {
    await ApiService.put('/api/notifications/$id/read', {});
  }

  // ── PUT /api/notifications/read-all ──────────────────────
  static Future<void> markAllAsRead() async {
    await ApiService.put('/api/notifications/read-all', {});
  }
}
