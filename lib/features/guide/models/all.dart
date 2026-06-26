// guide_models.dart
import 'package:kemit_get_it/core/constants/api_constants.dart';

export 'create_trip_form_model.dart';

class GuideReviewModel {
  final int id;
  final int touristUserId;
  final String? touristName;
  final int guideRating;
  final String comment;
  final DateTime createdAt;

  GuideReviewModel({
    required this.id,
    required this.touristUserId,
    this.touristName,
    required this.guideRating,
    required this.comment,
    required this.createdAt,
  });

  factory GuideReviewModel.fromJson(Map<String, dynamic> json) {
    return GuideReviewModel(
      id: json['id'],
      touristUserId: json['touristUserId'],
      touristName: json['touristName'],
      guideRating: json['guideRating'],
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'touristUserId': touristUserId,
    'touristName': touristName,
    'guideRating': guideRating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
  };
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
String _resolveUrl(String url) {
  if (url.isEmpty) return '';
  if (url.startsWith('http')) return url;

  return '${ApiConstants.baseUrl}$url';
}

class GuideProfileModel {
  final int id;
  final int userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String bio;
  final String profileImageUrl;
  final String specialization;
  final String workingRegions;
  final double averageRating;
  final int totalReviews;
  final String verificationStatus;
  final List<GuideReviewModel> recentReviews;
  final String? rejectionReason;

  GuideProfileModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.bio,
    required this.profileImageUrl,
    required this.specialization,
    required this.workingRegions,
    required this.averageRating,
    required this.totalReviews,
    required this.verificationStatus,
    required this.recentReviews,
    this.rejectionReason,
  });

