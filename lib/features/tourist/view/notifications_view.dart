import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../data/notification_model.dart';
import '../viewmodel/notification_viewmodel.dart';
import '../../../core/services/push_notification_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide locally for now, unless injected globally
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel()..fetchNotifications(),
      child: const _NotificationsPageContent(),
    );
  }
}

class _NotificationsPageContent extends StatelessWidget {
  const _NotificationsPageContent();

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark),
          iconSize: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, vm, child) {
              if (vm.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all, color: AppColors.primaryDark),
                  onPressed: () => vm.markAllAsRead(),
                  tooltip: 'Mark all as read',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryDark));
          }

          if (vm.errorMessage != null && vm.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: vm.fetchNotifications,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (vm.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet.', style: AppTextStyles.bodyText),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryDark,
            onRefresh: vm.fetchNotifications,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildFilterChip(vm.unreadCount),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: vm.notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(context, vm, vm.notifications[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(int unreadCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'All (${unreadCount > 0 ? '$unreadCount Unread' : '0 Unread'})',
        style: AppTextStyles.label.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationViewModel vm, NotificationModel notification) {
    Color titleColor = AppColors.primaryDark;
    if (notification.type.toLowerCase().contains('success') || notification.type == 'RequestAccepted') {
      titleColor = AppColors.success;
    } else if (notification.type.toLowerCase().contains('error') || notification.type == 'RequestDeclined') {
      titleColor = AppColors.error;
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          vm.markAsRead(notification.id);
        }
        // Delegate navigation to the unified deep-link handler
        final data = {
          'type': notification.type,
          'referenceId': notification.referenceId?.toString(),
        };
        PushNotificationService.instance.handleDeepLink(data);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.background : const Color(0xFFF0EAE1), // slightly darker if unread
          borderRadius: BorderRadius.circular(12),
          border: notification.isRead ? null : Border.all(color: AppColors.primaryDark.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: AppTextStyles.label.copyWith(
                      color: titleColor,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                  )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.body,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTimeAgo(notification.createdAt.toLocal()),
                  style: AppTextStyles.bodyTextSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
