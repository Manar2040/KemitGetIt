import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kemit_get_it/features/guide/core/guide_profile_service.dart';
import 'package:kemit_get_it/features/guide/core/hold_request_service.dart';
import 'package:kemit_get_it/features/guide/core/notification_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/features/guide/screens/hold_request_details_screen.dart';
import 'package:kemit_get_it/features/guide/screens/hold_requests_list_screen.dart';
// import 'package:kemit_get_it/features/guide/screens/mytrips.dart';
import 'package:kemit_get_it/features/guide/screens/notification_screen.dart';
import 'package:kemit_get_it/features/guide/widgets/mytrips_widget_inhome.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HoldRequestModel> _requests = [];
  String _guideName = '';
  String _profileImageUrl = '';
  bool _isLoadingProfile = true;
  bool _isLoading = true;
  String? _error;
  int _unreadCount = 0; // ← عدد الإشعارات الغير مقروءة

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _loadProfile();
    _loadUnreadCount();
  }

  // ── Unread notifications count ────────────────────────────
  Future<void> _loadUnreadCount() async {
    try {
      final result = await NotificationService.getNotifications(pageSize: 50);
      if (mounted) {
        setState(() {
          _unreadCount = result.items.where((n) => !n.isRead).length;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await GuideProfileService.getProfile();
      if (mounted) {
        setState(() {
          _guideName =
              profile.displayName.isNotEmpty
                  ? profile.displayName
                  : '${profile.firstName} ${profile.lastName}'.trim().isNotEmpty
                  ? '${profile.firstName} ${profile.lastName}'.trim()
                  : profile.username;
          _profileImageUrl = profile.profileImageUrl;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint('❌ Status code: ${e.response?.statusCode}');
        debugPrint('❌ Response body: ${e.response?.data}');
      } else {
        debugPrint('❌ GuideProfile load error: $e');
      }
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await HoldRequestService.getRequests();
      if (mounted) {
        setState(() {
          _requests = data.where((r) => r.tripId != null).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load requests';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadRequests();
          await _loadUnreadCount();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        _profileImageUrl.isNotEmpty
                            ? NetworkImage(_profileImageUrl) as ImageProvider
                            : null,
                    child:
                        _profileImageUrl.isEmpty
                            ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 22,
                            )
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLoadingProfile ? 'Welcome' : 'Welcome, $_guideName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // ── Notification Bell with Badge ──
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                      // لما يرجع من الـ screen يعمل refresh للـ count
                      _loadUnreadCount();
                    },
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined, size: 26),
                        if (_unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _unreadCount > 99 ? '99+' : '$_unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── My Trips ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Active Trips',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ActiveTripsList(),
              const SizedBox(height: 24),

              // ── Hold Requests ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hold Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HoldRequestsListScreen(),
                          ),
                        ),
                    child: const Text(
                      'See All',
                      style: TextStyle(fontSize: 15, color: Color(0xFFB9975B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Color(0xFFB9975B)),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (_requests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No pending requests',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._requests
                    .take(2)
                    .map(
                      (req) => GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        HoldRequestDetailsScreen(request: req),
                              ),
                            ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE5DDD0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF888888),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      req.tripTitle ?? req.requestType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'From: ${req.touristName}',
                                      style: const TextStyle(
                                        color: Color(0xFF888888),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${req.totalPrice.toInt()} ${req.currency}',
                                    style: const TextStyle(
                                      color: Color(0xFFD97B2B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF8B6914),
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Review',
                                      style: TextStyle(
                                        color: Color(0xFF8B6914),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
