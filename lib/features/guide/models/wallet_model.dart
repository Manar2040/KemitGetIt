// wallet_model.dart

// ── 1. Wallet Balance ─────────────────────────────────────────────
class WalletModel {
  final double balance;
  final String currency;

  WalletModel({required this.balance, required this.currency});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
    );
  }
}

// ── 2. Transaction ────────────────────────────────────────────────
class TransactionModel {
  final int id;
  final String transactionType; // "credit" | "withdrawal" | "refund"
  final double amount;
  final String? description;
  final int? referenceId;
  final String status;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.transactionType,
    required this.amount,
    this.description,
    this.referenceId,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionType: json['transactionType'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      referenceId: json['referenceId'],
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isCredit => transactionType == 'credit';
}

// ── 3. Transactions Page ──────────────────────────────────────────
class TransactionsPageModel {
  final int totalCount;
  final int page;
  final int pageSize;
  final List<TransactionModel> items;

  TransactionsPageModel({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory TransactionsPageModel.fromJson(Map<String, dynamic> json) {
    return TransactionsPageModel(
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      items: (json['items'] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
    );
  }
}

// ── 4. Payout Settings ────────────────────────────────────────────
enum PayoutMethod { instapay, vodafoneCash }

class PayoutSettingsModel {
  final PayoutMethod payoutMethod;
  final String accountNumber;

  PayoutSettingsModel({
    required this.payoutMethod,
    required this.accountNumber,
  });

  factory PayoutSettingsModel.fromJson(Map<String, dynamic> json) {
    return PayoutSettingsModel(
      payoutMethod: (json['payoutMethod'] ?? 0) == 0
          ? PayoutMethod.instapay
          : PayoutMethod.vodafoneCash,
      accountNumber: json['accountNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'payoutMethod': payoutMethod == PayoutMethod.instapay ? 0 : 1,
        'accountNumber': accountNumber,
      };

  String get methodName =>
      payoutMethod == PayoutMethod.instapay ? 'Instapay' : 'Vodafone Cash';
}

// ── 5. Update Payout Settings Request ────────────────────────────
class UpdatePayoutSettingsRequest {
  final PayoutMethod payoutMethod;
  final String accountNumber;

  UpdatePayoutSettingsRequest({
    required this.payoutMethod,
    required this.accountNumber,
  });

  Map<String, dynamic> toJson() => {
        'payoutMethod': payoutMethod == PayoutMethod.instapay ? 0 : 1,
        'accountNumber': accountNumber,
      };
}