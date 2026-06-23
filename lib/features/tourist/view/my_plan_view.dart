import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../data/models/place.dart';
import '../viewmodel/places_viewmodel.dart';
import '../../../data/services/places_service.dart';
import '../../../data/services/hold_request_service.dart';
import '../../../data/models/hold_request_models.dart';
import '../../../routes/app_routes.dart';

/// My Plan screen — shows places the tourist has saved to their plan.
///
/// Backed by [MyPlanViewModel] → [MyPlanService] → GET/DELETE /api/myplan
class MyPlanView extends StatefulWidget {
  const MyPlanView({super.key});

  @override
  State<MyPlanView> createState() => _MyPlanViewState();
}

class _MyPlanViewState extends State<MyPlanView> {
  final _vm = MyPlanViewModel();
  List<HoldRequestDto> _myRequests = [];

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
    _vm.loadPlan();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await HoldRequestsService.instance.getMyRequests();
      if (mounted) setState(() => _myRequests = requests);
    } catch (_) {
      // Silent fail — navigation will fall back to TripRequestForm
    }
  }

  /// Find the latest hold request that includes [placeId] in its selectedPlaces.
  HoldRequestDto? _getLatestRequestForPlace(int placeId) {
    final related = _myRequests
        .where((r) => r.selectedPlaces.any((p) => p.placeId == placeId))
        .toList();
    if (related.isEmpty) return null;
    related.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return related.first;
  }

  void _handlePlaceTap(BuildContext context, MyPlanItem item) {
    final req = _getLatestRequestForPlace(item.placeId);
    final place = Place(
      id: item.placeId,
      name: item.placeName,
      imageUrl: item.imageUrl ?? '',
      location: item.location,
    );

    if (req == null) {
      // No request yet → go fill trip form
      Navigator.pushNamed(context, AppRoutes.tripRequestForm,
          arguments: {'isFromTripPlan': true, 'place': place});
      return;
    }

    switch (req.status) {
      case 'PendingRequest':
        // Already sent a request → show matched guides to track
        Navigator.pushNamed(context, AppRoutes.matchedGuides, arguments: {
          'selectedPlaceIds': req.selectedPlaces.map((p) => p.placeId).toList(),
          'startDate': req.startDate.toIso8601String(),
          'endDate': req.endDate.toIso8601String(),
          'numberOfTravelers': req.numberOfTravelers,
          'travelerType': req.travelerType,
          'language': req.preferredLanguage,
          'transportPreference': req.transportPreference,
          'accommodationNeeded': req.accommodationNeeded,
          'mealsIncluded': req.mealsIncluded,
        });
        break;

      case 'Accepted':
        // Guide accepted → pay now
        Navigator.pushNamed(context, AppRoutes.payment, arguments: {
          'holdRequestId': req.id,
          'guideName': req.guideName ?? '',
          'totalPrice': req.totalPrice,
          'currency': req.currency ?? 'EGP',
        });
        break;

      case 'Paid':
      case 'Active':
      case 'Completed':
        // Booking confirmed → show requests screen
        Navigator.pushNamed(context, AppRoutes.myRequests);
        break;

      case 'Declined':
      case 'Cancelled':
        // Rejected → let them try again with a new request
        Navigator.pushNamed(context, AppRoutes.tripRequestForm,
            arguments: {'isFromTripPlan': false, 'place': place});
        break;

      default:
        // Unknown status → go to my requests for reference
        Navigator.pushNamed(context, AppRoutes.myRequests);
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
          'My Plan',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_vm.isLoading && _vm.planItems.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Error state
    if (_vm.errorMessage != null && _vm.planItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(_vm.errorMessage!, textAlign: TextAlign.center,
                style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _vm.loadPlan,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_vm.planItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('Your plan is empty',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Add places from the Places section.',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Review the places you selected.',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Text('Places in Plan', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _vm.loadPlan,
              color: AppColors.primary,
              child: ListView.separated(
                itemCount: _vm.planItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _vm.planItems[index];
                  return _buildPlanCard(item);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  int _getPlaceTicketPrice(int placeId) {
    switch (placeId) {
      case 1: return 360; // Great Pyramids of Giza
      case 2: return 300; // Karnak Temple Complex
      case 3: return 400; // Valley of the Kings
      case 4: return 300; // Abu Simbel Temples
      case 5: return 260; // Luxor Temple
      case 6: return 200; // Egyptian Museum
      case 7: return 450; // Grand Egyptian Museum
      case 8: return 0;   // Khan El Khalili Bazaar
      case 9: return 200; // Philae Temple
      case 10: return 200; // Cairo Citadel
      case 11: return 150; // Siwa Oasis
      case 12: return 250; // White Desert
      case 13: return 150; // Ras Mohammed
      case 14: return 0;   // Mount Sinai
      case 15: return 100; // Saint Catherine
      case 16: return 100; // Blue Hole Dahab
      case 17: return 150; // Baron Empain Palace
      case 18: return 0;   // Coptic Cairo
      case 19: return 0;   // Islamic Cairo
      case 20: return 100; // Aswan High Dam
      case 21: return 150; // Nubian Village
      case 22: return 100; // Elephantine Island
      case 23: return 200; // Kom Ombo Temple
      case 24: return 200; // Edfu Temple
      case 25: return 100; // Bibliotheca Alexandrina
      default: return 150;
    }
  }

  Widget _buildPlanCard(MyPlanItem item) {
    final priceVal = _getPlaceTicketPrice(item.placeId);

    return GestureDetector(
      onTap: () => _handlePlaceTap(context, item),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      width: 100,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.placeName,
                          style: AppTextStyles.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Remove button
                      GestureDetector(
                        onTap: _vm.isModifying
                            ? null
                            : () async {
                                final ok = await _vm.removePlace(item.placeId);
                                if (!ok && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_vm.errorMessage ?? 'Could not remove.'),
                                    ),
                                  );
                                }
                              },
                        child: const Icon(Icons.close, size: 18, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  if (item.location != null)
                    Text(
                      item.location!,
                      style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    priceVal == 0 ? 'Price: Free' : 'Price: Around $priceVal EGP',
                    style: AppTextStyles.bodyTextSmall.copyWith(
                      color: const Color(0xFFB39256),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 100,
        height: 70,
        color: AppColors.borderLight,
        child: const Icon(Icons.image, color: AppColors.textHint),
      );
}
