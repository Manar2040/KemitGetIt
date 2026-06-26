// ============================================================
// notification_tile.dart
// KemitGetit — Notification Tile Widget
// ============================================================

import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/models/notification.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onActionTap; // "View Trip" / "View hold request" / "Add him to Trip"
  final VoidCallback? onTap;       // mark as read + navigate

  const NotificationTile({
    super.key,
    required this.notification,
    this.onActionTap,
    this.onTap,
  });

  // ── Title color per type ──────────────────────────────────
  Color get _titleColor {
    switch (notification.type) {
      case NotificationType.paymentReceived:
        return const Color(0xFF2E7D32); // dark green
      case NotificationType.bookingCancelled:
        return const Color(0xFFC62828); // dark red
      case NotificationType.newRequest:
        return const Color(0xFF2E7D32);
      case NotificationType.newReview:
        return const Color(0xFF2E7D32);
      case NotificationType.unknown:
        return const Color(0xFF424242);
    }
  }

  // ── Action label per type ─────────────────────────────────
  String? get _actionLabel {
    switch (notification.type) {
      case NotificationType.paymentReceived:
        // "Payment received" مع tripId → "View Trip"
        // "Payment received" مع bookingId بس → "Add him to Trip"
        if (notification.relatedTripId != null) return 'View Trip';
        if (notification.relatedBookingId != null) return 'Add him to Trip';
        return null;
      case NotificationType.newRequest:
        return 'View hold request';
      case NotificationType.bookingCancelled:
      case NotificationType.newReview:
      case NotificationType.unknown:
        return null;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFFF9F9F9),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Unread dot + Title ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!notification.isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 5, right: 6),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      color: _titleColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Body ──
            Text(
              notification.body,
              style: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 13,
                height: 1.4,
              ),
            ),

            // ── Action link ──
            if (_actionLabel != null) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  _actionLabel!,
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],

            // ── Time ──
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatTime(notification.createdAt),
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}