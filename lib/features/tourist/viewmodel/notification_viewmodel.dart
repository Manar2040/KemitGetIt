import 'package:flutter/material.dart';
import '../../../data/services/notification_service.dart';
import '../data/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> notifications = [];
  bool isLoading = false;
  String? errorMessage;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      notifications = await _service.getNotifications();
    } catch (e) {
      errorMessage = 'Failed to load notifications: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      // Optimistic update
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        title: notifications[index].title,
        body: notifications[index].body,
        type: notifications[index].type,
        referenceId: notifications[index].referenceId,
        isRead: true,
        createdAt: notifications[index].createdAt,
      );
      notifyListeners();

      try {
        await _service.markAsRead(id);
      } catch (e) {
        // Revert on failure
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          body: notifications[index].body,
          type: notifications[index].type,
          referenceId: notifications[index].referenceId,
          isRead: false,
          createdAt: notifications[index].createdAt,
        );
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = NotificationModel(
          id: notifications[i].id,
          title: notifications[i].title,
          body: notifications[i].body,
          type: notifications[i].type,
          referenceId: notifications[i].referenceId,
          isRead: true,
          createdAt: notifications[i].createdAt,
        );
      }
    }
    notifyListeners();

    try {
      await _service.markAllAsRead();
    } catch (e) {
      // Ignore errors for now or refetch
      fetchNotifications();
    }
  }
}
