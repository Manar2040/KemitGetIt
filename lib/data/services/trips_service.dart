import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../models/trip_models.dart';

/// Real API service for Trips.
class TripsService {
  TripsService._();
  static final TripsService instance = TripsService._();
  final _client = ApiClient.instance;

  // ── Browse Published Trips ──────────────────────────────────────────────────
  /// GET /api/trips?type=&language=&page=&pageSize=
  Future<TripPagedResult> getPublishedTrips({
    String? type,
    String? language,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = {
      if (type != null && type.isNotEmpty) 'type': type,
      if (language != null && language.isNotEmpty) 'language': language,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    final data = await _client.get(
      ApiConstants.trips,
      queryParams: queryParams,
      auth: false, // AllowAnonymous
    );
    return TripPagedResult.fromJson(data as Map<String, dynamic>);
  }

  // ── Trip Details ─────────────────────────────────────────────────────────────
  /// GET /api/trips/{id}
  Future<TripDetails> getTripById(int id) async {
    final data = await _client.get(
      ApiConstants.tripById(id),
      auth: false, // AllowAnonymous
    );
    return TripDetails.fromJson(data as Map<String, dynamic>);
  }
}
