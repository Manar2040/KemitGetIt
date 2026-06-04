import 'package:flutter/material.dart';
import '../../../data/models/hold_request_models.dart';
import '../../../data/services/hold_request_service.dart';
import '../../../core/services/api_client.dart';

class HoldRequestViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSending = false;
  String? errorMessage;
  
  List<HoldRequestDto> myRequests = [];
  HoldRequestDto? currentRequest;

  // Temporary form data for Private Trips
  String tripType = 'Solo';
  String preferredLanguage = 'English';
  int numberOfTravelers = 1;
  String transportPreference = 'PrivateCar';
  bool accommodationNeeded = false;
  bool mealsIncluded = false;
  DateTime? startDate;
  DateTime? endDate;

  void updateFormData({
    String? tripType,
    String? preferredLanguage,
    int? numberOfTravelers,
    String? transportPreference,
    bool? accommodationNeeded,
    bool? mealsIncluded,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (tripType != null) this.tripType = tripType;
    if (preferredLanguage != null) this.preferredLanguage = preferredLanguage;
    if (numberOfTravelers != null) this.numberOfTravelers = numberOfTravelers;
    if (transportPreference != null) this.transportPreference = transportPreference;
    if (accommodationNeeded != null) this.accommodationNeeded = accommodationNeeded;
    if (mealsIncluded != null) this.mealsIncluded = mealsIncluded;
    if (startDate != null) this.startDate = startDate;
    if (endDate != null) this.endDate = endDate;
    notifyListeners();
  }

  Future<bool> sendRequest(SendHoldRequestDto request) async {
    isSending = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await HoldRequestsService.instance.sendRequest(request);
      currentRequest = res;
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      return false;
    } catch (_) {
      errorMessage = 'Failed to send trip request.';
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> loadMyRequests() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      myRequests = await HoldRequestsService.instance.getMyRequests();
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (_) {
      errorMessage = 'Failed to load requests.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
