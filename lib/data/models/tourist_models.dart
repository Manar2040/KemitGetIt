// ============================================================
// Tourist Profile DTOs – mirror KemitGetit.Application.DTOs.Tourist
// ============================================================
// ── Request ───────────────────────────────────────────────────────────────────
/// POST /api/users/tourist/complete-profile  [Authorize(Roles="Tourist")]
/// Maps to C# CompleteTouristProfileDto.
class CompleteTouristProfileRequest {
  final String    phone;
  final int       age;
  final String    country;
  final String    language;
  /// List of integer IDs from GET /api/interests.
  final List<int> interestIds;
  const CompleteTouristProfileRequest({
    required this.phone,
    required this.age,
    required this.country,
    required this.language,
    required this.interestIds,
  });
  Map<String, dynamic> toJson() => {
    'phone':       phone,
    'age':         age,
    'country':     country,
    'language':    language,
    'interestIds': interestIds,
  };
}
/// PUT /api/users/tourist/profile  [Authorize(Roles="Tourist")]
/// Maps to C# UpdateTouristProfileDto – all fields are optional.
class UpdateTouristProfileRequest {
  final String?    firstName;
  final String?    lastName;
  final String?    gender;
  final String?    aboutText;
  final String?    experienceText;
  final int?       age;
  final String?    touristTypePreference;
  final String?    countryOfResidence;
  final String?    preferredLanguage;
  final List<int>? interestIds;
  const UpdateTouristProfileRequest({
    this.firstName,
    this.lastName,
    this.gender,
    this.aboutText,
    this.experienceText,
    this.age,
    this.touristTypePreference,
    this.countryOfResidence,
    this.preferredLanguage,
    this.interestIds,
  });
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (firstName            != null) m['firstName']            = firstName;
    if (lastName             != null) m['lastName']             = lastName;
    if (gender               != null) m['gender']               = gender;
    if (aboutText            != null) m['aboutText']            = aboutText;
    if (experienceText       != null) m['experienceText']       = experienceText;
    if (age                  != null) m['age']                  = age;
    if (touristTypePreference != null) m['touristTypePreference'] = touristTypePreference;
    if (countryOfResidence   != null) m['countryOfResidence']   = countryOfResidence;
    if (preferredLanguage    != null) m['preferredLanguage']    = preferredLanguage;
    if (interestIds          != null) m['interestIds']          = interestIds;
    return m;
  }
}
// ── Response ──────────────────────────────────────────────────────────────────
/// Response for POST /api/users/tourist/complete-profile.
/// Maps to C# CompleteTouristProfileResponseDto.
class CompleteTouristProfileResponse {
  final int         userId;
  final String      username;
  final String      email;
  final String      phone;
  final int         age;
  final String      country;
  final String      preferredLanguage;
  final List<String> interests;
  const CompleteTouristProfileResponse({
    required this.userId,
    required this.username,
    required this.email,
    required this.phone,
    required this.age,
    required this.country,
    required this.preferredLanguage,
    required this.interests,
  });
  factory CompleteTouristProfileResponse.fromJson(Map<String, dynamic> j) =>
      CompleteTouristProfileResponse(
        userId:            j['userId']            as int,
        username:          j['username']          as String,
        email:             j['email']             as String,
        phone:             j['phone']             as String,
        age:               j['age']               as int,
        country:           j['country']           as String,
        preferredLanguage: j['preferredLanguage'] as String,
        interests:         List<String>.from(j['interests'] as List),
      );
}
/// Response for GET /api/users/tourist/profile.
/// Maps to C# TouristProfileDto.
class TouristProfileResponse {
  final int     id;
  final int     userId;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? aboutText;
  final String? experienceText;
  final int?    age;
  final String? touristTypePreference;
  final String? countryOfResidence;
  final String? preferredLanguage;
  final String? profileImageUrl;
  final List<String> interests;
  const TouristProfileResponse({
    required this.id,
    required this.userId,
    this.username,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.gender,
    this.aboutText,
    this.experienceText,
    this.age,
    this.touristTypePreference,
    this.countryOfResidence,
    this.preferredLanguage,
    this.profileImageUrl,
    required this.interests,
  });
  factory TouristProfileResponse.fromJson(Map<String, dynamic> j) =>
      TouristProfileResponse(
        id:                    j['id']                    as int,
        userId:                j['userId']                as int,
        username:              j['username']              as String?,
        email:                 j['email']                 as String?,
        phoneNumber:           j['phoneNumber']           as String?,
        firstName:             j['firstName']             as String?,
        lastName:              j['lastName']              as String?,
        gender:                j['gender']                as String?,
        aboutText:             j['aboutText']             as String?,
        experienceText:        j['experienceText']        as String?,
        age:                   j['age']                   as int?,
        touristTypePreference: j['touristTypePreference'] as String?,
        countryOfResidence:    j['countryOfResidence']    as String?,
        preferredLanguage:     j['preferredLanguage']     as String?,
        profileImageUrl:       j['profileImageUrl']       as String?,
        interests:             List<String>.from(j['interests'] as List? ?? []),
      );
}
// ── Interest ──────────────────────────────────────────────────────────────────
/// Item in the list returned by GET /api/interests.
class InterestDto {
  final int     id;
  final String  name;
  final String? description;
  final String? iconName;
  const InterestDto({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
  });
  factory InterestDto.fromJson(Map<String, dynamic> j) => InterestDto(
    id:          j['id']          as int,
    name:        j['name']        as String,
    description: j['description'] as String?,
    iconName:    j['iconName']    as String?,
  );
}
