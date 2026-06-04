import 'package:flutter/material.dart';
import '../../../data/models/guide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../data/mock_guide_profile_repository.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kemit_get_it/shared/models/user.dart';
import '../../../shared/widgets/add_review_bottom_sheet.dart';

class GuideProfileView extends StatefulWidget {
  final String guideId;

  const GuideProfileView({super.key, required this.guideId});

  @override
  State<GuideProfileView> createState() => _GuideProfileViewState();
}

class _GuideProfileViewState extends State<GuideProfileView> {
  final _repository = MockGuideProfileRepository();
  Guide? _guide;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final guide = await _repository.getGuideProfile(widget.guideId);
    setState(() {
      _guide = guide;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
      );
    }

    if (_guide == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load guide profile')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2EBE5), // Matching the mockup background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildAboutSection(),
              const SizedBox(height: 24),
              _buildRecentTripsSection(),
              const SizedBox(height: 24),
              _buildRecentFeedbackSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 64,
            backgroundImage: NetworkImage(_guide!.imageUrl),
            onBackgroundImageError: (exception, stackTrace) {},
            backgroundColor: AppColors.borderLight,
            child: _guide!.imageUrl.isEmpty 
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            _guide!.name,
            style: AppTextStyles.heading2.copyWith(color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFEAB308), size: 18), // Amber 500
              const SizedBox(width: 4),
              Text(
                '${_guide!.rating} (${_guide!.reviews} reviews)',
                style: const TextStyle(
                  color: Color(0xFF475569), // slate-600
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context, 
                '/guide-chat',
                arguments: widget.guideId, 
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA1824A), // Muted gold/brown from mockup
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Chat With',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(
          _guide!.aboutMe,
          style: const TextStyle(
            color: Color(0xFF334155), // slate-700
            height: 1.5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _guide!.certifications.join(' | '),
          style: const TextStyle(
            color: Color(0xFF475569), // slate-600
            height: 1.5,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Trips',
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _guide!.recentTrips.length,
            itemBuilder: (context, index) {
              final trip = _guide!.recentTrips[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        trip.imageUrl,
                        width: 90,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 90,
                          height: 70,
                          color: AppColors.borderLight,
                          child: const Icon(Icons.image, color: AppColors.textHint),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  trip.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: trip.status == 'Completed' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  trip.status,
                                  style: TextStyle(
                                    color: trip.status == 'Completed' ? const Color(0xFF166534) : const Color(0xFF854D0E),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trip.dateRange,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${trip.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFA1824A),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Feedback',
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _guide!.recentFeedback.length,
            itemBuilder: (context, index) {
              final feedback = _guide!.recentFeedback[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(feedback.reviewerImageUrl),
                          onBackgroundImageError: (exception, stackTrace) {},
                          backgroundColor: AppColors.borderLight,
                          child: feedback.reviewerImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feedback.reviewerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  color: index < feedback.rating.floor() ? const Color(0xFFEAB308) : Colors.grey[300],
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        feedback.comment,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () async {
              final result = await AddReviewBottomSheet.show(context);
              if (result is Map && mounted) {
                setState(() {
                  _guide!.recentFeedback.insert(
                    0,
                    FeedbackItem(
                      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                      reviewerName: 'You',
                      rating: (result['rating'] as int).toDouble(),
                      comment: result['comment'] as String,
                      reviewerImageUrl: '',
                    ),
                  );
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
      ],
    );
  }
}
