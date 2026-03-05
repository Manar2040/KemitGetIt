class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationType type;
  final String? actionText;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.actionText,
    this.isRead = false,
  });
}

enum NotificationType {
  success,
  error,
  info,
}

// --- Dummy Data ---

final List<NotificationModel> dummyNotifications = [
  NotificationModel(
    id: 'n1',
    title: 'Your request has been approved',
    message: 'Guide <Ahmed> approved your request for the trip \'Discover Luxor & Aswan\'',
    timestamp: '3h ago',
    type: NotificationType.success,
    actionText: 'Proceed to payment',
  ),
  NotificationModel(
    id: 'n2',
    title: 'Your request has been declined',
    message: 'because "Alexandria Cultural Getaway " trip has been completed.',
    timestamp: '7h ago',
    type: NotificationType.error,
  ),
  NotificationModel(
    id: 'n3',
    title: 'Special discount from Nile Hotel!',
    message: 'Limited-time offer — book tonight and get 20% off.',
    timestamp: '2d ago',
    type: NotificationType.info,
  ),
];
