enum RequestType {
  readyTrip,
  privateTrip
}

enum TravelerType {
  solo,
  group
}

enum TransportPreference {
  privateCar,
  publicTransport,
  noTransport
}

class SendHoldRequestDto {
  final int guideUserId;
  final int? tripId;
  final RequestType requestType;
  final TravelerType travelerType;
  final int numberOfTravelers;
  final String companionsInfo;
  final String preferredLanguage;
  final TransportPreference transportPreference;
  final DateTime startDate;
  final DateTime endDate;
  final bool accommodationNeeded;
  final bool mealsIncluded;
  final List<int> selectedPlaceIds;

  SendHoldRequestDto({
    required this.guideUserId,
    this.tripId,
    required this.requestType,
    required this.travelerType,
    this.numberOfTravelers = 1,
    this.companionsInfo = '',
    this.preferredLanguage = '',
    required this.transportPreference,
    required this.startDate,
    required this.endDate,
    this.accommodationNeeded = false,
    this.mealsIncluded = false,
    this.selectedPlaceIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'guideUserId': guideUserId,
    'tripId': tripId,
    'requestType': requestType.index,
    'travelerType': travelerType.index,
    'numberOfTravelers': numberOfTravelers,
    'companionsInfo': companionsInfo,
    'preferredLanguage': preferredLanguage,
    'transportPreference': transportPreference.index,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'accommodationNeeded': accommodationNeeded,
    'mealsIncluded': mealsIncluded,
    'selectedPlaceIds': selectedPlaceIds,
  };
}

class HoldRequestPlaceDto {
  final int placeId;
  final String? placeName;
  final int order;

  HoldRequestPlaceDto({
    required this.placeId,
    this.placeName,
    required this.order,
  });

  factory HoldRequestPlaceDto.fromJson(Map<String, dynamic> j) => HoldRequestPlaceDto(
    placeId: j['placeId'] as int,
    placeName: j['placeName'] as String?,
    order: j['order'] as int,
  );
}

class HoldRequestDto {
  final int id;
  final int touristUserId;
  final String? touristName;
  final int guideUserId;
  final String? guideName;
  final int? tripId;
  final String? tripTitle;
  final String requestType;
  final String travelerType;
  final int numberOfTravelers;
  final String companionsInfo;
  final String preferredLanguage;
  final String transportPreference;
  final DateTime startDate;
  final DateTime endDate;
  final bool accommodationNeeded;
  final bool mealsIncluded;
  final double totalPrice;
  final String? currency;
  final String status;
  final DateTime? paymentDeadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<HoldRequestPlaceDto> selectedPlaces;

  HoldRequestDto({
    required this.id,
    required this.touristUserId,
    this.touristName,
    required this.guideUserId,
    this.guideName,
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
    this.currency,
    required this.status,
    this.paymentDeadline,
    required this.createdAt,
    required this.updatedAt,
    this.selectedPlaces = const [],
  });

  factory HoldRequestDto.fromJson(Map<String, dynamic> j) => HoldRequestDto(
    id: j['id'] as int,
    touristUserId: j['touristUserId'] as int,
    touristName: _formatName(j['touristName'] as String?),
    guideUserId: j['guideUserId'] as int,
    guideName: _formatName(j['guideName'] as String?),
    tripId: j['tripId'] as int?,
    tripTitle: j['tripTitle'] as String?,
    requestType: j['requestType'] as String,
    travelerType: j['travelerType'] as String,
    numberOfTravelers: j['numberOfTravelers'] as int,
    companionsInfo: j['companionsInfo'] as String? ?? '',
    preferredLanguage: j['preferredLanguage'] as String? ?? '',
    transportPreference: j['transportPreference'] as String,
    startDate: DateTime.parse(j['startDate'] as String),
    endDate: DateTime.parse(j['endDate'] as String),
    accommodationNeeded: j['accommodationNeeded'] as bool,
    mealsIncluded: j['mealsIncluded'] as bool,
    totalPrice: (j['totalPrice'] as num).toDouble(),
    currency: j['currency'] as String?,
    status: j['status'] as String,
    paymentDeadline: j['paymentDeadline'] != null ? DateTime.parse(j['paymentDeadline'] as String) : null,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    selectedPlaces: (j['selectedPlaces'] as List?)?.map((e) => HoldRequestPlaceDto.fromJson(e)).toList() ?? [],
  );

  static String? _formatName(String? name) {
    if (name == null) return null;
    if (name.contains('@')) {
      final localPart = name.split('@')[0];
      return localPart.replaceAll(RegExp(r'[._]'), ' ').split(' ').map((w) {
        if (w.isEmpty) return '';
        return w[0].toUpperCase() + w.substring(1).toLowerCase();
      }).join(' ');
    }
    return name;
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
    'selectedPlaces': selectedPlaces.map((e) => {
      'placeId': e.placeId,
      'placeName': e.placeName,
      'order': e.order,
    }).toList(),
  };
}
