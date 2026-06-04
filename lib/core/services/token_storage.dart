import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/// Manages JWT access + refresh token persistence securely on the device.
///
/// Storage keys mirror exactly what the backend returns in [AuthResponseDto]:
///   accessToken  → Bearer token for Authorization headers
///   refreshToken → Used by POST /api/auth/refresh
///   userId       → int – stored as string
///   username
///   email
///   role         → "Tourist" | "Guide"
///   expiresAt    → ISO-8601 DateTime string
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();
  static const _store = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  // Key constants
  static const _kAccessToken  = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kExpiresAt    = 'expires_at';
  static const _kUserId       = 'user_id';
  static const _kUsername     = 'username';
  static const _kEmail        = 'email';
  static const _kRole         = 'role';
  // ── Write ─────────────────────────────────────────────────────────────────────
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required int userId,
    required String username,
    required String email,
    required String role,
  }) async {
    await Future.wait([
      _store.write(key: _kAccessToken,  value: accessToken),
      _store.write(key: _kRefreshToken, value: refreshToken),
      _store.write(key: _kExpiresAt,    value: expiresAt.toIso8601String()),
      _store.write(key: _kUserId,       value: userId.toString()),
      _store.write(key: _kUsername,     value: username),
      _store.write(key: _kEmail,        value: email),
      _store.write(key: _kRole,         value: role),
    ]);
  }
  // ── Read ──────────────────────────────────────────────────────────────────────
  Future<String?> get accessToken  => _store.read(key: _kAccessToken);
  Future<String?> get refreshToken => _store.read(key: _kRefreshToken);
  Future<String?> get role         => _store.read(key: _kRole);
  Future<String?> get username     => _store.read(key: _kUsername);
  Future<String?> get email        => _store.read(key: _kEmail);
  Future<int?>    get userId       async {
    final v = await _store.read(key: _kUserId);
    return v != null ? int.tryParse(v) : null;
  }
  Future<bool> get isTokenExpired async {
    final raw = await _store.read(key: _kExpiresAt);
    if (raw == null) return true;
    final expiry = DateTime.tryParse(raw);
    if (expiry == null) return true;
    // Treat as expired 60 s before actual expiry to allow refresh time
    return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 60)));
  }
  Future<bool> get hasValidSession async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }
  // ── Delete ────────────────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    await Future.wait([
      _store.delete(key: _kAccessToken),
      _store.delete(key: _kRefreshToken),
      _store.delete(key: _kExpiresAt),
      _store.delete(key: _kUserId),
      _store.delete(key: _kUsername),
      _store.delete(key: _kEmail),
      _store.delete(key: _kRole),
    ]);
  }
}
