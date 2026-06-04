import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../models/tourist_models.dart';
/// Tourist-specific API calls.
///
/// ALL endpoints require [Authorize(Roles="Tourist")] on the backend.
/// The [ApiClient] will automatically attach the Bearer token.
class TouristProfileService {
  TouristProfileService._();
  static final TouristProfileService instance = TouristProfileService._();
  final _client = ApiClient.instance;
  // ── Interests ─────────────────────────────────────────────────────────────────
  /// GET /api/interests  [Authorize]
  ///
  /// Returns the list of available interest categories.
  /// The profile-completion form should call this to show real interest options
  /// (with real [InterestDto.id] values) instead of hardcoded strings.
  Future<List<InterestDto>> getInterests() async {
    final data = await _client.get(ApiConstants.interests, auth: true);
    final list = data as List;
    return list.map((e) => InterestDto.fromJson(e as Map<String, dynamic>)).toList();
  }
  // ── Complete profile (first-time onboarding) ──────────────────────────────────
  /// POST /api/users/tourist/complete-profile  [Authorize(Roles="Tourist")]
  Future<CompleteTouristProfileResponse> completeProfile(
    CompleteTouristProfileRequest req,
  ) async {
    final data = await _client.post(
      ApiConstants.touristCompleteProfile,
      body: req.toJson(),
      auth: true,
    );
    return CompleteTouristProfileResponse.fromJson(data as Map<String, dynamic>);
  }
  // ── Get profile ───────────────────────────────────────────────────────────────
  /// GET /api/users/tourist/profile  [Authorize(Roles="Tourist")]
  Future<TouristProfileResponse> getProfile() async {
    final data = await _client.get(ApiConstants.touristProfile, auth: true);
    return TouristProfileResponse.fromJson(data as Map<String, dynamic>);
  }
  // ── Update profile ────────────────────────────────────────────────────────────
  /// PUT /api/users/tourist/profile  [Authorize(Roles="Tourist")]
  Future<void> updateProfile(UpdateTouristProfileRequest req) async {
    await _client.put(
      ApiConstants.touristProfile,
      body: req.toJson(),
      auth: true,
    );
  }
  // ── Upload profile image ──────────────────────────────────────────────────────
  /// POST /api/users/upload-profile-image  [Authorize]   multipart/form-data
  ///
  /// Returns the relative URL of the uploaded image.
  Future<String> uploadProfileImage(String filePath) async {
    final data = await _client.postMultipart(
      ApiConstants.uploadProfileImage,
      {},
      filePath:  filePath,
      fileField: 'file',
      auth:      true,
    );
    final map = data as Map<String, dynamic>;
    return map['url'] as String;
  }
}