  factory GuideProfileModel.fromJson(Map<String, dynamic> json) {
    return GuideProfileModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'] ?? '',
      bio: json['bio'] ?? '',
      profileImageUrl: _resolveUrl(json['profileImageUrl'] ?? ''),
      specialization: json['specialization'] ?? '',
      workingRegions: json['workingRegions'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      verificationStatus: json['verificationStatus'] ?? '',
      recentReviews:
          (json['recentReviews'] as List? ?? [])
              .map((e) => GuideReviewModel.fromJson(e))
              .toList(),
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}

/////////////////////////////////////////////////////////////////////////
class TripModel {
  final int id;
  final String title;
  final String tripType;
  final List<String> languages;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final int durationDays;
  final int durationNights;
  final int maxParticipants;
  final int currentParticipants;
  final String coverImageUrl;
  final String status;
  final String guideName;
  final double guideRating;

  TripModel({
    required this.id,
    required this.title,
    required this.tripType,
    required this.languages,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.durationNights,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.coverImageUrl,
    required this.status,
    required this.guideName,
    required this.guideRating,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      title: json['title'] ?? '',
      tripType: json['tripType'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      location: json['location'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      durationNights: json['durationNights'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      coverImageUrl: json['coverImageUrl'] ?? '',
      status: json['status'] ?? '',
      guideName: json['guideName'] ?? '',
      guideRating: (json['guideRating'] ?? 0).toDouble(),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class GuideInfoModel {
  final int id;
  final int userId;
  final String? username;
  final String? email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String bio;
  final String profileImageUrl;
  final String specialization;
  final String workingRegions;
  final double averageRating;
  final int totalReviews;
  final String verificationStatus;

  GuideInfoModel({
    required this.id,
    required this.userId,
    this.username,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.bio,
    required this.profileImageUrl,
    required this.specialization,
    required this.workingRegions,
    required this.averageRating,
    required this.totalReviews,
    required this.verificationStatus,
  });

  factory GuideInfoModel.fromJson(Map<String, dynamic> json) {
    return GuideInfoModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'] ?? '',
      bio: json['bio'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      specialization: json['specialization'] ?? '',
      workingRegions: json['workingRegions'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      verificationStatus: json['verificationStatus'] ?? '',
    );
  }
}

///////////////////////////////////////////////////////////////////////
class ItineraryDayModel {
  final int id;
  final int dayNumber;
  final String title;
  final String description;

  ItineraryDayModel({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.description,
  });

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) {
    return ItineraryDayModel(
      id: json['id'],
      dayNumber: json['dayNumber'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

///////////////////////////////////////////////////////////
class TripImageModel {
  final int id;
  final String imageUrl;
  final int displayOrder;

  TripImageModel({
    required this.id,
    required this.imageUrl,
    required this.displayOrder,
  });

  factory TripImageModel.fromJson(Map<String, dynamic> json) {
    return TripImageModel(
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}

///////////////////////////////////////////////////////////////////////////
class TripDetailsModel extends TripModel {
  final String description;
  final double locationLat;
  final double locationLng;
  final String startingPoint;
  final String endingPoint;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GuideInfoModel guide;
  final List<ItineraryDayModel> itineraryDays;
  final List<TripImageModel> images;
  final List<GuideReviewModel> recentReviews;

  TripDetailsModel({
    required super.id,
    required super.title,
    required super.tripType,
    required super.languages,
    required super.location,
    required super.startDate,
    required super.endDate,
    required super.price,
    required super.currency,
    required super.durationDays,
    required super.durationNights,
    required super.maxParticipants,
    required super.currentParticipants,
    required super.coverImageUrl,
    required super.status,
    required super.guideName,
    required super.guideRating,
    required this.description,
    required this.locationLat,
    required this.locationLng,
    required this.startingPoint,
    required this.endingPoint,
    required this.createdAt,
    required this.updatedAt,
    required this.guide,
    required this.itineraryDays,
    required this.images,
    required this.recentReviews,
  });

  factory TripDetailsModel.fromJson(Map<String, dynamic> json) {
    return TripDetailsModel(
      id: json['id'],
      title: json['title'] ?? '',
      tripType: json['tripType'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      location: json['location'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      durationNights: json['durationNights'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      coverImageUrl: json['coverImageUrl'] ?? '',
      status: json['status'] ?? '',
      guideName: json['guide']?['displayName'] ?? '',
      guideRating: (json['guide']?['averageRating'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      locationLat: (json['locationLat'] ?? 0).toDouble(),
      locationLng: (json['locationLng'] ?? 0).toDouble(),
      startingPoint: json['startingPoint'] ?? '',
      endingPoint: json['endingPoint'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      guide: GuideInfoModel.fromJson(json['guide']),
      itineraryDays:
          (json['itineraryDays'] as List? ?? [])
              .map((e) => ItineraryDayModel.fromJson(e))
              .toList(),
      images:
          (json['images'] as List? ?? [])
              .map((e) => TripImageModel.fromJson(e))
              .toList(),
      recentReviews:
          (json['recentReviews'] as List? ?? [])
              .map((e) => GuideReviewModel.fromJson(e))
              .toList(),
    );
  }
}

//////////////////////////////////////////////////////////////////

// 1. أضيفي الكلاس ده فوق CreateTripRequest مباشرة
class ItineraryDayRequest {
  final int dayNumber;
  final String title;
  final String description;

  ItineraryDayRequest({
    required this.dayNumber,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'dayNumber': dayNumber,
    'title': title,
    'description': description,
  };
}

// 2. عدّلي CreateTripRequest
class CreateTripRequest {
  final String title;
  final String description;
  final String tripType;
  final List<String> languages;
  final String location;
  final double locationLat;
  final double locationLng;
  final String startingPoint;
  final String endingPoint;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final String currency;
  final int durationDays;
  final int durationNights;
  final int maxParticipants;
  final List<ItineraryDayRequest> itineraryDays; // ✅ أضيفي دي

  CreateTripRequest({
    required this.title,
    required this.description,
    required this.tripType,
    required this.languages,
    required this.location,
    required this.locationLat,
    required this.locationLng,
    required this.startingPoint,
    required this.endingPoint,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.durationNights,
    required this.maxParticipants,
    this.itineraryDays =
        const [], // ✅ default فارغة عشان create trip القديم يشتغل
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "tripType": tripType,
      "languages": languages,
      "location": location,
      "locationLat": locationLat,
      "locationLng": locationLng,
      "startingPoint": startingPoint,
      "endingPoint": endingPoint,
      "startDate": startDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "price": price,
      "currency": currency,
      "durationDays": durationDays,
      "durationNights": durationNights,
      "maxParticipants": maxParticipants,
      "itineraryDays": itineraryDays.map((d) => d.toJson()).toList(), // ✅
    };
  }
}

////////////////////////////////////////////////////////////////////////////////////////
// guide_verification_models.dart

// ============================================================
// 1. GuideVerificationResponse
//    بييجي من: POST /api/users/guide/submit-verification
// ============================================================
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
  final String verificationStatus; // "Pending" | "Approved" | "Rejected"
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
      userId: json['userId'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      specialization: json['specialization'] ?? '',
      workingRegions: json['workingRegions'] ?? '',
      verificationDocIdCardUrl: json['verificationDocIdCardUrl'] ?? '',
      verificationDocPhotoUrl: json['verificationDocPhotoUrl'] ?? '',
      verificationStatus: json['verificationStatus'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}

///////////////////////////////////////////////////////////////////////////////////
// ============================================================
// 2. SubmitVerificationRequest
//    بيتبعت كـ multipart/form-data
//    الملفات بتتبعت كـ File مش String
// ============================================================
class SubmitVerificationRequest {
  final String phone;
  final String bio;
  final String specialization; // comma-separated: "Historical,Cultural"
  final String workingRegions; // comma-separated: "Cairo,Luxor"
  // الملفات بتتبعت منفصلة في الـ multipart request
  // IdCardFile و PersonalPhotoFile

  SubmitVerificationRequest({
    required this.phone,
    required this.bio,
    required this.specialization,
    required this.workingRegions,
  });

  // بيتحول لـ Map عشان تضيفيه على الـ MultipartRequest
  Map<String, String> toFields() => {
    'Phone': phone,
    'Bio': bio,
    'Specialization': specialization,
    'WorkingRegions': workingRegions,
  };
}
/////////////////////////////////////////////////////////////////////////////////////
// guide_missing_models.dart
// الموديلز الناقصة للجايد — مبنية على الـ API responses الفعلية

// ============================================================
// 1. SelectedPlaceModel
//    بييجي جوا HoldRequestModel في selectedPlaces
// ============================================================
class SelectedPlaceModel {
  final int placeId;
  final String placeName;
  final int order;

  SelectedPlaceModel({
    required this.placeId,
    required this.placeName,
    required this.order,
  });

  factory SelectedPlaceModel.fromJson(Map<String, dynamic> json) {
    return SelectedPlaceModel(
      placeId: json['placeId'],
      placeName: json['placeName'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'placeId': placeId,
    'placeName': placeName,
    'order': order,
  };
}

///////////////////////////////////////////////////////////
// ============================================================
// 2. HoldRequestModel
//    بييجي من:
//      GET /api/hold-requests          (قائمة)
//      GET /api/hold-requests/{id}     (تفصيلة واحدة)
//      PUT /api/hold-requests/{id}/set-price    (response)
//      PUT /api/hold-requests/{id}/accept       (response)
//      PUT /api/hold-requests/{id}/decline      (response)
//    يُستخدم في: Incoming Requests, Awaiting Payment, Declined Requests
// ============================================================
class HoldRequestModel {
  final int id;
  final int touristUserId;
  final String touristName;
  final int guideUserId;
  final String guideName;
  final int? tripId;
  final String? tripTitle;
  final String requestType; // "ReadyTrip" | "PrivateTrip"
  final String travelerType; // "Solo" | "Group" | ...
  final int numberOfTravelers;
  final String companionsInfo; // JSON string — parse لو محتاجة
  final String preferredLanguage;
  final String transportPreference; // "PrivateCar" | "NoTransport" | ...
  final DateTime startDate;
  final DateTime endDate;
  final bool accommodationNeeded;
  final bool mealsIncluded;
  final double totalPrice;
  final String currency;
  final String status;
  // "PendingRequest" | "Accepted" | "Declined" | "PaymentPending"
  // | "Paid" | "Completed" | "Cancelled" | "Expired"
  final DateTime? paymentDeadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SelectedPlaceModel> selectedPlaces;

  HoldRequestModel({
    required this.id,
    required this.touristUserId,
    required this.touristName,
    required this.guideUserId,
    required this.guideName,
    this.tripId,
    this.tripTitle,
    required this.requestType,
    required this.travelerType,
    required this.numberOfTravelers,
    required this.companionsInfo,
    required this.preferredLanguage,
    required this.transportPreference,
    required this.startDate,
    required this.endDate,
    required this.accommodationNeeded,
    required this.mealsIncluded,
    required this.totalPrice,
    required this.currency,
    required this.status,
    this.paymentDeadline,
    required this.createdAt,
    required this.updatedAt,
    required this.selectedPlaces,
  });

  factory HoldRequestModel.fromJson(Map<String, dynamic> json) {
    return HoldRequestModel(
      id: json['id'],
      touristUserId: json['touristUserId'],
      touristName: json['touristName'] ?? '',
      guideUserId: json['guideUserId'],
      guideName: json['guideName'] ?? '',
      tripId: json['tripId'],
      tripTitle: json['tripTitle'],
      requestType: json['requestType'] ?? '',
      travelerType: json['travelerType'] ?? '',
      numberOfTravelers: json['numberOfTravelers'] ?? 1,
      companionsInfo: json['companionsInfo'] ?? '[]',
      preferredLanguage: json['preferredLanguage'] ?? '',
      transportPreference: json['transportPreference'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      accommodationNeeded: json['accommodationNeeded'] ?? false,
      mealsIncluded: json['mealsIncluded'] ?? false,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      paymentDeadline:
          json['paymentDeadline'] != null
              ? DateTime.parse(json['paymentDeadline'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      selectedPlaces:
          (json['selectedPlaces'] as List? ?? [])
              .map((e) => SelectedPlaceModel.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'touristUserId': touristUserId,
    'touristName': touristName,
    'guideUserId': guideUserId,
    'guideName': guideName,
    'tripId': tripId,
    'tripTitle': tripTitle,
    'requestType': requestType,
    'travelerType': travelerType,
    'numberOfTravelers': numberOfTravelers,
    'companionsInfo': companionsInfo,
    'preferredLanguage': preferredLanguage,
    'transportPreference': transportPreference,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'accommodationNeeded': accommodationNeeded,
    'mealsIncluded': mealsIncluded,
    'totalPrice': totalPrice,
    'currency': currency,
    'status': status,
    'paymentDeadline': paymentDeadline?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'selectedPlaces': selectedPlaces.map((e) => e.toJson()).toList(),
  };
}
/////////////////////////////////////////////////////////////////////////////
// ============================================================
// 3. GuideDashboardModel
//    بييجي من: GET /api/guides/requests-dashboard
//    بيقسّم الطلبات في 4 أقسام
// ============================================================

// -- القسم الفرعي: incomingRequests --
class IncomingRequestsModel {
  final List<HoldRequestModel> readyTripRequests;
  final List<HoldRequestModel> customTripRequests;

  IncomingRequestsModel({
    required this.readyTripRequests,
    required this.customTripRequests,
  });

  factory IncomingRequestsModel.fromJson(Map<String, dynamic> json) {
    return IncomingRequestsModel(
      readyTripRequests:
          (json['readyTripRequests'] as List? ?? [])
              .map((e) => HoldRequestModel.fromJson(e))
              .toList(),
      customTripRequests:
          (json['customTripRequests'] as List? ?? [])
              .map((e) => HoldRequestModel.fromJson(e))
              .toList(),
    );
  }
}

/////////////////////////////////////////////////////
// -- القسم الفرعي: awaitingPayment --
class AwaitingPaymentModel {
  final List<HoldRequestModel> readyTripsAwaitingPayment;
  final List<HoldRequestModel> customTripsAwaitingPayment;

  AwaitingPaymentModel({
    required this.readyTripsAwaitingPayment,
    required this.customTripsAwaitingPayment,
  });

  factory AwaitingPaymentModel.fromJson(Map<String, dynamic> json) {
    return AwaitingPaymentModel(
      readyTripsAwaitingPayment:
          (json['readyTripsAwaitingPayment'] as List? ?? [])
              .map((e) => HoldRequestModel.fromJson(e))
              .toList(),
      customTripsAwaitingPayment:
          (json['customTripsAwaitingPayment'] as List? ?? [])
              .map((e) => HoldRequestModel.fromJson(e))
              .toList(),
    );
  }
}

///////////////////////////////////////
class BookingModel {
  final int id;
  final int tripId;
  final String tripTitle;
  final int holdRequestId;
  final int touristUserId;
  final String touristName;
  final int guideUserId;
  final String guideName;
  final int numberOfParticipants;
  final double totalAmount;
  final String currency;
  final double platformFeePercentage;
  final double platformFeeAmount;
  final double guideEarnings;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final DateTime bookingDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.tripId,
    required this.tripTitle,
    required this.holdRequestId,
    required this.touristUserId,
    required this.touristName,
    required this.guideUserId,
    required this.guideName,
    required this.numberOfParticipants,
    required this.totalAmount,
    required this.currency,
    required this.platformFeePercentage,
    required this.platformFeeAmount,
    required this.guideEarnings,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.bookingDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      tripId: json['tripId'],
      tripTitle: json['tripTitle'] ?? '',
      holdRequestId: json['holdRequestId'],
      touristUserId: json['touristUserId'],
      touristName: json['touristName'] ?? '',
      guideUserId: json['guideUserId'],
      guideName: json['guideName'] ?? '',
      numberOfParticipants: json['numberOfParticipants'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      platformFeePercentage: (json['platformFeePercentage'] ?? 0).toDouble(),
      platformFeeAmount: (json['platformFeeAmount'] ?? 0).toDouble(),
      guideEarnings: (json['guideEarnings'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      status: json['status'] ?? '',
      bookingDate: DateTime.parse(json['bookingDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tripId': tripId,
    'tripTitle': tripTitle,
    'holdRequestId': holdRequestId,
    'touristUserId': touristUserId,
    'touristName': touristName,
    'guideUserId': guideUserId,
    'guideName': guideName,
    'numberOfParticipants': numberOfParticipants,
    'totalAmount': totalAmount,
    'currency': currency,
    'platformFeePercentage': platformFeePercentage,
    'platformFeeAmount': platformFeeAmount,
    'guideEarnings': guideEarnings,
    'paymentMethod': paymentMethod,
    'paymentStatus': paymentStatus,
    'status': status,
    'bookingDate': bookingDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

////////////////////////////////////////////////////////////////
// -- الموديل الرئيسي --
// ملاحظة: confirmedBookings بيرجع List<BookingModel> — استخدمي BookingModel الموجود عندك
class GuideDashboardModel {
  final IncomingRequestsModel incomingRequests;
  final AwaitingPaymentModel awaitingPayment;
  final List<BookingModel> confirmedBookings;
  final List<HoldRequestModel> declinedRequests;

  GuideDashboardModel({
    required this.incomingRequests,
    required this.awaitingPayment,
    required this.confirmedBookings,
    required this.declinedRequests,
  });

  factory GuideDashboardModel.fromJson(Map<String, dynamic> json) {
    return GuideDashboardModel(
      incomingRequests: IncomingRequestsModel.fromJson(
        json['incomingRequests'] ?? {},
      ),
      awaitingPayment: AwaitingPaymentModel.fromJson(
        json['awaitingPayment'] ?? {},
      ),
      // غيّري dynamic لـ BookingModel وأضيفي .map((e) => BookingModel.fromJson(e))
      confirmedBookings:
          (json['confirmedBookings'] as List? ?? [])
              .map((e) => BookingModel.fromJson(e))
              .toList(),

      declinedRequests:
          (json['declinedRequests'] as List? ?? [])
              .map((e) => HoldRequestModel.fromJson(e))
              .toList(),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////
// ============================================================
// 4. UpdateGuideProfileRequest
//    بيتبعت في: PUT /api/users/guide/profile
//    الـ response بييجي { "message": "..." } بس — مش محتاجة موديل للـ response
// ============================================================
class UpdateGuideProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? bio;
  final String? specialization;
  final String? workingRegions;

  UpdateGuideProfileRequest({
    this.firstName,
    this.lastName,
    this.displayName,
    this.bio,
    this.specialization,
    this.workingRegions,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (displayName != null) map['displayName'] = displayName;
    if (bio != null) map['bio'] = bio;
    if (specialization != null) map['specialization'] = specialization;
    if (workingRegions != null) map['workingRegions'] = workingRegions;
    return map;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// ============================================================
// 5. SetPriceRequest
//    بيتبعت في: PUT /api/hold-requests/{id}/set-price
//    الـ response هو HoldRequestModel عادي
// ============================================================
class SetPriceRequest {
  final double price;
  final String currency;

  SetPriceRequest({required this.price, required this.currency});

  Map<String, dynamic> toJson() => {'price': price, 'currency': currency};
}

// active_trip_model.dart
// الموديل المستخدم في الـ Home widget و MyTrips list
// مبني على TripModel من guide_models.dart لكن بـ fields إضافية للعرض
///////////////////////////////////////////////////////////////////////////
class ActiveTripModel {
  final int id;
  final String title;
  final String status;
  final String coverImageUrl;
  final int currentParticipants;
  final int maxParticipants;
  final DateTime? startDate;
  final DateTime? endDate;
  final String location;
  final double price;
  final String currency;

  ActiveTripModel({
    required this.id,
    required this.title,
    required this.status,
    required this.coverImageUrl,
    required this.currentParticipants,
    required this.maxParticipants,
    this.startDate,
    this.endDate,
    required this.location,
    required this.price,
    required this.currency,
  });

  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    return ActiveTripModel(
      id: json['id'],
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      currentParticipants: json['currentParticipants'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 0,
      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(json['startDate'])
              : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      location: json['location'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
    );
  }

  // ── Getters للتوافق مع الـ widgets القديمة ──────────────
  String get image => coverImageUrl; // backward compat
  int get tourists => currentParticipants;
  String get timeLeft {
    if (endDate == null) return '';
    final diff = endDate!.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays == 0) return 'Today';
    return '${diff.inDays}d left';
  }
}
