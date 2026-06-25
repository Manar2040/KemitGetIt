import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

class HoldRequestService {
  // ── جيب كل الـ requests أو فلتر بالـ status ──────────────
  // GET /api/hold-requests?status=...
  static Future<List<HoldRequestModel>> getRequests({String? status}) async {
    final endpoint = status != null
        ? '/api/hold-requests?status=$status'
        : '/api/hold-requests';

    final response = await ApiService.get(endpoint);
    final List data = response.data as List;
    return data.map((e) => HoldRequestModel.fromJson(e)).toList();
  }

  // ── جيب بس الـ PendingRequest (للـ Home preview) ─────────
  // status=0 = PendingRequest على الـ backend (integer enum)
  static Future<List<HoldRequestModel>> getPendingRequests() async {
    return getRequests(status: '0'); // ✅ الـ API بتتوقع integer مش string
  }

  // ── جيب تفاصيل request واحد ──────────────────────────────
  // GET /api/hold-requests/{id}
  static Future<HoldRequestModel> getRequestById(int id) async {
    final response = await ApiService.get('/api/hold-requests/$id');
    return HoldRequestModel.fromJson(response.data);
  }

  // ── اقبل الـ request ──────────────────────────────────────
  // PUT /api/hold-requests/{id}/accept
  static Future<bool> acceptRequest(int id) async {
    try {
      final response = await ApiService.put(
        '/api/hold-requests/$id/accept',
        {},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── ارفض الـ request ──────────────────────────────────────
  // PUT /api/hold-requests/{id}/decline
  static Future<bool> declineRequest(int id) async {
    try {
      final response = await ApiService.put(
        '/api/hold-requests/$id/decline',
        {},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── حدد السعر (PrivateTrip — الجايد بيحدد السعر الأول) ──
// PUT /api/hold-requests/{id}/set-price
// الـ response: 200 OK بدون body
static Future<bool> setPrice({
  required int id,
  required double price,
  required String currency,
}) async {
  try {
    final response = await ApiService.put(
      '/api/hold-requests/$id/set-price',
      {'price': price, 'currency': currency},
    );
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
}