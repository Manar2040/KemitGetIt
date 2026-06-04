import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../data/models/tourist_models.dart';
import '../../../data/services/tourist_profile_service.dart';

/// ViewModel for the tourist Profile and Edit-Profile screens.
///
/// Replaces the old MockProfileRepository with live TouristProfileService calls.
class TouristProfileViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSaving = false;
  bool isUploadingImage = false;
  String? errorMessage;
  TouristProfileResponse? profile;

  // ── Load profile ─────────────────────────────────────────────────────────────
  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await TouristProfileService.instance.getProfile();
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (_) {
      errorMessage = 'Could not load profile. Please check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Update profile ────────────────────────────────────────────────────────────
  /// Returns true on success so the view can navigate / show a success message.
  Future<bool> updateProfile(UpdateTouristProfileRequest req) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await TouristProfileService.instance.updateProfile(req);
      // Refresh the local profile so the profile screen shows updated data
      await loadProfile();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      return false;
    } catch (_) {
      errorMessage = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ── Upload profile image ──────────────────────────────────────────────────────
  /// Picks an image file from [filePath] and uploads it.
  /// Updates [profile.profileImageUrl] on success.
  Future<bool> uploadProfileImage(String filePath) async {
    isUploadingImage = true;
    errorMessage = null;
    notifyListeners();
    try {
      final url = await TouristProfileService.instance.uploadProfileImage(filePath);
      // Update the local copy so the UI refreshes without a full reload
      if (profile != null) {
        profile = TouristProfileResponse(
          id: profile!.id,
          userId: profile!.userId,
          username: profile!.username,
          email: profile!.email,
          phoneNumber: profile!.phoneNumber,
          firstName: profile!.firstName,
          lastName: profile!.lastName,
          gender: profile!.gender,
          aboutText: profile!.aboutText,
          experienceText: profile!.experienceText,
          age: profile!.age,
          touristTypePreference: profile!.touristTypePreference,
          countryOfResidence: profile!.countryOfResidence,
          preferredLanguage: profile!.preferredLanguage,
          profileImageUrl: url,
          interests: profile!.interests,
        );
      }
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      return false;
    } catch (_) {
      errorMessage = 'Image upload failed. Please try again.';
      return false;
    } finally {
      isUploadingImage = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  /// Helper: display name derived from firstName + lastName or fallback to username.
  String get displayName {
    if (profile == null) return '';
    final first = profile!.firstName ?? '';
    final last = profile!.lastName ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : (profile!.username ?? '');
  }
}
