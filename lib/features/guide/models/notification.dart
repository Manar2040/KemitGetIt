// ============================================================
// notification_model.dart
// KemitGetit — Notification Models
// Endpoints:
//   GET  /api/notifications?page=&pageSize=
//   PUT  /api/notifications/{id}/read
//   PUT  /api/notifications/read-all
// ============================================================

// ============================================================
// 1. NotificationType
//    الأنواع المرئية في الـ UI من الصور
// ============================================================
enum NotificationType {
  paymentReceived,    // "Payment received"
  bookingCancelled,   // "Booking Cancelled"
  newRequest,         // "New request received"
  newReview,          // "New review received"
  unknown,
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromString(String? value) {
    switch (value) {
      case 'PaymentReceived':
        return NotificationType.paymentReceived;
      case 'BookingCancelled':
        return NotificationType.bookingCancelled;
      case 'NewRequest':
        return NotificationType.newRequest;
      case 'NewReview':
        return NotificationType.newReview;
      default:
        return NotificationType.unknown;
    }
  }
}

// ============================================================
// 2. NotificationModel
// ============================================================
class NotificationModel {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  // Optional deep-link data (بييجوا من الـ payload لو موجودين)
  final int? relatedTripId;
  final int? relatedBookingId;
  final int? relatedHoldRequestId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedTripId,
    this.relatedBookingId,
    this.relatedHoldRequestId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: NotificationTypeX.fromString(json['type']),
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      relatedTripId: json['relatedTripId'],
      relatedBookingId: json['relatedBookingId'],
      relatedHoldRequestId: json['relatedHoldRequestId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        'relatedTripId': relatedTripId,
        'relatedBookingId': relatedBookingId,
        'relatedHoldRequestId': relatedHoldRequestId,
      };

  // لو محتاجة تعملي copy مع تغيير isRead
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      relatedTripId: relatedTripId,
      relatedBookingId: relatedBookingId,
      relatedHoldRequestId: relatedHoldRequestId,
    );
  }
}

// ============================================================
// 3. NotificationsPageModel
//    الـ response من GET /api/notifications
//    { totalCount, page, pageSize, items: [...] }
//    ← لو الـ backend بيرجع list مباشرة بدون wrapper،
//      استخدمي NotificationsPageModel.fromList() بدل fromJson()
// ============================================================
class NotificationsPageModel {
  final int totalCount;
  final int page;
  final int pageSize;
  final List<NotificationModel> items;

  const NotificationsPageModel({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  // لو الـ response فيه wrapper object
  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    return NotificationsPageModel(
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      items: (json['items'] as List? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
    );
  }

  // لو الـ response list مباشرة
  factory NotificationsPageModel.fromList(List<dynamic> json,
      {int page = 1, int pageSize = 10}) {
    final items =
        json.map((e) => NotificationModel.fromJson(e)).toList();
    return NotificationsPageModel(
      totalCount: items.length,
      page: page,
      pageSize: pageSize,
      items: items,
    );
  }

  bool get hasMore => page * pageSize < totalCount;
}