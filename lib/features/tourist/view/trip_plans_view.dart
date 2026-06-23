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

  String? _selectedTripType;
  String? _selectedLanguage;

  final List<String> _tripTypes = ['Historical', 'Cultural', 'Adventure', 'Nature', 'Relaxation', 'Religious', 'Photography'];
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Italian', 'Arabic', 'Russian'];

  List<TripSummary> get filteredTrips {
    var result = _vm.trips;
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((trip) =>
        trip.title.toLowerCase().contains(query) ||
        (trip.guideName?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    if (_selectedTripType != null) {
      result = result.where((trip) => trip.tripType.toLowerCase() == _selectedTripType?.toLowerCase()).toList();
    }
    if (_selectedLanguage != null) {
      result = result.where((trip) => trip.languages.any((lang) => lang.toLowerCase() == _selectedLanguage?.toLowerCase())).toList();
    }
    return result;
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
    return Row(
      children: [
        Expanded(
          child: Container(
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
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _showFilterBottomSheet,
          child: Container(
            height: 48,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.filter_list, color: Color(0xFF6366F1)),
          ),
        ),
      ],
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Trips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  const Text('Trip Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTripType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any Type')),
                      ..._tripTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))),
                    ],
                    onChanged: (val) {
                      setStateBottomSheet(() {
                        _selectedTripType = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  const Text('Language', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Any Language')),
                      ..._languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))),
                    ],
                    onChanged: (val) {
                      setStateBottomSheet(() {
                        _selectedLanguage = val;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Apply filter
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
