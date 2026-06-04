class User {
  final String? email;
  final String? avatar;
  final String name;
  final String? phone;
  final int? age;
  final String? country;
  final String? language;
  final List<String> interests;

  User({
    required this.name,
    this.email,
    this.avatar,
    this.phone,
    this.age,
    this.country,
    this.language,
    this.interests = const [],
  });

  User copyWith({
    String? name,
    String? email,
    String? avatar,
    String? phone,
    int? age,
    String? country,
    String? language,
    List<String>? interests,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      country: country ?? this.country,
      language: language ?? this.language,
      interests: interests ?? this.interests,
    );
  }
}

