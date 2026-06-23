import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import 'token_storage.dart';
import '../../main.dart';
import '../../routes/app_routes.dart';
/// Custom exception that carries the structured error the backend returns.
///
/// The backend wraps ALL errors in the RFC-7807 ProblemDetails format:
/// ```json
/// {
///   "type":    "https://...",
///   "title":   "Bad Request",
///   "status":  400,
///   "detail":  "Email is already registered.",
///   "traceId": "..."
/// }
/// ```
/// For FluentValidation 400s the backend also returns ASP.NET's default
/// validation error body:
/// ```json
/// { "errors": { "Email": ["A valid email address is required."] } }
/// ```
class ApiException implements Exception {
  final int statusCode;
  final String title;
  final String detail;
  final Map<String, List<String>>? validationErrors;
  const ApiException({
    required this.statusCode,
    required this.title,
    required this.detail,
    this.validationErrors,
  });
  /// Returns the most user-friendly message available.
  String get userMessage {
    if (validationErrors != null && validationErrors!.isNotEmpty) {
      return validationErrors!.values.expand((e) => e).join('\n');
    }
    return detail.isNotEmpty ? detail : title;
  }
  @override
  String toString() => 'ApiException($statusCode): $title – $detail';
}
/// Thin HTTP client that:
///   1. Attaches [Authorization: Bearer <token>] on every protected request.
///   2. Parses both ProblemDetails and FluentValidation error bodies.
///   3. Throws [ApiException] on non-2xx responses.
///   4. Throws [ApiException] with status -1 on network / timeout errors.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();
  final _base = Uri.parse(ApiConstants.baseUrl);
  // ── Helpers ──────────────────────────────────────────────────────────────────
  Uri _uri(String path) => _base.replace(path: path);
  Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader:      'application/json',
    };
    if (auth) {
      final token = await TokenStorage.instance.accessToken;
      if (token != null) h[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return h;
  }
  /// Parses the response body and throws [ApiException] if status >= 400.
  dynamic _handle(http.Response response) {
    final body = response.body.isEmpty ? '{}' : response.body;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      return json.decode(body);
    }
    if (response.statusCode == 401) {
      _handleUnauthorized();
    }

    // Try to parse structured error
    try {
      final map = json.decode(body) as Map<String, dynamic>;
      // FluentValidation / DataAnnotations validation response
      if (map.containsKey('errors')) {
        final raw = map['errors'] as Map<String, dynamic>;
        final valErrors = raw.map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
        );
        throw ApiException(
          statusCode:       response.statusCode,
          title:            map['title'] as String? ?? 'Validation Error',
          detail:           '',
          validationErrors: valErrors,
        );
      }
      // ProblemDetails / custom error wrapper
      String errorDetail = map['detail'] as String? ?? map['message'] as String? ?? map['error'] as String? ?? body;
      if (errorDetail == '{}') {
        if (response.statusCode == 401) {
          errorDetail = 'Session expired or unauthorized. Please log in again.';
        } else if (response.statusCode == 403) {
          errorDetail = 'You do not have permission to access this.';
        } else {
          errorDetail = 'Error ${response.statusCode}: Something went wrong.';
        }
      }

      throw ApiException(
        statusCode: response.statusCode,
        title:      map['title'] as String? ?? 'Error',
        detail:     errorDetail,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        statusCode: response.statusCode,
        title:      'Error ${response.statusCode}',
        detail:     body,
      );
    }
  }
  // ── Public HTTP verbs ────────────────────────────────────────────────────────
  Future<dynamic> get(
    String path, {
    bool auth = true,
    Map<String, String>? query,
    Map<String, String>? queryParams,
  }) async {
    final q = queryParams ?? query;
    final uri = q != null ? _uri(path).replace(queryParameters: q) : _uri(path);
    try {
      final response = await http
          .get(uri, headers: await _headers(auth: auth))
          .timeout(ApiConstants.receiveTimeout);
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, title: 'Network Error', detail: e.toString());
    }
  }
  Future<dynamic> post(String path, {dynamic body, bool auth = false}) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: await _headers(auth: auth),
            body:    body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.receiveTimeout);
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, title: 'Network Error', detail: e.toString());
    }
  }
  Future<dynamic> put(String path, {dynamic body, bool auth = true}) async {
    try {
      final response = await http
          .put(
            _uri(path),
            headers: await _headers(auth: auth),
            body:    body != null ? json.encode(body) : null,
          )
          .timeout(ApiConstants.receiveTimeout);
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, title: 'Network Error', detail: e.toString());
    }
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    try {
      final response = await http
          .delete(_uri(path), headers: await _headers(auth: auth))
          .timeout(ApiConstants.receiveTimeout);
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, title: 'Network Error', detail: e.toString());
    }
  }
  Future<dynamic> postMultipart(
    String path,
    Map<String, String> fields, {
    String? filePath,
    String fileField = 'file',
    bool auth = true,
  }) async {
    try {
      final headers = await _headers(auth: auth);
      // Remove Content-Type – multipart sets its own boundary
      headers.remove(HttpHeaders.contentTypeHeader);
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(headers)
        ..fields.addAll(fields);
      if (filePath != null) {
        MediaType? contentType;
        if (filePath.toLowerCase().endsWith('.png')) {
          contentType = MediaType('image', 'png');
        } else if (filePath.toLowerCase().endsWith('.jpg') || filePath.toLowerCase().endsWith('.jpeg')) {
          contentType = MediaType('image', 'jpeg');
        }
        
        request.files.add(await http.MultipartFile.fromPath(
          fileField, 
          filePath,
          contentType: contentType,
        ));
      }
      final streamed = await request.send().timeout(ApiConstants.receiveTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(statusCode: -1, title: 'Network Error', detail: e.toString());
    }
  }

  void _handleUnauthorized() async {
    await TokenStorage.instance.clearAll();
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }
}
