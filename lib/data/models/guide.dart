class TripItem {
  final String id;
  final String title;
  final String dateRange;
  final double price;
  final String status; // e.g., "Completed"
  final String imageUrl;

  TripItem({
    required this.id,
    required this.title,
    required this.dateRange,
    required this.price,
    required this.status,
    required this.imageUrl,
  });
}

class FeedbackItem {
  final String id;
  final String reviewerName;
  final double rating;
  final String comment;
  final String reviewerImageUrl;

  FeedbackItem({
    required this.id,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.reviewerImageUrl,
  });
}

class Guide {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final List<String> sharedInterests;
  final String imageUrl;
  final String description;
  final String aboutMe;
  final List<String> certifications;
  final List<TripItem> recentTrips;
  final List<FeedbackItem> recentFeedback;
  final String? title;
  final String? email;
  final List<String> languages;
  final List<String> specialties;

  Guide({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.sharedInterests,
    required this.imageUrl,
    required this.description,
    this.aboutMe = '',
    this.certifications = const [],
    this.recentTrips = const [],
    this.recentFeedback = const [],
    this.title,
    this.email,
    this.languages = const [],
    this.specialties = const [],
  });
}
