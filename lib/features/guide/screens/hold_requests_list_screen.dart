import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/hold_request_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/features/guide/screens/hold_request_details_screen.dart';

const kGold = Color(0xFF8B6914);
const kBorder = Color(0xFFE5DDD0);
const kTextDark = Color(0xFF1A1A1A);
const kTextGrey = Color(0xFF888888);
const kTimerOrange = Color(0xFFD97B2B);

class HoldRequestsListScreen extends StatefulWidget {
  const HoldRequestsListScreen({super.key});

  @override
  State<HoldRequestsListScreen> createState() =>
      _HoldRequestsListScreenState();
}

class _HoldRequestsListScreenState extends State<HoldRequestsListScreen> {
  String _selectedFilter = "All";
  List<HoldRequestModel> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await HoldRequestService.getRequests();
      if (mounted) {
        setState(() {
          _requests = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load requests';
          _isLoading = false;
        });
      }
    }
  }

  // Guide Trip = عنده tripId  |  Tourist Trip = tripId == null
  List<HoldRequestModel> get _filtered {
    if (_selectedFilter == "Guide Trips") {
      return _requests.where((r) => r.tripId != null).toList();
    } else if (_selectedFilter == "Tourist Trips") {
      return _requests.where((r) => r.tripId == null).toList();
    }
    return _requests;
  }

  String _timeLeft(HoldRequestModel req) {
    if (req.paymentDeadline == null) return '';
    final diff = req.paymentDeadline!.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours < 24) return '${diff.inHours}h left';
    return '${diff.inDays}d left';
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kGold : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kGold : kBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : kTextGrey,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4EF),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Hold Requests",
          style: TextStyle(
            color: kTextDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Filters ──
            Row(
              children: [
                _buildFilterChip("All"),
                const SizedBox(width: 10),
                _buildFilterChip("Guide Trips"),
                const SizedBox(width: 10),
                _buildFilterChip("Tourist Trips"),
              ],
            ),
            const SizedBox(height: 16),

            // ── Content ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kGold))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!,
                                  style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _loadRequests,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: kGold),
                                child: const Text("Retry",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                          ? const Center(
                              child: Text("No requests found",
                                  style: TextStyle(
                                      color: kTextGrey, fontSize: 15)))
                          : RefreshIndicator(
                              onRefresh: _loadRequests,
                              color: kGold,
                              child: ListView.builder(
                                itemCount: _filtered.length,
                                itemBuilder: (context, index) {
                                  final req = _filtered[index];
                                  final timeLeft = _timeLeft(req);
                                  return GestureDetector(
                                    // ✅ await + _loadRequests بعد الرجوع
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              HoldRequestDetailsScreen(
                                                  request: req),
                                        ),
                                      );
                                      _loadRequests(); // ✅ ريفريش تلقائي
                                    },
                                    child: Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                            color: kBorder, width: 1.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.03),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info_outline,
                                              color: kTextGrey),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  req.tripTitle ??
                                                      req.requestType,
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14,
                                                    color: kTextDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  "From: ${req.touristName}",
                                                  style: const TextStyle(
                                                    color: kTextGrey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (timeLeft.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.access_time,
                                                        size: 13,
                                                        color: kTimerOrange),
                                                    const SizedBox(width: 4),
                                                    Text(timeLeft,
                                                        style: const TextStyle(
                                                            color: kTimerOrange,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ],
                                                ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 14,
                                                    vertical: 5),
                                                decoration: BoxDecoration(
                                                  border:
                                                      Border.all(color: kGold),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  "Review",
                                                  style: TextStyle(
                                                    color: kGold,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}