import 'package:flutter/material.dart';
import 'package:kemit_get_it/routes/app_routes.dart';
import '../../../data/models/place.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';

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
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _isWishlisted = WishlistService.isWishlisted(widget.place.id);
  }

  void _toggleWishlist() {
    setState(() {
      if (_isWishlisted) {
        WishlistService.removePlace(widget.place);
        _isWishlisted = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from Wishlist'), duration: Duration(seconds: 1)),
        );
      } else {
        WishlistService.addPlace(widget.place);
        _isWishlisted = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Wishlist'), duration: Duration(seconds: 1)),
        );
      }
    });
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
                    widget.place.imageUrl,
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
                Wrap(
                  spacing: 10,
                  children: widget.place.categories.map((category) {
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
                ),
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
                  widget.place.fullDescription,
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
                  value: widget.place.openingHours,
                ),
                const SizedBox(height: 12),

                // Entry Fee
                _buildInfoRow(
                  label: 'Entry Fee',
                  value: widget.place.entryFee,
                ),
                const SizedBox(height: 12),

                // Location
                _buildInfoRow(
                  label: 'Location',
                  value: widget.place.location,
                ),
                const SizedBox(height: 12),

                // Best Time to visit
                _buildInfoRow(
                  label: 'Best Time to visit',
                  value: widget.place.bestTimeToVisit,
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
                        onTap: () {
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
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
       onTap: () {
    Navigator.pushNamed(
      context,
      AppRoutes.videoTour,
      arguments: widget.place.name,
    );
    },
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