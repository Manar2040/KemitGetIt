import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../data/trip_plan_model.dart';
// Note: GuideProfilePage import will be added later when available.

class TripPlanDetailsPage extends StatelessWidget {
  const TripPlanDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // using dummy detail data
    final details = dummyTripDetails;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(details),
              const SizedBox(height: 24),
              _buildTagsAndShare(details),
              const SizedBox(height: 24),
              _buildOverviewSection(details),
              const SizedBox(height: 24),
              _buildTripInformationSection(details),
              const SizedBox(height: 24),
              _buildItinerarySection(details),
              const SizedBox(height: 24),
              _buildGuideSection(context, details),
              const SizedBox(height: 24),
              _buildReviewsSection(details),
              const SizedBox(height: 32),
              _buildSendRequestButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(TripPlanDetailsModel details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            details.imageUrl,
            width: 140,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 140,
              height: 180,
              color: AppColors.borderLight,
              child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
            ),
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
                'By Guide: ${details.guideName}',
                style: AppTextStyles.bodyText,
              ),
              Text(
                '"${details.guideTitle}"',
                style: AppTextStyles.bodyText.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${details.rating}(${details.reviewsCount})',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '(${details.reviewsCount}) Rating  |  152 Review',
                style: AppTextStyles.bodyTextSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsAndShare(TripPlanDetailsModel details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: details.tags.map((tag) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: AppTextStyles.label.copyWith(color: AppColors.surface, fontWeight: FontWeight.normal),
              ),
            );
          }).toList(),
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

  Widget _buildOverviewSection(TripPlanDetailsModel details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          details.overview,
          style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildTripInformationSection(TripPlanDetailsModel details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Information',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Start Date', details.startDate),
        _buildInfoRow('Starting Point', details.startPoint),
        _buildInfoRow('Ending point', details.endPoint),
        _buildInfoRow('Duration', details.duration),
        _buildInfoRow('Group Size', details.groupSize),
        _buildInfoRow('price', details.price),
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

  Widget _buildItinerarySection(TripPlanDetailsModel details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itinerary',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        ...details.itinerary.map((day) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    'Day ${day.day}',
                    style: AppTextStyles.label,
                  ),
                ),
                Expanded(
                  child: Text(
                    '- ${day.description}',
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGuideSection(BuildContext context, TripPlanDetailsModel details) {
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
              // TODO: Navigate to Guide Profile Page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Guide Profile Page (To be implemented)')),
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

  Widget _buildReviewsSection(TripPlanDetailsModel details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 12),
        ...details.reviews.map((review) {
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
                          text: '${review.reviewerName},${review.location} - ',
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
        }).toList(),
      ],
    );
  }

  Widget _buildSendRequestButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          // TODO: Send Request action
        },
        child: Text(
          'Send A Request',
          style: AppTextStyles.button.copyWith(fontSize: 18),
        ),
      ),
    );
  }
}
