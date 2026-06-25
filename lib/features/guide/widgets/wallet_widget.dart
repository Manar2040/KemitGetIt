// wallet_widget.dart
// أضيفيه في GuideProfileView تحت GuideInfoChipsWidget مباشرة
import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/wallet_service.dart';
import 'package:kemit_get_it/features/guide/models/wallet_model.dart';

class GuideWalletWidget extends StatefulWidget {
  const GuideWalletWidget({super.key});

  @override
  State<GuideWalletWidget> createState() => _GuideWalletWidgetState();
}

class _GuideWalletWidgetState extends State<GuideWalletWidget> {
  WalletModel? _wallet;
  TransactionsPageModel? _transactions;
  PayoutSettingsModel? _settings;
  bool _isLoading = true;
  bool _showTransactions = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        WalletService.getBalance(),
        WalletService.getTransactions(),
        WalletService.getSettings(),
      ]);
      if (!mounted) return;
      setState(() {
        _wallet = results[0] as WalletModel;
        _transactions = results[1] as TransactionsPageModel;
        _settings = results[2] as PayoutSettingsModel;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _openEditSettings() {
    if (_settings == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditPayoutSheet(
        current: _settings!,
        onSaved: (updated) async {
          await WalletService.updateSettings(
            UpdatePayoutSettingsRequest(
              payoutMethod: updated.payoutMethod,
              accountNumber: updated.accountNumber,
            ),
          );
          await _load();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payout settings updated')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Wallet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (!_isLoading && _wallet != null)
              GestureDetector(
                onTap: () =>
                    setState(() => _showTransactions = !_showTransactions),
                child: Text(
                  _showTransactions ? 'Hide History' : 'View History',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB9975B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFB9975B)),
          )
        else if (_wallet == null)
          const Text(
            'Failed to load wallet',
            style: TextStyle(color: Colors.grey),
          )
        else ...[
          // ── Balance Card ───────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB9975B), Color(0xFFD4A96A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_wallet!.balance.toStringAsFixed(0)} ${_wallet!.currency}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // ── Payout Settings Row ──────────────────────────
                if (_settings != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _settings!.methodName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _settings!.accountNumber.isEmpty
                                ? 'No account set'
                                : _settings!.accountNumber,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _openEditSettings,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Transactions ───────────────────────────────────────
          if (_showTransactions && _transactions != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_transactions!.items.isEmpty)
              const Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions!.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tx = _transactions!.items[index];
                  final isCredit = tx.isCredit;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isCredit
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      child: Icon(
                        isCredit
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: isCredit
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                        size: 18,
                      ),
                    ),
                    title: Text(
                      tx.description ?? tx.transactionType,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatDate(tx.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                    trailing: Text(
                      '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(0)} EGP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isCredit
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ════════════════════════════════════════════════════════
// Edit Payout Settings Bottom Sheet
// ════════════════════════════════════════════════════════
class _EditPayoutSheet extends StatefulWidget {
  final PayoutSettingsModel current;
  final Future<void> Function(PayoutSettingsModel) onSaved;

  const _EditPayoutSheet({required this.current, required this.onSaved});

  @override
  State<_EditPayoutSheet> createState() => _EditPayoutSheetState();
}

class _EditPayoutSheetState extends State<_EditPayoutSheet> {
  late PayoutMethod _selectedMethod;
  late TextEditingController _accountController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.current.payoutMethod;
    _accountController =
        TextEditingController(text: widget.current.accountNumber);
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_accountController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSaved(
        PayoutSettingsModel(
          payoutMethod: _selectedMethod,
          accountNumber: _accountController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update settings')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payout Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // ── Method Selector ──────────────────────────────────
          const Text('Payment Method', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              _MethodChip(
                label: 'Instapay',
                isSelected: _selectedMethod == PayoutMethod.instapay,
                onTap: () =>
                    setState(() => _selectedMethod = PayoutMethod.instapay),
              ),
              const SizedBox(width: 12),
              _MethodChip(
                label: 'Vodafone Cash',
                isSelected: _selectedMethod == PayoutMethod.vodafoneCash,
                onTap: () =>
                    setState(() => _selectedMethod = PayoutMethod.vodafoneCash),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Account Number ───────────────────────────────────
          const Text('Account Number', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _accountController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: _selectedMethod == PayoutMethod.instapay
                  ? 'e.g. name@instapay'
                  : 'e.g. 01012345678',
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFB9975B)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9975B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB9975B) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFB9975B) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}