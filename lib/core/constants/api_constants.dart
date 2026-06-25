import 'package:flutter/foundation.dart';

/// Central API configuration.
///
/// ⚠️  Change [baseUrl] to the Docker container address when deployed.
///     For local Android emulator use 10.0.2.2  (routes to host loopback).
///     For local iOS simulator use 127.0.0.1.
class ApiConstants {
  ApiConstants._();

  // ── Base URL ─────────────────────────────────────────────────────────────────
  static const String baseUrl = kIsWeb  ? 'http://localhost:5000': 'http://172.20.10.3:5000';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const String register       = '/api/auth/register';
  static const String login          = '/api/auth/login';
  static const String refresh        = '/api/auth/refresh';
  static const String verifyEmail    = '/api/auth/verify-email';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword  = '/api/auth/reset-password';
  static const String changePassword = '/api/auth/change-password';
  static const String logout         = '/api/auth/logout';
  static const String deviceRegisterToken = '/api/device/register-token';

  // ── Tourist profile ──────────────────────────────────────────────────────────
  static const String touristCompleteProfile = '/api/users/tourist/complete-profile';
  static const String touristProfile         = '/api/users/tourist/profile';
  static const String uploadProfileImage     = '/api/users/upload-profile-image';

  // ── Interests ────────────────────────────────────────────────────────────────
  static const String interests = '/api/interests';

  // ── Places ────────────────────────────────────────────────────────────────────
  /// GET /api/places?search=&category=&page=&pageSize=
  static const String places          = '/api/places';
  /// GET /api/places/{id}
  static String placeById(int id)     => '/api/places/$id';
  /// POST /api/places/{id}/favorite
  static String addFavorite(int id)   => '/api/places/$id/favorite';
  /// DELETE /api/places/{id}/favorite
  static String removeFavorite(int id)=> '/api/places/$id/favorite';
  /// GET /api/places/favorites
  static const String favorites       = '/api/places/favorites';

  // ── My Plan ───────────────────────────────────────────────────────────────────
  /// GET /api/myplan    [Authorize(Roles="Tourist")]
  static const String myPlan          = '/api/myplan';
  /// POST /api/myplan/add   body: {placeId}
  static const String myPlanAdd       = '/api/myplan/add';
  /// DELETE /api/myplan/{placeId}
  static String myPlanRemove(int id)  => '/api/myplan/$id';

  // ── Trips ─────────────────────────────────────────────────────────────────────
  /// GET /api/trips?type=&language=&page=&pageSize=
  static const String trips           = '/api/trips';
  /// GET /api/trips/{id}
  static String tripById(int id)      => '/api/trips/$id';

  // ── Reviews ───────────────────────────────────────────────────────────────────
  /// POST /api/reviews  [Authorize(Roles="Tourist")]
  static const String createReview         = '/api/reviews';
  /// GET /api/reviews/{id}
  static String reviewById(int id)         => '/api/reviews/$id';
  /// GET /api/reviews/guide/{guideUserId}?page=&pageSize=
  static String reviewsByGuide(int id)     => '/api/reviews/guide/$id';
  /// GET /api/reviews/trip/{tripId}?page=&pageSize=
  static String reviewsByTrip(int id)      => '/api/reviews/trip/$id';

  // ── Chat ─────────────────────────────────────────────────────────────────────
  static const String chatConversations      = '/api/chat/conversations';
  static String chatConversation(int id)     => '/api/chat/conversations/$id';
  static const String chatSearch             = '/api/chat/conversations/search';
  static String chatMessages(int convId)     => '/api/chat/conversations/$convId/messages';
  static String chatMarkRead(int convId, int msgId) => '/api/chat/conversations/$convId/messages/$msgId/read';
  static const String chatUnreadCount        = '/api/chat/messages/unread';
  static String chatClose(int convId)        => '/api/chat/conversations/$convId/close';
  static const String chatHub                = '/chathub';

/// ── Kemit AI Assistant ───────────────────────────────────────────────────────
  static const String aiBaseUrl              = 'https://gliding-outright-manhunt.ngrok-free.dev';
  static const String aiRecommend = '/api/places'; // Intercepts GetAllPlaces for AI re-ranking
  static const String kemitAiChatbot         = '$aiBaseUrl/api/chatbot';
  static const String aiChatHistory = '/api/ai-chat/history';
  static const String aiChatSend = '/api/ai-chat/send';
  // ── Notifications ────────────────────────────────────────────────────────────
  static const String notifications        = '/api/notifications';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static String notificationRead(int id)   => '/api/notifications/$id/read';

  // ── Request timeouts ─────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
