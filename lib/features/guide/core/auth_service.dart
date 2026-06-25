import 'package:kemit_get_it/core/services/token_storage.dart';
import 'package:kemit_get_it/data/services/auth_service.dart' as data_auth;

class AuthService {
  // جيب الـ access token (مع تجديد تلقائي لو قرب ينتهي)
  static Future<String?> getToken() async {
    final isExpired = await TokenStorage.instance.isTokenExpired;

    if (isExpired) {
      try {
        await data_auth.AuthService.instance.refreshToken();
      } catch (_) {
        // الـ refresh token نفسه منتهي/غير صالح
        // هنسيب الكود يكمل، الـ API هترجع 401 والـ interceptor
        // في ApiClient هيتعامل معاها بتسجيل خروج المستخدم
      }
    }

    return await TokenStorage.instance.accessToken;
  }

  // جيب الـ role
  static Future<String?> getRole() async {
    return await TokenStorage.instance.role;
  }

  // هل اليوزر logged in؟
  static Future<bool> isLoggedIn() async {
    return await TokenStorage.instance.hasValidSession;
  }

  // Logout
  static Future<void> logout() async {
    await TokenStorage.instance.clearAll();
  }
}