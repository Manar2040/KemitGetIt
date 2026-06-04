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
  final Set<String> _requestedGuideIds = {};
  final _vm = HoldRequestViewModel();

  @override
  void dispose() {
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
          'Matched Guides',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: mockMatchedGuides.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final guide = mockMatchedGuides[index];
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
                    GestureDetector(
                      onTap: () async {
                        if (!_requestedGuideIds.contains(guide.id) && widget.requestData != null) {
                          // Build DTO
                          final dto = SendHoldRequestDto(
                            guideUserId: int.tryParse(guide.id) ?? 0,
                            requestType: widget.requestData!['requestType'] as RequestType,
                            travelerType: widget.requestData!['travelerType'] as TravelerType,
                            numberOfTravelers: widget.requestData!['numberOfTravelers'] as int,
                            preferredLanguage: widget.requestData!['preferredLanguage'] as String,
                            transportPreference: widget.requestData!['transportPreference'] as TransportPreference,
                            startDate: widget.requestData!['startDate'] as DateTime,
                            endDate: widget.requestData!['endDate'] as DateTime,
                            accommodationNeeded: widget.requestData!['accommodationNeeded'] as bool,
                            mealsIncluded: widget.requestData!['mealsIncluded'] as bool,
                          );

                          final success = await _vm.sendRequest(dto);
                          if (success && mounted) {
                            setState(() {
                              _requestedGuideIds.add(guide.id);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Request Sent to ${guide.name}. Status: Pending.'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_vm.errorMessage ?? 'Failed to send request'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else if (widget.requestData == null) {
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request data missing! Please go back and fill the form.'),
                              ),
                            );
                        }
                      },
                      child: _vm.isSending && !_requestedGuideIds.contains(guide.id)
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              _requestedGuideIds.contains(guide.id) ? 'Request Sent' : 'Send Request',
                              style: AppTextStyles.label.copyWith(
                                color: _requestedGuideIds.contains(guide.id) ? AppColors.textHint : const Color(0xFFB39256),
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
                  width: double.infinity,
                  child: _buildButton(
                    label: 'My Trip Plans',
                    backgroundColor: AppColors.primary,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.myPlan);
                    },
                  ),
                ),
                const SizedBox(height: 24),
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
