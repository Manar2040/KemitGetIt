class User {
  final String name;
  final String? phone;
  final int? age;
  final String? country;
  final String? language;
  final List<String> interests;

  User({
    required this.name,
    this.phone,
    this.age,
    this.country,
    this.language,
    this.interests = const [],
  });

  User copyWith({
    String? name,
    String? phone,
    int? age,
    String? country,
    String? language,
    List<String>? interests,
  }) {
    return User(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      country: country ?? this.country,
      language: language ?? this.language,
      interests: interests ?? this.interests,
    );
  }
}
