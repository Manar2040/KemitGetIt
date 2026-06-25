
//////////////////////////////////////////////////////////////////////
class TouristProfileModel {
  final int id;
  final int userId;
  final String username;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String aboutText;
  final String experienceText;
  final int age;
  final String touristTypePreference;
  final String countryOfResidence;
  final String preferredLanguage;
  final String profileImageUrl;
  final List<String> interests;

  TouristProfileModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.aboutText,
    required this.experienceText,
    required this.age,
    required this.touristTypePreference,
    required this.countryOfResidence,
    required this.preferredLanguage,
    required this.profileImageUrl,
    required this.interests,
  });

  factory TouristProfileModel.fromJson(Map<String, dynamic> json) {
    return TouristProfileModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      aboutText: json['aboutText'],
      experienceText: json['experienceText'],
      age: json['age'],
      touristTypePreference: json['touristTypePreference'],
      countryOfResidence: json['countryOfResidence'],
      preferredLanguage: json['preferredLanguage'],
      profileImageUrl: json['profileImageUrl'],
      interests: List<String>.from(json['interests']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'aboutText': aboutText,
      'experienceText': experienceText,
      'age': age,
      'touristTypePreference': touristTypePreference,
      'countryOfResidence': countryOfResidence,
      'preferredLanguage': preferredLanguage,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
    };
  }
}
