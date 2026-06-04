// ============================================================
// Auth DTOs – mirror the C# models in KemitGetit.Application.DTOs.Auth
// JSON keys follow the ASP.NET Core default camelCase serializer policy.
// ============================================================
// ── Request models ────────────────────────────────────────────────────────────
/// POST /api/auth/register
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  /// Must be "tourist" or "guide" (case-insensitive on backend).
  final String role;
  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.role = 'tourist',
  });
  Map<String, dynamic> toJson() => {
    'username': username,
    'email':    email,
    'password': password,
    'role':     role,
  };
}
/// POST /api/auth/login
class LoginRequest {
  final String email;
  final String password;
  const LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
/// POST /api/auth/refresh
class RefreshTokenRequest {
  final String refreshToken;
  const RefreshTokenRequest(this.refreshToken);
  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
/// POST /api/auth/forgot-password
class ForgotPasswordRequest {
  final String email;
  const ForgotPasswordRequest(this.email);
  Map<String, dynamic> toJson() => {'email': email};
}
/// POST /api/auth/reset-password
class ResetPasswordRequest {
  final String userId;
  final String token;
  final String newPassword;
  const ResetPasswordRequest({
    required this.userId,
    required this.token,
    required this.newPassword,
  });
  Map<String, dynamic> toJson() => {
    'userId':      userId,
    'token':       token,
    'newPassword': newPassword,
  };
}
/// POST /api/auth/change-password  [Authorize]
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });
  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword':     newPassword,
  };
}
// ── Response models ───────────────────────────────────────────────────────────
/// Nested inside [AuthResponse] — maps to C# UserDto.
class AuthUserDto {
  final int    id;
  final String username;
  final String email;
  final String role;  // "Tourist" | "Guide"
  const AuthUserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });
  factory AuthUserDto.fromJson(Map<String, dynamic> j) => AuthUserDto(
    id:       j['id']       as int,
    username: j['username'] as String,
    email:    j['email']    as String,
    role:     j['role']     as String,
  );
}
/// Response for POST /api/auth/login  and  POST /api/auth/refresh
/// Maps to C# AuthResponseDto.
class AuthResponse {
  final String      accessToken;
  final String      refreshToken;
  final DateTime    expiresAt;
  final AuthUserDto user;
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });
  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
    accessToken:  j['accessToken']  as String,
    refreshToken: j['refreshToken'] as String,
    expiresAt:    DateTime.parse(j['expiresAt'] as String),
    user:         AuthUserDto.fromJson(j['user'] as Map<String, dynamic>),
  );
}
/// Simple message wrapper returned by register, logout, verify-email, etc.
class MessageResponse {
  final String message;
  const MessageResponse(this.message);
  factory MessageResponse.fromJson(Map<String, dynamic> j) =>
      MessageResponse(j['message'] as String? ?? '');
}