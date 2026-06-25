import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/trip_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

// ════════════════════════════════════════════════════════
// 1. SECTION HEADER
// ════════════════════════════════════════════════════════
class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const ProfileSectionHeader({super.key, required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              "View All",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFB9975B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// 2. PROFILE HEADER
// ════════════════════════════════════════════════════════
class ProfileHeaderWidget extends StatelessWidget {
  final GuideProfileModel profile;
  final VoidCallback? onEditTap;

  const ProfileHeaderWidget({super.key, required this.profile, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    debugPrint("PROFILE IMAGE = ${profile.profileImageUrl}");

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  profile.profileImageUrl.isNotEmpty
                      ? NetworkImage(profile.profileImageUrl)
                      : null,
              child:
                  profile.profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 48, color: Colors.grey)
                      : null,
            ),
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB9975B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              profile.displayName.isNotEmpty
                  ? profile.displayName
                  : '${profile.firstName} ${profile.lastName}'.trim().isNotEmpty
                  ? '${profile.firstName} ${profile.lastName}'.trim()
                  : profile.username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            if (profile.verificationStatus.toLowerCase() == 'approved')
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF1DA1F2),
                size: 22,
              )
            else
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFFCCCCCC),
                size: 22,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
            const SizedBox(width: 4),
            Text(
              profile.averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B5563),
              ),
            ),
            Text(
              " (${profile.totalReviews} reviews)",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// 3. ABOUT ME
// ════════════════════════════════════════════════════════
class AboutMeWidget extends StatelessWidget {
  final String aboutMe;

  const AboutMeWidget({super.key, required this.aboutMe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(title: "About Me"),
        const SizedBox(height: 8),
        Text(
          aboutMe,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// 4. SPECIALIZATION & WORKING REGIONS
// ════════════════════════════════════════════════════════
class GuideInfoChipsWidget extends StatelessWidget {
  final String specialization;
  final String workingRegions;

  const GuideInfoChipsWidget({
    super.key,
    required this.specialization,
    required this.workingRegions,
  });

  List<String> _parse(String value) {
    if (value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final specs = _parse(specialization);
    final regions = _parse(workingRegions);

    if (specs.isEmpty && regions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Specialization ──
        if (specs.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                size: 18,
                color: Color(0xFFB9975B),
              ),
              const SizedBox(width: 6),
              const Text(
                'Specialization',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                specs
                    .map(
                      (s) => _Chip(
                        label: s,
                        color: const Color(0xFFFFF3E0),
                        textColor: const Color(0xFFB9975B),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // ── Working Regions ──
        if (regions.isNotEmpty) ...[
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 6),
              const Text(
                'Working Regions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                regions
                    .map(
                      (r) => _Chip(
                        label: r,
                        color: const Color(0xFFE8F5E9),
                        textColor: const Color(0xFF2E7D32),
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Chip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// 5. COMPLETED TRIPS LIST
// ════════════════════════════════════════════════════════
class CompletedTripsListWidget extends StatelessWidget {
  final List<ActiveTripModel> trips;

  const CompletedTripsListWidget({super.key, required this.trips});

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';
    String fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
    return '${fmt(start)} – ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionHeader(title: "Recent Completed Trips"),
          SizedBox(height: 12),
          Text(
            "No completed trips yet",
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 13),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(title: "Recent Completed Trips", onViewAll: () {}),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trips.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Container(
                width: 280,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          trip.coverImageUrl.isNotEmpty
                              ? Image.network(
                                TripService.resolveImageUrl(trip.coverImageUrl),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _imgPlaceholder(),
                              )
                              : _imgPlaceholder(),
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
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  trip.status,
                                  style: const TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateRange(trip.startDate, trip.endDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${trip.price.toStringAsFixed(0)} ${trip.currency}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB9975B),
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

  Widget _imgPlaceholder() => Container(
    width: 80,
    height: 80,
    color: Colors.grey.shade200,
    child: const Icon(Icons.image_outlined, color: Colors.grey),
  );
}

// ════════════════════════════════════════════════════════
// 6. FEEDBACK LIST
// ════════════════════════════════════════════════════════
class FeedbackListWidget extends StatelessWidget {
  final List<GuideReviewModel> feedbacks;
  final VoidCallback? onViewAll;

  const FeedbackListWidget({
    super.key,
    required this.feedbacks,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(title: "Recent Feedback", onViewAll: onViewAll),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: feedbacks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              final name = feedback.touristName ?? 'Tourist';
              return Container(
                width: 250,
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
                          radius: 16,
                          backgroundColor: const Color(0xFFB9975B),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 14,
                                  color:
                                      i < feedback.guideRating
                                          ? const Color(0xFFFBBF24)
                                          : Colors.grey.shade300,
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
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                          height: 1.5,
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
