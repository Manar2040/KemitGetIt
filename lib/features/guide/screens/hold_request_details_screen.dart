import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/hold_request_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

const kGold = Color(0xFF8B6914);
const kBorder = Color(0xFFE5DDD0);
const kTextDark = Color(0xFF1A1A1A);
const kTextGrey = Color(0xFF888888);
const kTimerOrange = Color(0xFFD97B2B);

class HoldRequestDetailsScreen extends StatefulWidget {
  final HoldRequestModel request;
  const HoldRequestDetailsScreen({super.key, required this.request});

  @override
  State<HoldRequestDetailsScreen> createState() =>
      _HoldRequestDetailsScreenState();
}

class _HoldRequestDetailsScreenState extends State<HoldRequestDetailsScreen> {
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String _timeLeft() {
    if (widget.request.paymentDeadline == null) return '';
    final diff = widget.request.paymentDeadline!.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours < 24) return '${diff.inHours}h left';
    return '${diff.inDays}d left';
  }

  // PrivateTrip = tripId == null (التوريست هو اللي طلب custom)
  bool get _isPrivateTrip => widget.request.tripId == null;

  // ── Set Price Dialog (PrivateTrip فقط) ───────────────────
  void _showSetPriceDialog() {
    _priceController.clear();
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Set Trip Price",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kTextDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, color: kTextGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Enter the price for this trip",
                    style: TextStyle(color: kTextGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: "e.g. 450",
                      hintStyle: const TextStyle(
                        color: kTextGrey,
                        fontSize: 13,
                      ),
                      suffixText: widget.request.currency,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx); // ✅ يقفل الـ dialog بس
                        _submitSetPrice(); // ✅ بيشتغل على الشاشة، مش على ctx
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Confirm & Send",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // ── الـ API call لـ set-price فقط ────────────────────────
  Future<void> _submitSetPrice() async {
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);

    if (price == null || price <= 0) {
      _showSnack("Please enter a valid price", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // الخطوة 1: حدد السعر
    final priceSet = await HoldRequestService.setPrice(
      id: widget.request.id,
      price: price,
      currency:
          widget.request.currency.isNotEmpty ? widget.request.currency : 'USD',
    );

    if (!priceSet) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack("Failed to set price. Please try again.", isError: true);
      }
      return;
    }

    // الخطوة 2: accept → status يتحول لـ PaymentPending
    final accepted = await HoldRequestService.acceptRequest(widget.request.id);

    if (mounted) {
      setState(() => _isLoading = false);
      _showSnack(
        accepted
            ? "Price set & request accepted ✓"
            : "Price set, but accept failed — try again",
        isError: !accepted,
      );
      if (accepted) Navigator.pop(context);
    }
  }

  // ── Accept ────────────────────────────────────────────────
  Future<void> _handleAccept() async {
    if (_isPrivateTrip) {
      _showSetPriceDialog();
      return;
    }
    setState(() => _isLoading = true);
    final success = await HoldRequestService.acceptRequest(widget.request.id);
    if (mounted) {
      setState(() => _isLoading = false);
      _showSnack(
        success ? "Hold Request Accepted ✓" : "Failed to accept",
        isError: !success,
      );
      if (success) Navigator.pop(context);
    }
  }

  // ── Decline ───────────────────────────────────────────────
  Future<void> _handleDecline() async {
    setState(() => _isLoading = true);
    final success = await HoldRequestService.declineRequest(widget.request.id);
    if (mounted) {
      setState(() => _isLoading = false);
      _showSnack(
        success ? "Request Declined" : "Failed to decline",
        isError: !success,
      );
      if (success) Navigator.pop(context);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : kGold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final timeLeft = _timeLeft();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Hold Request",
          style: TextStyle(
            color: kTextDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── Tourist Row ───────────────────────────
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          child: Icon(Icons.person, size: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.touristName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: kTextDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // GestureDetector(
                              //   child: Container(
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 12,
                              //       vertical: 4,
                              //     ),
                              //     decoration: BoxDecoration(
                              //       color: kGold,
                              //       borderRadius: BorderRadius.circular(20),
                              //     ),
                              //     child: const Text(
                              //       "Chat With",
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 12,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                        // ── Status + Timer ──────────────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _StatusBadge(status: req.status),
                            if (timeLeft.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 13,
                                    color: kTimerOrange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeLeft,
                                    style: const TextStyle(
                                      color: kTimerOrange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Trip Title (لو ReadyTrip) ─────────────
                    if (req.tripTitle != null) ...[
                      _SectionCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              color: kGold,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                req.tripTitle!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: kTextDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Selected Places (PrivateTrip) ─────────
                    if (req.selectedPlaces.isNotEmpty) ...[
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Requested Places",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...req.selectedPlaces.map(
                              (place) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: kGold.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${place.order}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: kGold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      place.placeName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: kTextDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── Details Card ──────────────────────────
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Details",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _DetailItem(
                                  label: "Traveler Type",
                                  value:
                                      "${req.travelerType} (${req.numberOfTravelers})",
                                  icon: Icons.person_outline,
                                ),
                              ),
                              Expanded(
                                child: _DetailItem(
                                  label: "Language",
                                  value: req.preferredLanguage,
                                  icon: Icons.language_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _DetailItem(
                                  label: "Transport",
                                  value: req.transportPreference,
                                  icon: Icons.directions_car_outlined,
                                ),
                              ),
                              if (!_isPrivateTrip || req.totalPrice > 0)
                                Expanded(
                                  child: _DetailItem(
                                    label:
                                        _isPrivateTrip
                                            ? "Tourist Budget"
                                            : "Price",
                                    value:
                                        "${req.totalPrice.toStringAsFixed(0)} ${req.currency}",
                                    icon: Icons.attach_money,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Additional Services",
                            style: TextStyle(fontSize: 12, color: kTextGrey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (req.mealsIncluded) "Meals Included",
                              if (req.accommodationNeeded) "Accommodation",
                              if (!req.mealsIncluded &&
                                  !req.accommodationNeeded)
                                "None",
                            ].join(" • "),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Dates ─────────────────────────────────
                    _buildDateRow("Start Date", _formatDate(req.startDate)),
                    const SizedBox(height: 10),
                    _buildDateRow("End Date", _formatDate(req.endDate)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Buttons ───────────────────────────────────────
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: kGold),
                ),
              )
            // ✅ بعد
            else if (req.status == 'PendingRequest')
              Column(
                children: [
                  GestureDetector(
                    onTap: _handleAccept,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kGold,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _isPrivateTrip
                            ? "Set Price & Accept"
                            : "Accept Hold Request",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _handleDecline,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Decline Request",
                        style: TextStyle(
                          color: kTextDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  Widget _buildDateRow(String label, String date) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: kTextDark,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(date, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// Helper Widgets
// ════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey)),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 15, color: kTextGrey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'PendingRequest':
        return const Color(0xFFD97B2B);
      case 'Accepted':
      case 'Paid':
        return Colors.green;
      case 'Declined':
      case 'Cancelled':
      case 'Expired':
        return Colors.red;
      case 'Completed':
        return kGold;
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (status) {
      case 'PendingRequest':
        return 'Pending';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
