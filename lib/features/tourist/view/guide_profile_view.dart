import 'package:flutter/material.dart';
import '../../../data/models/guide.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../data/services/guides_service.dart';

import '../../../core/services/api_client.dart';


class GuideProfileView extends StatefulWidget {
  final String guideId;

  const GuideProfileView({super.key, required this.guideId});

  @override
  State<GuideProfileView> createState() => _GuideProfileViewState();
}

class _GuideProfileViewState extends State<GuideProfileView> {
  Guide? _guide;
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final guideIdInt = int.tryParse(widget.guideId) ?? 0;
      final guide = await GuidesService.instance.getGuideProfile(guideIdInt);
      
      setState(() {
        _guide = guide;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.userMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load guide profile.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryDark)),
      );
    }

    if (_errorMessage != null || _guide == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _errorMessage ?? 'Failed to load guide profile',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
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
              _buildWorkingRegionsSection(),
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
        // Chat button removed as per user request
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

  Widget _buildWorkingRegionsSection() {
    if (_guide!.location.isEmpty) {
      return const SizedBox.shrink();
    }

    final regions = _guide!.location.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Working Regions',
          style: AppTextStyles.heading3.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: regions.map((region) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3), // Yellow-ish
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                region,
                style: const TextStyle(
                  color: Color(0xFF854D0E), // Dark yellow
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
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
        _guide!.recentFeedback.isEmpty
            ? const SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    'No feedback yet.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ),
              )
            : SizedBox(
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

      ],
    );
  }
}
