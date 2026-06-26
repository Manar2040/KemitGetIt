import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kemit_get_it/core/services/token_storage.dart';
import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

class GuideProfileService {
  // ── GET /api/users/guide/profile ───────────────────────────
  static Future<GuideProfileModel> getProfile() async {
    final response = await ApiService.get('/api/users/guide/profile');
    debugPrint(
      '🖼️ profileImageUrl: ${response.data['profileImageUrl']}',
    ); // ← ضيفي ده
    return GuideProfileModel.fromJson(response.data);
  }

  // ── PUT /api/users/guide/profile ───────────────────────────
  static Future<bool> updateProfile(
  UpdateGuideProfileRequest request,
) async {
  try {
    await ApiService.put(
      '/api/users/guide/profile',
      request.toJson(),
    );
    return true;
  } catch (e) {
    if (e is DioException) {
      debugPrint('❌ updateProfile status: ${e.response?.statusCode}');
      debugPrint('❌ updateProfile body: ${e.response?.data}');
    } else {
  debugPrint('❌ updateProfile error type: ${e.runtimeType}');
  debugPrint('❌ updateProfile error: $e');
}
    return false;
  }
}

  // ── POST /api/users/upload-profile-image ───────────────────
  // بيرجع الـ url الجديد للصورة لو نجح، أو null لو فشل
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          // ← بدل 'ProfileImage'
          imageFile.path,
          filename: 'profile.jpg',
        ),
      });
      final response = await ApiService.postMultipart(
        '/api/users/upload-profile-image',
        formData,
      );
      debugPrint('✅ upload response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        return data['profileImageUrl'] ?? data['url'] ?? data['imageUrl'];
      }
      return null;
    } catch (e) {
      if (e is DioException) {
        debugPrint('❌ Status: ${e.response?.statusCode}');
        debugPrint('❌ Body: ${e.response?.data}'); // ← ده اللي محتاجاه
      }
      return null;
    }
  }

  // ── POST /api/users/guide/submit-verification ──────────────
  static Future<GuideVerificationResponse?> submitVerification({
    required SubmitVerificationRequest request,
    required File idCardFile,
    required File personalPhotoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...request.toFields(),
        'IdCardFile': await MultipartFile.fromFile(
          idCardFile.path,
          filename: 'id_card.jpg',
        ),
        'PersonalPhotoFile': await MultipartFile.fromFile(
          personalPhotoFile.path,
          filename: 'personal_photo.jpg',
        ),
      });
      final response = await ApiService.postMultipart(
        '/api/users/guide/submit-verification',
        formData,
      );
      if (response.statusCode == 200) {
        return GuideVerificationResponse.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Logout: مسح التوكن من التخزين الآمن ─────────────────────
  static Future<void> logout() async {
    await TokenStorage.instance.clearAll();
  }
}
