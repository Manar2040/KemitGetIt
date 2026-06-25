import 'package:dio/dio.dart';
import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/verification_model.dart';

class GuideVerificationService {
  static const String _endpoint = '/api/users/guide/submit-verification';

  /// Submits guide verification documents during first-time onboarding.
  ///
  /// [phone] - Guide's phone number (e.g. "01012345678")
  /// [bio] - Short professional bio
  /// [specializations] - List of specializations (e.g. ["Historical", "Cultural"])
  /// [workingRegions] - List of working regions (e.g. ["Cairo", "Luxor"])
  /// [idCardFilePath] - Absolute path to the ID card image (.jpg, .jpeg, .png, or .pdf — max 5 MB)
  /// [personalPhotoFilePath] - Absolute path to the personal photo (.jpg, .jpeg, or .png — max 5 MB)
  static Future<GuideVerificationResponse> submitVerification({
    required String phone,
    required String bio,
    required List<String> specializations,
    required List<String> workingRegions,
    required String idCardFilePath,
    required String personalPhotoFilePath,
  }) async {
    final formData = FormData.fromMap({
      'Phone': phone,
      'Bio': bio,
      'Specialization': specializations.join(','),
      'WorkingRegions': workingRegions.join(','),
      'IdCardFile': await MultipartFile.fromFile(
        idCardFilePath,
        filename: idCardFilePath.split('/').last,
      ),
      'PersonalPhotoFile': await MultipartFile.fromFile(
        personalPhotoFilePath,
        filename: personalPhotoFilePath.split('/').last,
      ),
    });

    final response = await ApiService.postMultipart(_endpoint, formData);
    return GuideVerificationResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}