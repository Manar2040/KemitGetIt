// ============================================================
// notification_screen.dart
// KemitGetit — Guide Notifications Screen
// API:
//   GET  /api/notifications?page=&pageSize=
//   PUT  /api/notifications/{id}/read
//   PUT  /api/notifications/read-all
// ============================================================

import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/notification_service.dart';
import 'package:kemit_get_it/features/guide/models/notification.dart';
import 'package:kemit_get_it/features/guide/widgets/notification_widget.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // ── State ─────────────────────────────────────────────────
  List<NotificationModel> _notifications = [];
  bool   _isLoading      = true;
  bool   _isFetchingMore = false;
  String? _errorMessage;
  int    _page           = 1;
  bool   _hasMore        = true;

  final ScrollController _scrollController = ScrollController();

  // ── عدد الغير مقروء (للـ badge في الـ AppBar) ────────────
  int get _unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Fetch ─────────────────────────────────────────────────
  Future<void> _fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page         = 1;
        _hasMore      = true;
        _isLoading    = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await NotificationService.getNotifications(
        page: _page,
        pageSize: 10,
      );

      setState(() {
        if (refresh || _page == 1) {
          _notifications = result.items;
        } else {
          _notifications.addAll(result.items);
        }
        _hasMore        = result.hasMore;
        _isLoading      = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage   = 'Failed to load notifications. Please try again.';
        _isLoading      = false;
        _isFetchingMore = false;
      });
    }
  }

  // ── Pagination ────────────────────────────────────────────
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isFetchingMore) {
      setState(() {
        _page++;
        _isFetchingMore = true;
      });
      _fetchNotifications();
    }
  }

  // ── Mark single as read ───────────────────────────────────
  Future<void> _markAsRead(NotificationModel n) async {
    if (n.isRead) return;
    // Optimistic update
    setState(() {
      final idx = _notifications.indexWhere((e) => e.id == n.id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      }
    });
    try {
      await NotificationService.markAsRead(n.id);
    } catch (_) {
      // Rollback لو فشل
      setState(() {
        final idx = _notifications.indexWhere((e) => e.id == n.id);
        if (idx != -1) {
          _notifications[idx] =
              _notifications[idx].copyWith(isRead: false);
        }
      });
    }
  }

  // ── Mark all as read ──────────────────────────────────────
  Future<void> _markAllAsRead() async {
    // Optimistic update
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    try {
      await NotificationService.markAllAsRead();
    } catch (_) {
      _showSnackBar('Failed to mark all as read.');
      // Refresh من السيرفر
      _fetchNotifications(refresh: true);
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Handle action tap (View Trip / View hold request / etc) ──
  void _handleAction(NotificationModel n) {
    // TODO: استبدلي بالـ navigation الحقيقي
    switch (n.type) {
      case NotificationType.paymentReceived:
        if (n.relatedTripId != null) {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailsView(...)));
        } else if (n.relatedBookingId != null) {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => AddToTripScreen(...)));
        }
        break;
      case NotificationType.newRequest:
        if (n.relatedHoldRequestId != null) {
          // Navigator.push(context, MaterialPageRoute(builder: (_) => HoldRequestDetailsScreen(...)));
        }
        break;
      default:
        break;
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 18, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_unreadCount > 0)
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Read all',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchNotifications(refresh: true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50)),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_outlined,
                size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF4CAF50),
      onRefresh: () => _fetchNotifications(refresh: true),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                _notifications.length + (_isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _notifications.length) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50), strokeWidth: 2),
                  ),
                );
              }

              final n = _notifications[index];
              return NotificationTile(
                notification: n,
                onTap: () => _markAsRead(n),
                onActionTap: () {
                  _markAsRead(n);
                  _handleAction(n);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}