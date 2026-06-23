import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../features/tourist/data/notification_model.dart';

class NotificationService {
  final ApiClient _client;

  NotificationService() : _client = ApiClient.instance;

  Future<List<NotificationModel>> getNotifications({int page = 1, int pageSize = 20}) async {
    final response = await _client.get(
      ApiConstants.notifications,
      queryParams: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final List<dynamic> data = response is List ? response : (response['items'] ?? response['data'] ?? []);
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await _client.put(ApiConstants.notificationRead(notificationId));
  }

  Future<void> markAllAsRead() async {
    await _client.put(ApiConstants.notificationsReadAll);
  }
}
