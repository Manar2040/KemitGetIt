import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kemit_get_it/core/constants/api_constants.dart';
import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

class TripService {
  // ── resolve image url ──────────────────────────────────────
  static String resolveImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('/')) {
      return '${ApiConstants.baseUrl}$trimmed';
    }
    return trimmed;
  }

  // ── GET /api/trips/my-trips ────────────────────────────────
  static Future<List<ActiveTripModel>> getMyTrips({String? status}) async {
    final endpoint =
        status != null
            ? '/api/trips/my-trips?status=$status'
            : '/api/trips/my-trips';
    final response = await ApiService.get(endpoint);
    final List data = response.data as List;
    return data.map((e) => ActiveTripModel.fromJson(e)).toList();
  }

  static Future<List<ActiveTripModel>> getActiveTrips() async {
    return getMyTrips(status: 'active');
  }

  // ── GET /api/trips ─────────────────────────────────────────
  static Future<List<TripModel>> getTrips() async {
    final response = await ApiService.get('/api/trips');
    final List data = response.data as List;
    return data.map((e) => TripModel.fromJson(e)).toList();
  }

  // ── GET /api/trips/{id} ────────────────────────────────────
  static Future<TripDetailsModel> getTripById(int id) async {
    final response = await ApiService.get('/api/trips/$id');
    return TripDetailsModel.fromJson(response.data);
  }

  // ── POST /api/trips ────────────────────────────────────────
  static Future<TripDetailsModel?> createTrip(CreateTripRequest request) async {
    try {
      final response = await ApiService.post('/api/trips', request.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TripDetailsModel.fromJson(response.data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── PUT /api/trips/{id} ────────────────────────────────────
  static Future<TripDetailsModel?> updateTrip(
    int id,
    CreateTripRequest request,
  ) async {
    try {
      final response = await ApiService.put('/api/trips/$id', request.toJson());

      // ✅ أضف debug logging
      debugPrint('updateTrip status: ${response.statusCode}');
      debugPrint('updateTrip data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TripDetailsModel.fromJson(response.data);
      }
      return null;
    } catch (e, stack) {
      // ✅ اطبع الـ error الحقيقي بدل ما تـswallow الـ exception
      debugPrint('updateTrip error: $e');
      debugPrint('updateTrip stack: $stack');
      return null;
    }
  }

  // ── POST /api/trips/{id}/cover-image ──────────────────────
  static Future<bool> uploadCoverImage({
    required int tripId,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'CoverImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'cover.jpg',
        ),
      });
      final response = await ApiService.postMultipart(
        '/api/trips/$tripId/cover-image',
        formData,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── POST /api/trips/{id}/images ────────────────────────────
  static Future<bool> uploadTripImages(int id, List<String> imagePaths) async {
    try {
      final formData = FormData.fromMap({
        'images':
            imagePaths.map((path) => MultipartFile.fromFileSync(path)).toList(),
      });
      final response = await ApiService.postMultipart(
        '/api/trips/$id/images',
        formData,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── أنشئ تريب + ارفع الصورة في خطوة واحدة ────────────────
  static Future<TripDetailsModel?> createTripWithImage({
    required CreateTripRequest request,
    required File coverImage,
  }) async {
    final created = await createTrip(request);
    if (created == null) return null;
    await uploadCoverImage(tripId: created.id, imageFile: coverImage);
    return created;
  }

  // ── PUT /api/trips/{id}/publish ────────────────────────────
  static Future<bool> publishTrip(int id) async {
    try {
      final response = await ApiService.put('/api/trips/$id/publish', {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── PUT /api/trips/{id}/complete ───────────────────────────
  static Future<bool> completeTrip(int id) async {
    try {
      final response = await ApiService.put('/api/trips/$id/complete', {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── PUT /api/trips/{id}/cancel ─────────────────────────────
  static Future<bool> cancelTrip(int id) async {
    try {
      final response = await ApiService.put('/api/trips/$id/cancel', {});
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── DELETE /api/trips/{id} ─────────────────────────────────
  static Future<bool> deleteTrip(int id) async {
    try {
      final response = await ApiService.delete('/api/trips/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
