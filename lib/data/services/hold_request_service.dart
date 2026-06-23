import '../models/hold_request_models.dart';
import '../../core/services/api_client.dart';

class HoldRequestsService {
  HoldRequestsService._();
  static final instance = HoldRequestsService._();

  final String _basePath = '/api/hold-requests';

  Future<HoldRequestDto> sendRequest(SendHoldRequestDto req) async {
    final response = await ApiClient.instance.post(
      _basePath,
      body: req.toJson(),
      auth: true,
    );
    return HoldRequestDto.fromJson(response);
  }

  Future<List<HoldRequestDto>> getMyRequests() async {
    final response = await ApiClient.instance.get(
      '$_basePath/my-requests',
      auth: true,
    );
    if (response is List) {
      return response.map((e) => HoldRequestDto.fromJson(e)).toList();
    }
    return [];
  }

  Future<HoldRequestDto> getRequestDetails(int id) async {
    final response = await ApiClient.instance.get('$_basePath/$id', auth: true);
    return HoldRequestDto.fromJson(response);
  }
}
