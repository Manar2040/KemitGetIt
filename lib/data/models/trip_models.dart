import 'guide.dart';

/// Maps to C# TripSummaryDto
class TripSummary {
  final int id;
  final String title;
  final String tripType;
  final List<String> languages;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final int durationDays;
  final int durationNights;
  final int maxParticipants;
  final int currentParticipants;
  final String? coverImageUrl;
  final String status;
  final String? guideName;
  final double guideRating;

  TripSummary({
    required this.id,
    required this.title,
    required this.tripType,
    this.languages = const [],
    this.location,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.durationNights,
    required this.maxParticipants,
    required this.currentParticipants,
    this.coverImageUrl,
    required this.status,
    this.guideName,
    this.guideRating = 0.0,
  });

  factory TripSummary.fromJson(Map<String, dynamic> j) => TripSummary(
    id:                  j['id'] as int,
    title:               j['title'] as String,
    tripType:            j['tripType'] as String,
    languages:           (j['languages'] as List?)?.map((e) => e.toString()).toList() ?? [],
    location:            j['location'] as String?,
    startDate:           DateTime.parse(j['startDate'] as String),
    endDate:             DateTime.parse(j['endDate'] as String),
    price:               (j['price'] as num).toDouble(),
    currency:            j['currency'] as String,
    durationDays:        j['durationDays'] as int,
    durationNights:      j['durationNights'] as int,
    maxParticipants:     j['maxParticipants'] as int,
    currentParticipants: j['currentParticipants'] as int,
    coverImageUrl:       j['coverImageUrl'] as String?,
    status:              j['status'] as String,
    guideName:           j['guideName'] as String?,
    guideRating:         (j['guideRating'] as num?)?.toDouble() ?? 0.0,
  );
}

/// Maps to C# PagedResult<TripSummaryDto>
class TripPagedResult {
  final int totalCount;
  final int page;
  final int pageSize;
  final List<TripSummary> items;

  TripPagedResult({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory TripPagedResult.fromJson(Map<String, dynamic> j) => TripPagedResult(
    totalCount: j['totalCount'] as int,
    page:       j['page'] as int,
    pageSize:   j['pageSize'] as int,
    items:      (j['items'] as List).map((e) => TripSummary.fromJson(e)).toList(),
  );
}

/// Maps to C# TripDto
class TripDetails {
  final int id;
  final int guideId;
  final String title;
  final String? description;
  final String tripType;
  final List<String> languages;
  final String? location;
  final double? locationLat;
  final double? locationLng;
  final String startingPoint;
  final String endingPoint;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final int durationDays;
  final int durationNights;
  final int maxParticipants;
  final int currentParticipants;
  final String? coverImageUrl;
  final String status;
  
  final Guide? guide; // Maps to GuideProfileDto
  final List<TripItineraryDay> itineraryDays;
  final List<TripImage> images;
  final List<GuideReview> recentReviews;

  TripDetails({
    required this.id,
    required this.guideId,
    required this.title,
    this.description,
    required this.tripType,
    this.languages = const [],
    this.location,
    this.locationLat,
    this.locationLng,
    required this.startingPoint,
    required this.endingPoint,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.durationNights,
    required this.maxParticipants,
    required this.currentParticipants,
    this.coverImageUrl,
    required this.status,
    this.guide,
    this.itineraryDays = const [],
    this.images = const [],
    this.recentReviews = const [],
  });

  factory TripDetails.fromJson(Map<String, dynamic> j) => TripDetails(
    id:                  j['id'] as int,
    guideId:             j['guideId'] as int,
    title:               j['title'] as String,
    description:         j['description'] as String?,
    tripType:            j['tripType'] as String,
    languages:           (j['languages'] as List?)?.map((e) => e.toString()).toList() ?? [],
    location:            j['location'] as String?,
    locationLat:         (j['locationLat'] as num?)?.toDouble(),
    locationLng:         (j['locationLng'] as num?)?.toDouble(),
    startingPoint:       j['startingPoint'] as String,
    endingPoint:         j['endingPoint'] as String,
    startDate:           DateTime.parse(j['startDate'] as String),
    endDate:             DateTime.parse(j['endDate'] as String),
    price:               (j['price'] as num).toDouble(),
    currency:            j['currency'] as String,
    durationDays:        j['durationDays'] as int,
    durationNights:      j['durationNights'] as int,
    maxParticipants:     j['maxParticipants'] as int,
    currentParticipants: j['currentParticipants'] as int,
    coverImageUrl:       j['coverImageUrl'] as String?,
    status:              j['status'] as String,
    // We assume GuideProfileDto maps roughly to our Guide model, or we parse what we need:
    guide:               j['guide'] != null ? _parseGuide(j['guide']) : null,
    itineraryDays:       (j['itineraryDays'] as List?)?.map((e) => TripItineraryDay.fromJson(e)).toList() ?? [],
    images:              (j['images'] as List?)?.map((e) => TripImage.fromJson(e)).toList() ?? [],
    recentReviews:       (j['recentReviews'] as List?)?.map((e) => GuideReview.fromJson(e)).toList() ?? [],
  );

  static Guide _parseGuide(Map<String, dynamic> j) {
    // This parses from GuideProfileDto (backend) into our local Guide class.
    return Guide(
      id: j['userId']?.toString() ?? '',
      name: '${j['firstName']} ${j['lastName']}'.trim(),
      email: '',
      title: j['professionalTitle'] ?? 'Guide',
      rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: j['reviewCount'] as int? ?? 0,
      imageUrl: j['profileImageUrl'] ?? 'https://via.placeholder.com/150',
      description: j['bio'] ?? '',
      location: j['location'] ?? '',
      languages: (j['languages'] as List?)?.map((e) => e.toString()).toList() ?? [],
      specialties: (j['specialties'] as List?)?.map((e) => e.toString()).toList() ?? [],
      sharedInterests: [],
    );
  }
}

class TripItineraryDay {
  final int id;
  final int dayNumber;
  final String title;
  final String description;

  TripItineraryDay({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
  });

  factory TripItineraryDay.fromJson(Map<String, dynamic> j) => TripItineraryDay(
    id:          j['id'] as int,
    dayNumber:   j['dayNumber'] as int,
    title:       j['title'] as String,
    description: j['description'] as String,
  );
}

class TripImage {
  final int id;
  final String imageUrl;
  final int displayOrder;

  TripImage({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory TripImage.fromJson(Map<String, dynamic> j) => TripImage(
    id:           j['id'] as int,
    imageUrl:     j['imageUrl'] as String,
    displayOrder: j['displayOrder'] as int,
  );
}

class GuideReview {
  final String touristName;
  final String? touristImageUrl;
  final int rating;
  final String comment;
  final DateTime createdAt;

  GuideReview({
    required this.touristName,
    this.touristImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory GuideReview.fromJson(Map<String, dynamic> j) => GuideReview(
    touristName:     j['touristName'] as String,
    touristImageUrl: j['touristImageUrl'] as String?,
    rating:          j['rating'] as int,
    comment:         j['comment'] as String,
    createdAt:       DateTime.parse(j['createdAt'] as String),
  );
}
