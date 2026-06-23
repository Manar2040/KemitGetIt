import '../../core/services/api_client.dart';

class BookingsService {
  BookingsService._();
  static final instance = BookingsService._();

  /// Fetches tourist's bookings and matches them with [holdRequestId]
  /// to return the corresponding [bookingId].
  Future<int?> getBookingIdForHoldRequest(int holdRequestId) async {
    try {
      final response = await ApiClient.instance.get('/api/bookings/my-bookings');
      if (response is List) {
        for (var item in response) {
          if (item is Map && item['holdRequestId'] == holdRequestId) {
            return item['id'] as int?;
          }
        }
      }
    } catch (_) {
      // Return null if call fails
    }
    return null;
  }
}
