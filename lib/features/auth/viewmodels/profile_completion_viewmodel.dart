import 'package:flutter/material.dart';
import 'package:kemit_get_it/core/services/api_client.dart';
import 'package:kemit_get_it/data/models/tourist_models.dart';
import 'package:kemit_get_it/data/services/tourist_profile_service.dart';

import 'package:image_picker/image_picker.dart';

/// State for the tourist profile-completion (onboarding) screen.
class ProfileCompletionViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isLoadingInterests = false;
  String? errorMessage;
  List<InterestDto> availableInterests = [];
  Set<int> selectedInterestIds = {};
  bool profileCompleted = false;
  CompleteTouristProfileResponse? completedProfile;
  
  String? selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  // ── Load interests from the backend ──────────────────────────────────────────
  Future<void> loadInterests() async {
    isLoadingInterests = true;
    errorMessage = null;
    notifyListeners();
    try {
      availableInterests = await TouristProfileService.instance.getInterests();
    } on ApiException catch (e) {
      errorMessage = 'Could not load interests: ${e.userMessage}';
    } catch (_) {
      errorMessage = 'Could not load interests. Check your connection.';
    } finally {
      isLoadingInterests = false;
      notifyListeners();
    }
  }
  
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        selectedImagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  void toggleInterest(int id) {
    if (selectedInterestIds.contains(id)) {
      selectedInterestIds.remove(id);
    } else {
      selectedInterestIds.add(id);
    }
    notifyListeners();
  }
  
  void setError(String message) {
    errorMessage = message;
    notifyListeners();
  }
  
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
  
  // ── Submit profile ────────────────────────────────────────────────────────────
  Future<void> completeProfile({
    required String phone,
    required int age,
    required String country,
    required String language,
  }) async {
    errorMessage = null;
    notifyListeners();
    if (selectedInterestIds.isEmpty) {
      errorMessage = 'Please select at least one interest';
      notifyListeners();
      return;
    }
    isLoading = true;
    notifyListeners();
    try {
      completedProfile = await TouristProfileService.instance.completeProfile(
        CompleteTouristProfileRequest(
          phone:       phone,
          age:         age,
          country:     country,
          language:    language,
          interestIds: selectedInterestIds.toList(),
        ),
      );
      
      if (selectedImagePath != null) {
        await TouristProfileService.instance.uploadProfileImage(selectedImagePath!);
      }
      
      profileCompleted = true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (_) {
      errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}