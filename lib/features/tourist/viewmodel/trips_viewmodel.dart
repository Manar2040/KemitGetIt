import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../data/models/trip_models.dart';
import '../../../data/services/trips_service.dart';

/// ViewModel for browsing Published Trips (Tourists).
class TripsViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<TripSummary> trips = [];
  int currentPage = 1;
  bool hasMore = true;

  Future<void> loadTrips({
    String? type,
    String? language,
    bool refresh = false,
  }) async {
    if (refresh) {
      currentPage = 1;
      hasMore = true;
      trips = [];
    }
    if (!hasMore || isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await TripsService.instance.getPublishedTrips(
        type: type,
        language: language,
        page: currentPage,
      );
      trips.addAll(result.items);
      hasMore = trips.length < result.totalCount;
      currentPage++;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (_) {
      errorMessage = 'Could not load trips. Check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

/// ViewModel for Trip Details.
class TripDetailsViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  TripDetails? trip;

  Future<void> loadTripDetails(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      trip = await TripsService.instance.getTripById(id);
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (_) {
      errorMessage = 'Could not load trip details.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
