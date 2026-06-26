// wallet_service.dart
import 'package:kemit_get_it/features/guide/core/api_service.dart';
import 'package:kemit_get_it/features/guide/models/wallet_model.dart';

class WalletService {
  // ── 1. GET /api/wallet ────────────────────────────────────────
  static Future<WalletModel> getBalance() async {
    final response = await ApiService.get('/api/wallet');
    return WalletModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── 2. GET /api/wallet/transactions ──────────────────────────
  static Future<TransactionsPageModel> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiService.get(
      '/api/wallet/transactions?page=$page&limit=$limit',
    );
    return TransactionsPageModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // ── 3. GET /api/wallet/settings ──────────────────────────────
  static Future<PayoutSettingsModel> getSettings() async {
    final response = await ApiService.get('/api/wallet/settings');
    return PayoutSettingsModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── 4. PUT /api/wallet/settings ──────────────────────────────
  static Future<void> updateSettings(
    UpdatePayoutSettingsRequest request,
  ) async {
    await ApiService.put('/api/wallet/settings', request.toJson());
  }
}