import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../../core/services/token_storage.dart';
import '../models/auth_models.dart';
/// Handles all authentication API calls.
///
/// Endpoints used:
///   POST /api/auth/register           → [register]
///   POST /api/auth/login              → [login]
///   POST /api/auth/refresh            → [refreshToken]
///   POST /api/auth/forgot-password    → [forgotPassword]
///   POST /api/auth/reset-password     → [resetPassword]
///   POST /api/auth/change-password    → [changePassword]  (auth required)
///   POST /api/auth/logout             → [logout]          (auth required)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  final _client = ApiClient.instance;
  // ── Register ──────────────────────────────────────────────────────────────────
  /// Registers a new tourist account.
  ///
  /// Throws [ApiException] on failure.
  /// On success returns the backend's [MessageResponse].
  Future<MessageResponse> register(RegisterRequest req) async {
    final data = await _client.post(
      ApiConstants.register,
      body: req.toJson(),
      auth: false,
    );
    return MessageResponse.fromJson(data as Map<String, dynamic>);
  }
  // ── Login ─────────────────────────────────────────────────────────────────────
  /// Authenticates the user and persists JWT + refresh token.
  ///
  /// Throws [ApiException] on failure.
  /// Returns the parsed [AuthResponse].
  Future<AuthResponse> login(LoginRequest req) async {
    final data = await _client.post(
      ApiConstants.login,
      body: req.toJson(),
      auth: false,
    );
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    // Persist tokens immediately so subsequent calls use them
    await TokenStorage.instance.saveTokens(
      accessToken:  response.accessToken,
      refreshToken: response.refreshToken,
      expiresAt:    response.expiresAt,
      userId:       response.user.id,
      username:     response.user.username,
      email:        response.user.email,
      role:         response.user.role,
    );
    return response;
  }
  // ── Refresh ───────────────────────────────────────────────────────────────────
  /// Exchanges the stored refresh token for a new access token.
  ///
  /// Automatically updates [TokenStorage] on success.
  /// Throws [ApiException] on failure (invalid/expired refresh token → 401).
  Future<AuthResponse> refreshToken() async {
    final stored = await TokenStorage.instance.refreshToken;
    if (stored == null) {
      throw const ApiException(
        statusCode: 401,
        title: 'Unauthorized',
        detail: 'No refresh token found. Please log in again.',
      );
    }
    final data = await _client.post(
      ApiConstants.refresh,
      body: RefreshTokenRequest(stored).toJson(),
      auth: false,
    );
    final response = AuthResponse.fromJson(data as Map<String, dynamic>);
    await TokenStorage.instance.saveTokens(
      accessToken:  response.accessToken,
      refreshToken: response.refreshToken,
      expiresAt:    response.expiresAt,
      userId:       response.user.id,
      username:     response.user.username,
      email:        response.user.email,
      role:         response.user.role,
    );
    return response;
  }
  // ── Forgot Password ───────────────────────────────────────────────────────────
  /// Always returns 200 on the backend (prevents user enumeration).
  Future<MessageResponse> forgotPassword(String email) async {
    final data = await _client.post(
      ApiConstants.forgotPassword,
      body: ForgotPasswordRequest(email).toJson(),
      auth: false,
    );
    return MessageResponse.fromJson(data as Map<String, dynamic>);
  }
  // ── Reset Password ────────────────────────────────────────────────────────────
  Future<MessageResponse> resetPassword(ResetPasswordRequest req) async {
    final data = await _client.post(
      ApiConstants.resetPassword,
      body: req.toJson(),
      auth: false,
    );
    return MessageResponse.fromJson(data as Map<String, dynamic>);
  }
  // ── Change Password (authenticated) ──────────────────────────────────────────
  Future<MessageResponse> changePassword(ChangePasswordRequest req) async {
    final data = await _client.post(
      ApiConstants.changePassword,
      body: req.toJson(),
      auth: true,
    );
    return MessageResponse.fromJson(data as Map<String, dynamic>);
  }
  // ── Logout ────────────────────────────────────────────────────────────────────
  /// Revokes the refresh token on the server, then clears local storage.
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout, auth: true);
    } catch (_) {
      // Even if the server call fails, clear local tokens
    } finally {
      await TokenStorage.instance.clearAll();
    }
  }
}
