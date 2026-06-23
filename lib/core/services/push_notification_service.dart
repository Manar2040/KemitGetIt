// lib/core/services/push_notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';
import 'token_storage.dart';
import '../../main.dart'; // for navigatorKey
import '../../routes/app_routes.dart';
import '../../shared/widgets/add_review_bottom_sheet.dart';
import '../../data/services/hold_request_service.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiClient _apiClient = ApiClient.instance;
  final TokenStorage _tokenStorage = TokenStorage.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Request permissions (primarily for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // ── Foreground: app is open ──────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground message: ${message.data}');
      // Foreground notifications are handled by in-app notification bell.
      // Deep-link navigation is intentionally NOT triggered here to avoid
      // interrupting the user's current flow.
    });

    // ── Background tap: user taps notification while app is in background ───
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM notification tapped (background): ${message.data}');
      handleDeepLink(message.data);
    });

    // ── Terminated tap: app was closed, user taps notification ──────────────
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM notification tapped (terminated): ${initialMessage.data}');
      // Small delay so Navigator is ready after app launch
      Future.delayed(const Duration(milliseconds: 500), () {
        handleDeepLink(initialMessage.data);
      });
    }

    // Handle token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
      _sendTokenToBackend(newToken);
    });

    _initialized = true;

    // Send initial token to backend if logged in
    await checkAndSendToken();
  }

  // ── Deep Link Router ────────────────────────────────────────────────────────
  /// Routes the user to the correct screen based on FCM notification type.
  ///
  /// Types defined in the KemitGetIt scenario:
  ///   RateTrip          → Opens AddReviewBottomSheet (referenceId = bookingId)
  ///   PaymentRequired   → Opens Payment screen (referenceId = holdRequestId)
  ///   BookingPaid       → Opens chat/booking detail (referenceId = bookingId)
  ///   HoldRequest       → Opens My Requests screen (referenceId = holdRequestId)
  ///   BookingCancelled  → Opens My Requests screen
  ///   TripCancelled     → Opens My Requests screen
  ///   WalletCredit      → (Guide only) — no action on tourist side
  void handleDeepLink(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final referenceIdStr = data['referenceId'] as String?;
    final referenceId = referenceIdStr != null ? int.tryParse(referenceIdStr) : null;

    debugPrint('FCM Deep Link → type: $type, referenceId: $referenceId');

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    switch (type) {
      case 'RateTrip':
        // Open review sheet. referenceId = bookingId
        if (referenceId != null) {
          _openRatingScreen(navigator, bookingId: referenceId);
        }
        break;

      case 'PaymentRequired':
        // referenceId = holdRequestId → navigate directly to payment screen
        if (referenceId != null) {
          _openPaymentScreen(navigator, holdRequestId: referenceId);
        }
        break;

      case 'BookingPaid':
        // referenceId = bookingId → go to chats (conversation auto-created on payment)
        navigator.pushNamed(AppRoutes.chatsList);
        break;

      case 'HoldRequest':
      case 'BookingCancelled':
      case 'TripCancelled':
        // referenceId = holdRequestId → show my requests
        navigator.pushNamed(AppRoutes.myRequests);
        break;

      default:
        // Unknown or Guide-only type — navigate to home
        debugPrint('FCM: Unknown notification type "$type" — no navigation.');
        break;
    }
  }

  /// Opens the rating bottom sheet on top of the current screen.
  /// Fetches guideUserId from the booking record using [bookingId].
  Future<void> _openRatingScreen(NavigatorState navigator, {required int bookingId}) async {
    try {
      // Get the booking details to find guideUserId and tripId
      final response = await _apiClient.get(
        '/api/bookings/my-bookings',
        auth: true,
      );

      int? guideUserId;
      int? tripId;

      if (response is List) {
        for (var item in response) {
          if (item is Map && item['id'] == bookingId) {
            guideUserId = item['guideUserId'] as int?;
            tripId = item['tripId'] as int?;
            break;
          }
        }
      }

      // Navigate to My Requests first so user has context
      navigator.pushNamed(AppRoutes.myRequests);

      // Wait for the route to settle before showing the bottom sheet
      await Future.delayed(const Duration(milliseconds: 400));

      final ctx = navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;

      // Capture messenger before await
      final messenger = ScaffoldMessenger.of(ctx);

      final result = await AddReviewBottomSheet.show(
        ctx,
        bookingId: bookingId,
        guideUserId: guideUserId,
        tripId: tripId,
      );

      if (result == true) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully! Thank you 🌟'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('FCM RateTrip: Failed to open rating screen — $e');
    }
  }

  /// Opens the payment screen with the necessary request details.
  Future<void> _openPaymentScreen(NavigatorState navigator, {required int holdRequestId}) async {
    try {
      final req = await HoldRequestsService.instance.getRequestDetails(holdRequestId);
      
      // Ensure it is still in a state that requires payment
      final status = req.status.toLowerCase();
      if (status == 'accepted' || status == 'paymentpending') {
        navigator.pushNamed(
          AppRoutes.payment,
          arguments: {
            'holdRequestId': req.id,
            'guideName': req.guideName ?? '',
            'totalPrice': req.totalPrice,
            'currency': req.currency ?? 'EGP',
          },
        );
      } else {
        navigator.pushNamed(AppRoutes.myRequests);
      }
    } catch (e) {
      debugPrint('FCM PaymentRequired: Failed to open payment screen — $e');
      navigator.pushNamed(AppRoutes.myRequests);
    }
  }

  // ── Token Management ────────────────────────────────────────────────────────

  /// Called after successful login or app startup to sync token with backend.
  Future<void> checkAndSendToken() async {
    final isLoggedIn = await _tokenStorage.hasValidSession;
    if (isLoggedIn) {
      try {
        final fcmToken = await _fcm.getToken();
        if (fcmToken != null) {
          debugPrint('FCM Token Retrieved: $fcmToken');
          await _sendTokenToBackend(fcmToken);
        }
      } catch (e) {
        debugPrint('Failed to get FCM token: $e');
      }
    }
  }

  Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      await _apiClient.post(
        ApiConstants.deviceRegisterToken,
        body: {'fcmToken': fcmToken},
        auth: true,
      );
      debugPrint('FCM token sent to backend successfully.');
    } catch (e) {
      debugPrint('Failed to send FCM token to backend: $e');
    }
  }
}
