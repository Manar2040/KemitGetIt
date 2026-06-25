import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/features/guide/models/chat_model.dart';

class CreateTripService {
  static Future<TripModel> createTripWithImage({
    required CreateTripModel trip,
  }) async {
    final itineraryJson = jsonEncode(
      trip.itinerary
          .map(
            (d) => {
              'dayNumber': d.dayNumber,
              'title': d.dayTitle,
              'description': d.description,
            },
          )
          .toList(),
    );

    final coverImageFile = await MultipartFile.fromFile(
      trip.coverImage!.path,
      filename: trip.coverImage!.path.split('/').last,
    );

    final formData = FormData.fromMap({
      'Title': trip.tripName,
      'Description': trip.longDescription,
      'TripType':
          trip.selectedTripTypes.isNotEmpty ? trip.selectedTripTypes.first : '',
      'Location': trip.startingPoint,
      'LocationLat': trip.locationLat,
      'LocationLng': trip.locationLng,
      'StartingPoint': trip.startingPoint,
      'EndingPoint': trip.endingPoint,
      'StartDate': trip.startingDate!.toIso8601String(),
      'EndDate': trip.endingDate!.toIso8601String(),
      'Price': trip.price,
      'Currency': trip.currency,
      'MaxParticipants': trip.maxPersons,
      'Languages': trip.selectedLanguages,
      'ItineraryDays': itineraryJson,
      'CoverImage': coverImageFile,
    });

    try {
      final response = await ApiService.postMultipart('/api/trips', formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return TripModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw _toProblemDetails(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw _toProblemDetails(e.response!.data);
      }
      throw Exception('Network error while creating trip: ${e.message}');
    }
  }

  static Exception _toProblemDetails(dynamic data) {
    try {
      final map = data is String ? jsonDecode(data) : data;
      return ProblemDetails.fromJson(map as Map<String, dynamic>);
    } catch (_) {
      return Exception('Failed to create trip.');
    }
  }
}
