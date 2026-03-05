import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../data/trip_plan_model.dart';
import 'trip_plan_details_view.dart';

class TripPlansPage extends StatefulWidget {
  const TripPlansPage({super.key});

  @override
  State<TripPlansPage> createState() => _TripPlansPageState();
}

class _TripPlansPageState extends State<TripPlansPage> {
  final TextEditingController _searchController = TextEditingController();
  List<TripPlanModel> filteredTrips = dummyTripPlans;

  void _filterTrips(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredTrips = dummyTripPlans;
      });
      return;
    }
    setState(() {
      filteredTrips = dummyTripPlans.where((trip) {
        return trip.title.toLowerCase().contains(query.toLowerCase()) ||
            trip.guideName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          'Trip Plans',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Search', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recommendation', style: AppTextStyles.heading3),
                Text(
                  'See More',
                  style: AppTextStyles.bodyText.copyWith(color: AppColors.primaryDark),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: filteredTrips.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final trip = filteredTrips[index];
                  return _buildTripCard(context, trip);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterTrips,
              decoration: InputDecoration(
                hintText: 'search for trips by destination,guide,...',
                hintStyle: AppTextStyles.hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripPlanModel trip) {
    Color statusColor;
    if (trip.status.toLowerCase() == 'closed') {
      statusColor = AppColors.error;
    } else {
      statusColor = AppColors.success;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TripPlanDetailsPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                trip.imageUrl,
                width: 120,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 140,
                  color: AppColors.borderLight,
                  child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: AppTextStyles.label.copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${trip.guideName}',
                      style: AppTextStyles.bodyTextSmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          trip.duration,
                          style: AppTextStyles.bodyTextSmall,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '||',
                            style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.borderGrey),
                          ),
                        ),
                        Text(
                          trip.price,
                          style: AppTextStyles.bodyTextSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${trip.rating} (${trip.reviewsCount} Ratings)',
                          style: AppTextStyles.bodyTextSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trip.status,
                          style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                        ),
                        Text(
                          'Details',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF2C3E50),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
