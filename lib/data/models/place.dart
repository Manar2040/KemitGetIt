/// Maps to C# PlaceDto from KemitGetit.Application.DTOs.
///
/// Backend fields (GET /api/places and GET /api/places/{id}):
///   id, name, description, location, locationLat, locationLng, imageUrl, category
class Place {
  final int    id;
  final String name;
  final String description;
  final String imageUrl;
  final String? location;
  final double? locationLat;
  final double? locationLng;
  final String? category;

  // UI-only helpers (not from backend – kept for backward compat with cards)
  final double  rating;
  final int     reviewCount;

  const Place({
    required this.id,
    required this.name,
    this.description  = '',
    this.imageUrl     = '',
    this.location,
    this.locationLat,
    this.locationLng,
    this.category,
    this.rating       = 0.0,
    this.reviewCount  = 0,
  });

  factory Place.fromJson(Map<String, dynamic> j) => Place(
    id:          j['id']          as int,
    name:        j['name']        as String,
    description: j['description'] as String? ?? '',
    imageUrl:    j['imageUrl']    as String? ?? '',
    location:    j['location']    as String?,
    locationLat: (j['locationLat'] as num?)?.toDouble(),
    locationLng: (j['locationLng'] as num?)?.toDouble(),
    category:    j['category']   as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'name':        name,
    'description': description,
    'imageUrl':    imageUrl,
    'location':    location,
    'locationLat': locationLat,
    'locationLng': locationLng,
    'category':    category,
  };

  // Keep equality by id for Set<Place> usage in wishlist
  @override
  bool operator ==(Object other) => other is Place && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Paged result wrapper – mirrors C# PagedResult<PlaceDto>
class PlacedPagedResult {
  final int         totalCount;
  final int         page;
  final int         pageSize;
  final List<Place> items;

  const PlacedPagedResult({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory PlacedPagedResult.fromJson(Map<String, dynamic> j) =>
      PlacedPagedResult(
        totalCount: j['totalCount'] as int,
        page:       j['page']       as int,
        pageSize:   j['pageSize']   as int,
        items:      (j['items'] as List)
            .map((e) => Place.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// My Plan item – mirrors C# AddToMyPlanDto response
class MyPlanItem {
  final int    id;
  final int    placeId;
  final String placeName;
  final String? imageUrl;
  final String? location;

  const MyPlanItem({
    required this.id,
    required this.placeId,
    required this.placeName,
    this.imageUrl,
    this.location,
  });

  factory MyPlanItem.fromJson(Map<String, dynamic> j) => MyPlanItem(
    id:         j['id']        as int,
    placeId:    j['placeId']   as int? ?? j['id'] as int,
    placeName:  j['placeName'] as String? ?? j['name'] as String? ?? '',
    imageUrl:   j['imageUrl']  as String?,
    location:   j['location']  as String?,
  );
}