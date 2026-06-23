import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../data/trip_flow_mock_data.dart';

import '../../../routes/app_routes.dart';
import '../../../data/models/hold_request_models.dart';
import '../viewmodel/hold_request_viewmodel.dart';

class MatchedGuidesView extends StatefulWidget {
  final Map<String, dynamic>? requestData;

  const MatchedGuidesView({super.key, this.requestData});

  @override
  State<MatchedGuidesView> createState() => _MatchedGuidesViewState();
}

class _MatchedGuidesViewState extends State<MatchedGuidesView> {
  final _vm = HoldRequestViewModel();
  String? _sendingGuideId;

  // --- Bug Fix #2: Correct backend status constants ---
  static const _statusPending   = 'PendingRequest';
  static const _statusAccepted  = 'Accepted';
  static const _statusDeclined  = 'Declined';
  static const _statusCancelled = 'Cancelled';
  static const _statusPaid      = 'Paid';
  static const _statusActive    = 'Active';
  static const _statusCompleted = 'Completed';

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
    _vm.loadMyRequests();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  int _getDbUserIdForMockGuide(String mockGuideId) {
    switch (mockGuideId) {
      case '1': return 1;
      case '2': return 2;
      case '3': return 3;
      case '4': return 6;
      case '5': return 13;
      default: return 0;
    }
  }

  HoldRequestDto? _getRequestForGuide(String mockGuideId) {
    final dbUserId = _getDbUserIdForMockGuide(mockGuideId);
    if (dbUserId == 0) return null;

    final matches = _vm.myRequests.where((r) => r.guideUserId == dbUserId).toList();
    if (matches.isEmpty) return null;

    // Sort to get the latest one
    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.first;
  }

  bool _isRejectedOrCancelled(String status) =>
      status == _statusDeclined || status == _statusCancelled;

  bool _isApprovedOrBeyond(String status) =>
      status == _statusAccepted ||
      status == _statusPaid ||
      status == _statusActive ||
      status == _statusCompleted;

  String _formatDeadline(DateTime? deadline) {
    if (deadline == null) return '';
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return 'Deadline passed';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    if (hours > 24) return '${remaining.inDays}d left to pay';
    if (hours > 0) return '${hours}h ${minutes}m left to pay';
    return '${minutes}m left to pay';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark),
          iconSize: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Matched Guides',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: mockMatchedGuides.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final guide = mockMatchedGuides[index];
                      final req = _getRequestForGuide(guide.id);

                      Widget trailingWidget;

                      // --- Bug Fix #2: Use correct backend status strings ---
                      if (req == null || _isRejectedOrCancelled(req.status)) {
                        // No request yet OR declined/cancelled → show Send Request
                        trailingWidget = GestureDetector(
                          onTap: () async {
                            if (widget.requestData == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please go back and fill in your trip details first.'),
                                ),
                              );
                              return;
                            }

                            setState(() => _sendingGuideId = guide.id);

                            final dto = SendHoldRequestDto(
                              guideUserId: _getDbUserIdForMockGuide(guide.id),
                              requestType: widget.requestData!['requestType'] as RequestType,
                              travelerType: widget.requestData!['travelerType'] as TravelerType,
                              numberOfTravelers: widget.requestData!['numberOfTravelers'] as int,
                              preferredLanguage: widget.requestData!['preferredLanguage'] as String,
                              transportPreference: widget.requestData!['transportPreference'] as TransportPreference,
                              startDate: widget.requestData!['startDate'] as DateTime,
                              endDate: widget.requestData!['endDate'] as DateTime,
                              accommodationNeeded: widget.requestData!['accommodationNeeded'] as bool,
                              mealsIncluded: widget.requestData!['mealsIncluded'] as bool,
                              selectedPlaceIds: (widget.requestData!['selectedPlaceIds'] as List<int>?) ?? [],
                            );

                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final success = await _vm.sendRequest(dto);
                            
                            if (!mounted) return;
                            setState(() => _sendingGuideId = null);

                            if (success) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Request sent to ${guide.name}. Status: Pending.'),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              _vm.loadMyRequests();
                            } else {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(_vm.errorMessage ?? 'Failed to send request'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: _vm.isSending && _sendingGuideId == guide.id
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                )
                              : Text(
                                  req != null ? '↩ Try Again' : 'Send Request',
                                  style: AppTextStyles.label.copyWith(
                                    color: req != null ? AppColors.error : const Color(0xFFB39256),
                                    fontSize: 14,
                                  ),
                                ),
                        );
                      } else if (req.status == _statusPending) {
                        // --- Pending state ---
                        trailingWidget = Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: const Text(
                            '⏳ Pending',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      } else if (_isApprovedOrBeyond(req.status)) {
                        // --- Bug Fix #3: Accepted → show Pay Now + Chat ---
                        trailingWidget = Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (req.status == _statusAccepted) ...[
                              // Pay Now button
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.payment,
                                    arguments: {
                                      'holdRequestId': req.id,
                                      'guideName': req.guideName ?? guide.name,
                                      'totalPrice': req.totalPrice,
                                      'currency': req.currency ?? 'EGP',
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '💳 Pay Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (req.paymentDeadline != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _formatDeadline(req.paymentDeadline),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ] else ...[
                              // Paid/Active/Completed → show Approved badge + Chat
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.success),
                                    ),
                                    child: Text(
                                      req.status == _statusPaid ? '✅ Paid' : '✅ ${req.status}',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                                    onPressed: () {
                                      Navigator.pushNamed(context, AppRoutes.chatsList);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      } else {
                        trailingWidget = const SizedBox.shrink();
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(guide.imageUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  guide.name,
                                  style: AppTextStyles.label.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.guideProfile, arguments: guide.id);
                                  },
                                  child: Text(
                                    'View Profile',
                                    style: AppTextStyles.bodyTextSmall.copyWith(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailingWidget,
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: _buildButton(
                label: 'My Trip Plans',
                backgroundColor: AppColors.primary,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.myPlan);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
