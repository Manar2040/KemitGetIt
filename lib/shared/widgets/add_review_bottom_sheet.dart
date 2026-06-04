import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/text_styles.dart';
import '../../core/services/api_client.dart';
import '../../data/models/review_models.dart';
import '../../data/services/review_service.dart';

class AddReviewBottomSheet extends StatefulWidget {
  /// Required: the booking this review belongs to.
  final int bookingId;
  /// Required: the guide being reviewed.
  final int guideUserId;
  /// Optional: the trip being reviewed.
  final int? tripId;

  const AddReviewBottomSheet({
    super.key,
    required this.bookingId,
    required this.guideUserId,
    this.tripId,
  });

  /// Shows the bottom sheet and returns true if the review was submitted successfully.
  static Future<bool> show(
    BuildContext context, {
    required int bookingId,
    required int guideUserId,
    int? tripId,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddReviewBottomSheet(
          bookingId: bookingId,
          guideUserId: guideUserId,
          tripId: tripId,
        ),
      ),
    );
    return result == true;
  }

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  int _guideRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_guideRating == 0) {
      setState(() => _errorMessage = 'Please select a rating.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ReviewService.instance.createReview(
        CreateReviewRequest(
          bookingId: widget.bookingId,
          guideUserId: widget.guideUserId,
          tripId: widget.tripId,
          guideRating: _guideRating,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.userMessage;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to submit review. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Write a Review',
                style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'How was your experience with the guide?',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _guideRating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFEAB308),
                  size: 32,
                ),
                onPressed: () => setState(() => _guideRating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: 'Share details of your experience (optional)...',
              hintStyle: AppTextStyles.bodyText.copyWith(color: AppColors.textHint),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC1A46A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
