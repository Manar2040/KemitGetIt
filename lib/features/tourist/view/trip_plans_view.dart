import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/trip_models.dart';
import '../viewmodel/trips_viewmodel.dart';
import '../../../core/themes/text_styles.dart';
import 'trip_plan_details_view.dart';

class TripPlansPage extends StatefulWidget {
  const TripPlansPage({super.key});

  @override
  State<TripPlansPage> createState() => _TripPlansPageState();
}

class _TripPlansPageState extends State<TripPlansPage> {
  final TextEditingController _searchController = TextEditingController();
  final _vm = TripsViewModel();

  List<TripSummary> get filteredTrips {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _vm.trips;
    return _vm.trips.where((trip) =>
      trip.title.toLowerCase().contains(query) ||
      (trip.guideName?.toLowerCase().contains(query) ?? false)
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
    _vm.loadTrips();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
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
            Expanded(
              child: _vm.isLoading && _vm.trips.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _vm.errorMessage != null && _vm.trips.isEmpty
                      ? Center(child: Text(_vm.errorMessage!))
                      : filteredTrips.isEmpty
                          ? const Center(child: Text('No trips found.'))
                          : RefreshIndicator(
                              onRefresh: () => _vm.loadTrips(refresh: true),
                              child: ListView.separated(
                                itemCount: filteredTrips.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final trip = filteredTrips[index];
                                  return _buildTripCard(context, trip);
                                },
                              ),
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
              onChanged: (v) => setState(() {}),
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

  Widget _buildTripCard(BuildContext context, TripSummary trip) {
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
            builder: (context) => TripPlanDetailsPage(tripId: trip.id),
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
              child: trip.coverImageUrl != null && trip.coverImageUrl!.isNotEmpty
                  ? Image.network(
                      trip.coverImageUrl!,
                      width: 120,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 140,
                        color: AppColors.borderLight,
                        child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 140,
                      color: AppColors.borderLight,
                      child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
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
                      'By ${trip.guideName ?? 'Unknown'}',
                      style: AppTextStyles.bodyTextSmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${trip.durationDays}D/${trip.durationNights}N',
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
                          '${trip.currency} ${trip.price}',
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
                          '${trip.guideRating}',
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
