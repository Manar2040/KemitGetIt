import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../../../routes/app_routes.dart';
import '../../../core/themes/text_styles.dart';
import '../viewmodel/hold_request_viewmodel.dart';
import '../../../data/models/hold_request_models.dart';
import '../../../data/services/bookings_service.dart';

class MyRequestsView extends StatefulWidget {
  const MyRequestsView({super.key});

  @override
  State<MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<MyRequestsView> {
  final _vm = HoldRequestViewModel();

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onStateChanged);
    _vm.loadMyRequests();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onStateChanged);
    _vm.dispose();
    super.dispose();
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
          'My Requests',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: _vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vm.errorMessage != null
              ? Center(child: Text(_vm.errorMessage!))
              : _vm.myRequests.isEmpty
                  ? const Center(child: Text('You have no requests yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _vm.myRequests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final req = _vm.myRequests[index];
                        return _buildRequestCard(req);
                      },
                    ),
    );
  }

  String _getRequestTitle(HoldRequestDto req) {
    if (req.requestType == 'ReadyTrip') {
      return req.tripTitle ?? 'Ready Trip';
    }
    
    if (req.selectedPlaces.isNotEmpty) {
      final placeNames = req.selectedPlaces
          .map((p) => p.placeName)
          .where((name) => name != null && name.isNotEmpty)
          .join(', ');
      if (placeNames.isNotEmpty) return placeNames;
    }
    
    return 'Private Trip';
  }

  Widget _buildRequestCard(HoldRequestDto req) {
    return InkWell(
      onTap: () {
        if (req.tripId != null) {
          // Ready Trip → open trip details page
          Navigator.pushNamed(
            context,
            AppRoutes.tripPlanDetails,
            arguments: <String, dynamic>{
              'tripId': req.tripId,
              'requestStatus': req.status,
              'requestId': req.id,
              'requestGuideUserId': req.guideUserId,
            },
          );
        } else if (req.status == 'PendingRequest') {
          // Private Trip that is pending → show matched guides so user can track/manage the request
          Navigator.pushNamed(
            context,
            AppRoutes.matchedGuides,
            arguments: <String, dynamic>{
              'selectedPlaceIds': req.selectedPlaces.map((p) => p.placeId).toList(),
              'startDate': req.startDate.toIso8601String(),
              'endDate': req.endDate.toIso8601String(),
              'numberOfTravelers': req.numberOfTravelers,
              'travelerType': req.travelerType,
              'language': req.preferredLanguage,
              'transportPreference': req.transportPreference,
              'accommodationNeeded': req.accommodationNeeded,
              'mealsIncluded': req.mealsIncluded,
            },
          );
        }
        // Other private trip statuses: buttons inside the card handle the actions.
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getRequestTitle(req),
                    style: AppTextStyles.heading3,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(req.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    req.status,
                    style: AppTextStyles.label.copyWith(color: _getStatusColor(req.status), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Guide: ${req.guideName ?? 'Unknown'}', style: AppTextStyles.bodyTextSmall),
            const SizedBox(height: 4),
            Text('Dates: ${_formatDate(req.startDate)} - ${_formatDate(req.endDate)}', style: AppTextStyles.bodyTextSmall),
            const SizedBox(height: 4),
            Text('Travelers: ${req.numberOfTravelers} (${req.travelerType})', style: AppTextStyles.bodyTextSmall),
            if (req.totalPrice > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Price: ${req.totalPrice} ${req.currency ?? 'EGP'}',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ],
            
            // Action Buttons
            if (req.status == 'Accepted') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.payment,
                      arguments: {
                        'holdRequestId': req.id,
                        'guideName': req.guideName ?? '',
                        'totalPrice': req.totalPrice,
                        'currency': req.currency ?? 'EGP',
                      },
                    );
                  },
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ] else if (['Paid', 'Active', 'Completed'].contains(req.status)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    final tempChatVm = ChatViewModel();
                    await tempChatVm.loadConversations();
                    
                    final bookingId = await BookingsService.instance.getBookingIdForHoldRequest(req.id);
                    
                    navigator.pop();

                    try {
                      if (bookingId == null) {
                        throw Exception('Booking ID not found');
                      }
                      
                      final index = tempChatVm.conversations.indexWhere((c) => c.bookingId == bookingId);

                      if (index == -1) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Chat Not Available'),
                            content: const Text('No conversation history has been generated for this trip. This happens for some trips in the backend mock data.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      final conversation = tempChatVm.conversations[index];

                      navigator.pushNamed(AppRoutes.guideChat, arguments: {
                        'conversationId': conversation.id,
                        'bookingId': bookingId,
                        'otherParticipantName': req.guideName ?? 'Guide',
                        'status': req.status,
                      });
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Chat Error'),
                          content: Text('An error occurred while trying to open the chat: $e'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } finally {
                      tempChatVm.dispose();
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat with Guide'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendingrequest':
        return Colors.orange;
      case 'accepted':
      case 'paid':
      case 'active':
      case 'completed':
        return AppColors.success;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      case 'paymentpending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
