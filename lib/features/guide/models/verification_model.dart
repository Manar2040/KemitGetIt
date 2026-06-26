class GuideVerificationResponse {
  final int userId;
  final String username;
  final String email;
  final String phone;
  final String bio;
  final String specialization;
  final String workingRegions;
  final String verificationDocIdCardUrl;
  final String verificationDocPhotoUrl;
  final String verificationStatus;
  final bool isVerified;

  GuideVerificationResponse({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.bio,
    required this.specialization,
    required this.workingRegions,
    required this.verificationDocIdCardUrl,
    required this.verificationDocPhotoUrl,
    required this.verificationStatus,
    required this.isVerified,
  });

  factory GuideVerificationResponse.fromJson(Map<String, dynamic> json) {
    return GuideVerificationResponse(
      userId: json['userId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String,
      specialization: json['specialization'] as String,
      workingRegions: json['workingRegions'] as String,
      verificationDocIdCardUrl: json['verificationDocIdCardUrl'] as String,
      verificationDocPhotoUrl: json['verificationDocPhotoUrl'] as String,
      verificationStatus: json['verificationStatus'] as String,
      isVerified: json['isVerified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'bio': bio,
      'specialization': specialization,
      'workingRegions': workingRegions,
      'verificationDocIdCardUrl': verificationDocIdCardUrl,
      'verificationDocPhotoUrl': verificationDocPhotoUrl,
      'verificationStatus': verificationStatus,
      'isVerified': isVerified,
    };
  }
}