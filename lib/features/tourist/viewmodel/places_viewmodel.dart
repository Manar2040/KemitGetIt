import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../data/models/place.dart';
import '../../../data/services/places_service.dart';

/// ViewModel for Home and Search screens — browses places from the real API.
class PlacesViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<Place> places = [];
  int currentPage = 1;
  bool hasMore = true;

  Future<void> loadPlaces({
    String? search,
    String? category,
    bool refresh = false,
  }) async {
    if (refresh) {
      currentPage = 1;
      hasMore = true;
      places = [];
    }
    if (!hasMore || isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await PlacesService.instance.getPlaces(
        search:   search,
        category: category,
        page:     currentPage,
      );
      places.addAll(result.items);
      
      // Move Mosque of Muhammad Ali to be second in the list (after Pyramids)
      final mosqueIndex = places.indexWhere((p) => p.name.contains('Muhammad Ali'));
      if (mosqueIndex > 0) {
        final mosque = places.removeAt(mosqueIndex);
        places.insert(1, mosque);
      }

      hasMore = places.length < result.totalCount;
      currentPage++;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (_) {
      errorMessage = 'Could not load places. Check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

/// ViewModel for the Wishlist screen.
class WishlistViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isToggling = false;
  String? errorMessage;
  List<Place> wishlist = [];

  Future<void> loadWishlist() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      wishlist = await PlacesService.instance.getFavorites();
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (_) {
      errorMessage = 'Could not load wishlist. Check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFromWishlist(int placeId) async {
    isToggling = true;
    notifyListeners();
    try {
      await PlacesService.instance.removeFromFavorites(placeId);
      wishlist.removeWhere((p) => p.id == placeId);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      return false;
    } catch (_) {
      errorMessage = 'Could not remove from wishlist.';
      return false;
    } finally {
      isToggling = false;
      notifyListeners();
    }
  }

  Future<bool> addToWishlist(int placeId) async {
    try {
      await PlacesService.instance.addToFavorites(placeId);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Could not add to wishlist.';
      notifyListeners();
      return false;
    }
  }
}

/// ViewModel for the My Plan screen.
class MyPlanViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isModifying = false;
  String? errorMessage;
  List<MyPlanItem> planItems = [];

  Future<void> loadPlan() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      planItems = await MyPlanService.instance.getMyPlan();
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (e) {
      errorMessage = 'Could not load plan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPlace(int placeId) async {
    isModifying = true;
    notifyListeners();
    try {
      await MyPlanService.instance.addPlace(placeId);
      await loadPlan();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Could not add to plan.';
      notifyListeners();
      return false;
    } finally {
      isModifying = false;
      notifyListeners();
    }
  }

  Future<bool> removePlace(int placeId) async {
    isModifying = true;
    notifyListeners();
    try {
      await MyPlanService.instance.removePlace(placeId);
      planItems.removeWhere((item) => item.placeId == placeId);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.userMessage;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Could not remove from plan.';
      notifyListeners();
      return false;
    } finally {
      isModifying = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
