import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../data/notification_model.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildFilterChip(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: dummyNotifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildNotificationCard(dummyNotifications[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'All',
        style: AppTextStyles.label.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    Color titleColor;
    switch (notification.type) {
      case NotificationType.success:
        titleColor = AppColors.success;
        break;
      case NotificationType.error:
        titleColor = AppColors.error;
        break;
      case NotificationType.info:
        titleColor = AppColors.textPrimary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.title,
            style: AppTextStyles.label.copyWith(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notification.message,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                notification.timestamp,
                style: AppTextStyles.bodyTextSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (notification.actionText != null)
                Text(
                  notification.actionText!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryDark,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
