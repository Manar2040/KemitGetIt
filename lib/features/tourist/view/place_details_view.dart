import 'package:flutter/material.dart';
import 'package:kemit_get_it/routes/app_routes.dart';
import '../../../data/models/place.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/themes/text_styles.dart';
import '../viewmodel/places_viewmodel.dart';
import '../../../data/services/hold_request_service.dart';
import '../../../data/models/hold_request_models.dart';
import '../../../data/services/places_service.dart';

class PlaceDetailsView extends StatefulWidget {
  final Place place;

  const PlaceDetailsView({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailsView> createState() => _PlaceDetailsViewState();
}

class _PlaceDetailsViewState extends State<PlaceDetailsView> {
  final _wishlistVm = WishlistViewModel();
  final _myPlanVm = MyPlanViewModel();
  bool _isWishlisted = false;
  List<Map<String, dynamic>> _placeReviews = [];

  // Bug Fix #5: Plan State Awareness
  bool _isInPlan = false;
  HoldRequestDto? _latestRequest;
  bool _checkingPlanState = true;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
    _checkPlanAndRequestState();
    _placeReviews = [
      {'name': 'Sarah', 'comment': 'Absolutely stunning place! A must-visit.', 'rating': 5},
      {'name': 'Omar', 'comment': 'Great historical site with lots to explore.', 'rating': 4},
    ];
  }

  Future<void> _checkPlanAndRequestState() async {
    try {
      // Check if place is already in plan
      final planItems = await MyPlanService.instance.getMyPlan();
      final isInPlan = planItems.any((item) => item.placeId == widget.place.id);

      // Check if there's an existing hold request related to this place
      HoldRequestDto? latestRequest;
      if (isInPlan) {
        final requests = await HoldRequestsService.instance.getMyRequests();
        // Find requests that include this place in selectedPlaces
        final relatedRequests = requests.where((r) =>
          r.selectedPlaces.any((p) => p.placeId == widget.place.id)
        ).toList();

        if (relatedRequests.isNotEmpty) {
          relatedRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          latestRequest = relatedRequests.first;
        }
      }

      if (mounted) {
        setState(() {
          _isInPlan = isInPlan;
          _latestRequest = latestRequest;
          _checkingPlanState = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checkingPlanState = false);
    }
  }

  Future<void> _checkWishlistStatus() async {
    await _wishlistVm.loadWishlist();
    if (mounted) {
      setState(() {
        _isWishlisted = _wishlistVm.wishlist.any((p) => p.id == widget.place.id);
      });
    }
  }

  Future<void> _toggleWishlist() async {
    if (_isWishlisted) {
      final success = await _wishlistVm.removeFromWishlist(widget.place.id);
      if (success && mounted) {
        setState(() => _isWishlisted = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from Wishlist'), duration: Duration(seconds: 1)),
        );
      }
    } else {
      final success = await _wishlistVm.addToWishlist(widget.place.id);
      if (success && mounted) {
        setState(() => _isWishlisted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Wishlist'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  @override
  void dispose() {
    _wishlistVm.dispose();
    _myPlanVm.dispose();
    super.dispose();
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

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Back Button and Details Text
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Details',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleWishlist,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isWishlisted ? Icons.bookmark : Icons.bookmark_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    () {
                      final url = widget.place.imageUrl;
                      const placeholder = 'https://placehold.co/600x600/png';
                      if (url.isEmpty) return placeholder;
                      if (url.startsWith('http')) return url;
                      return '${ApiConstants.baseUrl}$url';
                    }(),
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        color: AppColors.borderLight,
                        child: const Icon(Icons.image,
                            size: 60, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Title and Subtitle
                Text(
                  widget.place.name,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.place.description,
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Rating and Review
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.place.rating.toStringAsFixed(1),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.place.reviewCount} Reviews)',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories
                if (widget.place.category != null && widget.place.category!.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    children: [widget.place.category!].map((category) {
                      return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 24),

                // Overview Section
                Text(
                  'Overview',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.place.description,
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Visiting Info Section
                Text(
                  'Visiting Info',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Opening Hours
                _buildInfoRow(
                  label: 'Opening Hours',
                  value: '9:00 AM - 5:00 PM',
                ),
                const SizedBox(height: 12),

                // Entry Fee
                _buildInfoRow(
                  label: 'Entry Fee',
                  value: () {
                    final price = _getPlaceTicketPrice(widget.place.id);
                    return price == 0 ? 'Free' : '$price EGP';
                  }(),
                ),
                const SizedBox(height: 12),

                // Location
                _buildInfoRow(
                  label: 'Location',
                  value: widget.place.location ?? 'Egypt',
                ),
                const SizedBox(height: 12),

                // Best Time to visit
                _buildInfoRow(
                  label: 'Best Time to visit',
                  value: 'Morning',
                ),
                const SizedBox(height: 28),

                // Reviews Section
                Text(
                  'Reviews',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._placeReviews.map((review) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textHint),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    review['name'] as String,
                                    style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
                                  ),
                                  const SizedBox(width: 8),
                                  ...List.generate(
                                    review['rating'] as int,
                                    (_) => const Icon(Icons.star, color: Color(0xFFEAB308), size: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '"${review['comment']}"',
                                style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),

                const SizedBox(height: 28),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        label: 'Start 3D Virtual Tour',
                        backgroundColor: AppColors.primary,
                        onTap: () {
                          final placeName = widget.place.name;
                          Navigator.pushNamed(
                            context,
                            AppRoutes.unityEmbed,
                            arguments: {'placeName': placeName},
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting 3D Virtual Tour for $placeName...'),
                              backgroundColor: AppColors.primary,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPlanActionButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
              ],
            ),
          ),
        ),
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

  /// Bug Fix #5: Dynamic button based on plan state
  Widget _buildPlanActionButton() {
    // While checking, show a loading placeholder
    if (_checkingPlanState) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(height: 18, width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
      );
    }

    final req = _latestRequest;

    // State 1: Request is Accepted → Pay Now
    if (req != null && req.status == 'Accepted') {
      return _buildButton(
        label: '💳 Pay Now',
        backgroundColor: AppColors.primaryDark,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.payment, arguments: {
            'holdRequestId': req.id,
            'guideName': req.guideName ?? '',
            'totalPrice': req.totalPrice,
            'currency': req.currency ?? 'EGP',
          });
        },
      );
    }

    // State 2: Request is Pending → show disabled state
    if (req != null && req.status == 'PendingRequest') {
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.myRequests),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.orange.shade400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '⏳ Request Pending',
              style: AppTextStyles.bodyText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    // State 3: Paid, Active, Completed → Booking confirmed
    if (req != null && ['Paid', 'Active', 'Completed'].contains(req.status)) {
      return _buildButton(
        label: '✅ Booking Confirmed',
        backgroundColor: AppColors.success,
        onTap: () => Navigator.pushNamed(context, AppRoutes.myRequests),
      );
    }

    // State 4: Declined → Try again
    if (req != null && ['Declined', 'Cancelled'].contains(req.status)) {
      return _buildButton(
        label: '↩ Request Declined — Try Again',
        backgroundColor: AppColors.error,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.tripRequestForm, arguments: {
            'isFromTripPlan': false,
            'place': widget.place,
          });
        },
      );
    }

    // State 5: In plan but no request → Find a Guide
    if (_isInPlan) {
      return _buildButton(
        label: '🔍 Find a Guide',
        backgroundColor: AppColors.primary,
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.tripRequestForm, arguments: {
            'isFromTripPlan': false,
            'place': widget.place,
          });
        },
      );
    }

    // State 6: Default → Add To My Plan
    return _buildButton(
      label: 'Add To My Plan',
      backgroundColor: AppColors.primary,
      onTap: () async {
        final success = await _myPlanVm.addPlace(widget.place.id);
        if (success && mounted) {
          setState(() => _isInPlan = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Added to your plan!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          Navigator.pushNamed(context, AppRoutes.tripRequestForm, arguments: {
            'isFromTripPlan': false,
            'place': widget.place,
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_myPlanVm.errorMessage ?? 'Failed to add to plan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}