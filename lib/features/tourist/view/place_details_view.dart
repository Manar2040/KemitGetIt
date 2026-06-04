import 'package:flutter/material.dart';
import 'package:kemit_get_it/routes/app_routes.dart';
import '../../../data/models/place.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/themes/text_styles.dart';
import '../viewmodel/places_viewmodel.dart';
import '../../../shared/widgets/add_review_bottom_sheet.dart';

class PlaceDetailsView extends StatefulWidget {
  final Place place;

  const PlaceDetailsView({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  State<PlaceDetailsView> createState() => _PlaceDetailsViewState();
}

class _PlaceDetailsViewState extends State<PlaceDetailsView> {
  final _wishlistVm = WishlistViewModel();
  final _myPlanVm = MyPlanViewModel();
  bool _isWishlisted = false;
  List<Map<String, dynamic>> _placeReviews = [];

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
    _placeReviews = [
      {'name': 'Sarah', 'comment': 'Absolutely stunning place! A must-visit.', 'rating': 5},
      {'name': 'Omar', 'comment': 'Great historical site with lots to explore.', 'rating': 4},
    ];
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
                              color: Colors.grey.withOpacity(0.2),
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
                      const placeholder = 'https://images.unsplash.com/photo-1539650116574-8efeb43e2b45?q=80&w=600';
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
                      '${widget.place.rating}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '(${widget.place.reviewCount})',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '(12k Rating',
                      style: AppTextStyles.bodyTextSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '|',
                      style: AppTextStyles.bodyTextSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '328 Review)',
                      style: AppTextStyles.bodyTextSmall.copyWith(
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
                const SizedBox(height: 16),

                // Share Button
                Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Share',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
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
                  value: 'Free',
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
                }).toList(),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final result = await AddReviewBottomSheet.show(context);
                      if (result is Map && mounted) {
                        setState(() {
                          _placeReviews.insert(0, {
                            'name': 'You',
                            'comment': result['comment'] as String,
                            'rating': result['rating'] as int,
                          });
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, color: AppColors.primaryDark, size: 18),
                    label: Text(
                      'Write a Review',
                      style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        label: 'Start 3D Virtual Tour',
                        backgroundColor: AppColors.primary,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.pyramids3d);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Starting 3D Virtual Tour...'),
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
                      child: _buildButton(
                        label: 'Add To My Plan',
                        backgroundColor: AppColors.primary,
                        onTap: () async {
                          final success = await _myPlanVm.addPlace(widget.place.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Added to your plan!'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                            Navigator.pushNamed(context, AppRoutes.myPlan);
                          } else if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_myPlanVm.errorMessage ?? 'Failed to add to plan'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
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