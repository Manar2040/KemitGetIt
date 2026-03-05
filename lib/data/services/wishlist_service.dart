import '../models/place.dart';

class WishlistService {
  // Using a static set for simplicity to mock a global state or database
  static final Set<Place> _wishlist = {};

  static List<Place> getWishlist() {
    return _wishlist.toList();
  }

  static void addPlace(Place place) {
    _wishlist.add(place);
  }

  static void removePlace(Place place) {
    _wishlist.removeWhere((p) => p.id == place.id);
  }

  static bool isWishlisted(String placeId) {
    return _wishlist.any((p) => p.id == placeId);
  }
}
