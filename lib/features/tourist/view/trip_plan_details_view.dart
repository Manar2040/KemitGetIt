import 'package:flutter/material.dart';
import '../../../data/models/trip_models.dart';
import '../viewmodel/trips_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/hold_request_service.dart';
import '../../../data/models/hold_request_models.dart';

class TripPlanDetailsPage extends StatefulWidget {
  final int tripId;
  final String? requestStatus;
  final int? requestId;
  final int? requestGuideUserId;

  const TripPlanDetailsPage({
    super.key,
    required this.tripId,
    this.requestStatus,
    this.requestId,
    this.requestGuideUserId,
  });

  @override
  State<TripPlanDetailsPage> createState() => _TripPlanDetailsPageState();
}

class _TripPlanDetailsPageState extends State<TripPlanDetailsPage> {
  final _vm = TripDetailsViewModel();
  bool _isRequested = false;

  String? _resolvedRequestStatus;

  @override
  void initState() {
    super.initState();
    _resolvedRequestStatus = widget.requestStatus;

    _vm.addListener(_onVmChanged);
    _vm.loadTripDetails(widget.tripId);
    _checkActiveRequest();
  }

  Future<void> _checkActiveRequest() async {
    // If requestStatus is already passed from MyRequestsView, we don't need to resolve it
    if (widget.requestStatus != null) return;

    try {
      final requests = await HoldRequestsService.instance.getMyRequests();
      HoldRequestDto? activeReq;
      for (var r in requests) {
        if (r.tripId == widget.tripId) {
          final statusL = r.status.toLowerCase();
          // Prioritize active or completed requests. Ignore cancelled/declined
          if (statusL != 'cancelled' && statusL != 'declined') {
            activeReq = r;
            break;
          }
        }
      }

      final req = activeReq;
      if (req != null && mounted) {
        setState(() {
          _resolvedRequestStatus = req.status;
        });
      }
    } catch (_) {
      // Fail silently
    }
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark),
          iconSize: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Trip Plan Details',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: _vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vm.errorMessage != null
              ? Center(child: Text(_vm.errorMessage!))
              : _vm.trip == null
                  ? const Center(child: Text('Trip not found'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRequestStatusBanner(),
                            _buildHeaderSection(_vm.trip!),
                            const SizedBox(height: 24),
                            _buildTagsAndShare(_vm.trip!),
                            const SizedBox(height: 24),
                            _buildOverviewSection(_vm.trip!),
                            const SizedBox(height: 24),
                            _buildTripInformationSection(_vm.trip!),
                            const SizedBox(height: 24),
                            _buildItinerarySection(_vm.trip!),
                            const SizedBox(height: 24),
                            _buildGuideSection(context, _vm.trip!),
                            const SizedBox(height: 24),
                            _buildReviewsSection(_vm.trip!),
                            const SizedBox(height: 32),
                            _buildSendRequestButton(context, _vm.trip!),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildRequestStatusBanner() {
    if (_resolvedRequestStatus == null) return const SizedBox.shrink();
    
    final status = _resolvedRequestStatus!;
    Color statusColor = Colors.grey;
    IconData icon = Icons.info_outline;
    String displayStatus = status;

    switch (status.toLowerCase()) {
      case 'pendingrequest':
        statusColor = Colors.orange;
        icon = Icons.hourglass_empty;
        displayStatus = 'Pending Request';
        break;
      case 'accepted':
        statusColor = AppColors.success;
        icon = Icons.check_circle_outline;
        displayStatus = 'Accepted';
        break;
      case 'paid':
        statusColor = AppColors.success;
        icon = Icons.payment;
        displayStatus = 'Paid';
        break;
      case 'active':
        statusColor = AppColors.success;
        icon = Icons.directions_run;
        displayStatus = 'Active';
        break;
      case 'completed':
        statusColor = AppColors.success;
        icon = Icons.done_all;
        displayStatus = 'Completed';
        break;
      case 'declined':
        statusColor = Colors.red;
        icon = Icons.cancel_outlined;
        displayStatus = 'Declined';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        icon = Icons.block;
        displayStatus = 'Cancelled';
        break;
      case 'paymentpending':
        statusColor = Colors.blue;
        icon = Icons.hourglass_bottom;
        displayStatus = 'Payment Pending';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Status',
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  displayStatus,
                  style: AppTextStyles.heading3.copyWith(color: statusColor, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(TripDetails details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: details.coverImageUrl != null && details.coverImageUrl!.isNotEmpty
              ? Image.network(
                  details.coverImageUrl!,
                  width: 140,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 140,
                    height: 180,
                    color: AppColors.borderLight,
                    child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
                  ),
                )
              : Container(
                  width: 140,
                  height: 180,
                  color: AppColors.borderLight,
                  child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.title,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                'By Guide: ${details.guide?.name ?? 'Unknown'}',
                style: AppTextStyles.bodyText,
              ),
              Text(
                '"${details.guide?.title ?? 'Guide'}"',
                style: AppTextStyles.bodyText.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${details.guide?.rating ?? 0.0}(${details.guide?.reviews ?? 0})',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '(${details.guide?.reviews ?? 0}) Rating',
                style: AppTextStyles.bodyTextSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsAndShare(TripDetails details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                details.tripType,
                style: AppTextStyles.label.copyWith(color: AppColors.surface, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            const SizedBox(width: 4),
            Text('Share', style: AppTextStyles.label),
          ],
        )
      ],
    );
  }

  Widget _buildOverviewSection(TripDetails details) {
    if (details.description == null || details.description!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          details.description!,
          style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildTripInformationSection(TripDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Information',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Start Date', '${details.startDate.day}/${details.startDate.month}/${details.startDate.year}'),
        _buildInfoRow('Starting Point', details.startingPoint),
        _buildInfoRow('Ending point', details.endingPoint),
        _buildInfoRow('Duration', '${details.durationDays} Days / ${details.durationNights} Nights'),
        _buildInfoRow('Group Size', 'Up to ${details.maxParticipants} participants'),
        _buildInfoRow('price', '${details.currency} ${details.price}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.label,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerarySection(TripDetails details) {
    if (details.itineraryDays.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itinerary',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        ...details.itineraryDays.map((day) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'Day ${day.dayNumber}',
                    style: AppTextStyles.label,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: AppTextStyles.label,
                      ),
                      Text(
                        '- ${day.description}',
                        style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGuideSection(BuildContext context, TripDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guide Information',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context, 
                '/guide-profile', // Hardcoded string since AppRoutes is not imported
                arguments: details.guide?.id ?? details.guideId.toString(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Guide Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(TripDetails details) {
    if (details.recentReviews.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        ...details.recentReviews.map((review) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textHint),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
                      children: [
                        TextSpan(
                          text: '${review.touristName} - ',
                          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '"${review.comment}"',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSendRequestButton(BuildContext context, TripDetails details) {
    if (_resolvedRequestStatus != null) {
      final status = _resolvedRequestStatus!.toLowerCase();

      // Completed → show info banner (review opens from FCM notification only, per scenario)
      if (status == 'completed') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  '✅ Trip completed! Check your notifications to rate your experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // If active / pending / paid / accepted / paymentpending: show a banner, hide send request button
      if (status == 'pendingrequest' ||
          status == 'accepted' ||
          status == 'paid' ||
          status == 'active' ||
          status == 'paymentpending') {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Text(
              'You already have an active request for this trip.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }
    }

    if (_isRequested) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC1A46A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // Mock edit request action
              },
              child: const Text(
                'Edit Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC1A46A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // Cancel Trip
                setState(() {
                  _isRequested = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip Request Cancelled'),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Cancel Trip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB39256), // Similar to the mock color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.tripRequestForm,
            arguments: {
              'isFromTripPlan': true,
              'tripPlan': details,
            },
          );
        },
        child: const Text(
          'Send a Request',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
