import '../../core/constants/api_constants.dart';
import '../../core/services/api_client.dart';
import '../models/place.dart';

/// Real API service for Places and Wishlist (Favorites).
///
/// Replaces the old static mock [PlacesService].
/// All endpoints under [PlacesController] — GET /api/places, etc.
class PlacesService {
  PlacesService._();
  static final PlacesService instance = PlacesService._();
  final _client = ApiClient.instance;

  // ── Browse places ─────────────────────────────────────────────────────────────
  /// GET /api/places?search=&category=&page=&pageSize=   [Authorize]
  Future<PlacedPagedResult> getPlaces({
    String? search,
    String? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = {
      if (search   != null && search.isNotEmpty)   'search':   search,
      if (category != null && category.isNotEmpty) 'category': category,
      'page':     page.toString(),
      'pageSize': pageSize.toString(),
    };
    final data = await _client.get(
      ApiConstants.places,
      queryParams: queryParams,
      auth: true,
    );
    return PlacedPagedResult.fromJson(data as Map<String, dynamic>);
  }

  // ── Place by id ───────────────────────────────────────────────────────────────
  /// GET /api/places/{id}   [Authorize]
  Future<Place> getPlaceById(int id) async {
    final data = await _client.get(ApiConstants.placeById(id), auth: true);
    return Place.fromJson(data as Map<String, dynamic>);
  }

  // ── Wishlist / Favorites ──────────────────────────────────────────────────────
  /// GET /api/places/favorites   [Authorize(Roles="Tourist")]
  Future<List<Place>> getFavorites() async {
    final data = await _client.get(ApiConstants.favorites, auth: true);
    final list = data as List;
    return list.map((e) => Place.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/places/{id}/favorite   [Authorize(Roles="Tourist")]
  Future<void> addToFavorites(int placeId) async {
    await _client.post(ApiConstants.addFavorite(placeId), auth: true);
  }

  /// DELETE /api/places/{id}/favorite   [Authorize(Roles="Tourist")]
  Future<void> removeFromFavorites(int placeId) async {
    await _client.delete(ApiConstants.removeFavorite(placeId), auth: true);
  }
}

/// My Plan API service.
///
/// Endpoints under [MyPlanController] — all Tourist-only.
class MyPlanService {
  MyPlanService._();
  static final MyPlanService instance = MyPlanService._();
  final _client = ApiClient.instance;

  // ── Get plan ──────────────────────────────────────────────────────────────────
  /// GET /api/myplan   [Authorize(Roles="Tourist")]
  Future<List<MyPlanItem>> getMyPlan() async {
    final data = await _client.get(ApiConstants.myPlan, auth: true);
    final list = data as List;
    return list.map((e) => MyPlanItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Add place ─────────────────────────────────────────────────────────────────
  /// POST /api/myplan/add   body: {placeId}   [Authorize(Roles="Tourist")]
  Future<void> addPlace(int placeId) async {
    await _client.post(
      ApiConstants.myPlanAdd,
      body: {'placeId': placeId},
      auth: true,
    );
  }

  // ── Remove place ──────────────────────────────────────────────────────────────
  /// DELETE /api/myplan/{placeId}   [Authorize(Roles="Tourist")]
  Future<void> removePlace(int placeId) async {
    await _client.delete(ApiConstants.myPlanRemove(placeId), auth: true);
  }
}
