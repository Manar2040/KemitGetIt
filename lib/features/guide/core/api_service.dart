import 'package:dio/dio.dart';
import 'package:kemit_get_it/core/constants/api_constants.dart';
import 'auth_service.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:5000';
  //static const String baseUrl = 'http://192.168.237.161:5000';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Options> _authOptions() async {
    final token = await AuthService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  static Future<Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final options = requiresAuth ? await _authOptions() : Options();
    return await _dio.get(endpoint, options: options);
  }

  static Future<Response> post(
    String endpoint,
    dynamic data, {
    bool requiresAuth = true,
  }) async {
    final options = requiresAuth ? await _authOptions() : Options();
    return await _dio.post(endpoint, data: data, options: options);
  }

  static Future<Response> put(
    String endpoint,
    dynamic data, {
    bool requiresAuth = true,
  }) async {
    final options = requiresAuth ? await _authOptions() : Options();
    return await _dio.put(endpoint, data: data, options: options);
  }

  static Future<Response> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final options = requiresAuth ? await _authOptions() : Options();
    return await _dio.delete(endpoint, options: options);
  }

  static Future<Response> postMultipart(
    String endpoint,
    FormData formData,
  ) async {
    final token = await AuthService.getToken();
    return await _dio.post(
      endpoint,
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<Response> putMultipart(
    String endpoint,
    FormData formData,
  ) async {
    final token = await AuthService.getToken();
    return await _dio.put(
      endpoint,
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
