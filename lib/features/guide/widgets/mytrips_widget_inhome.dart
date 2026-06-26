import 'package:flutter/material.dart';
import 'package:kemit_get_it/core/constants/api_constants.dart';
import 'package:kemit_get_it/features/guide/core/trip_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

class ActiveTripsList extends StatefulWidget {
  const ActiveTripsList({super.key});

  @override
  State<ActiveTripsList> createState() => _ActiveTripsListState();
}

class _ActiveTripsListState extends State<ActiveTripsList> {
  List<ActiveTripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final trips = await TripService.getActiveTrips();
      if (mounted) {
        setState(() {
          _trips = trips.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('ActiveTripsList error: $e'); // ✅ اطبع الـ error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFB9975B)),
        ),
      );
    }

    if (_trips.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text("No active trips", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      height: 220, // ✅ زودنا الـ height شوية
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _trips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return _ActiveTripCard(trip: trip);
        },
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final ActiveTripModel trip;
  const _ActiveTripCard({required this.trip});

  String _timeLeft() {
    if (trip.endDate == null) return '';
    final diff = trip.endDate!.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays == 0) return 'Today';
    return '${diff.inDays}d left';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ اطبع الـ URL عشان تشوف المشكلة
    debugPrint('Trip cover URL: "${trip.coverImageUrl}"');

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover Image ──────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildImage(),
          ),

          // ── Info ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      "${trip.currentParticipants}/${trip.maxParticipants}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      _timeLeft(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    var url = trip.coverImageUrl.trim();

    if (url.isEmpty) return _imagePlaceholder();

    // ✅ لو الـ URL relative، أضف الـ base URL
    if (url.startsWith('/')) {
      url = '${ApiConstants.baseUrl}$url'; // ✅ الصح
    }

    return Image.network(
      url,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              color: const Color(0xFFB9975B),
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image load error for "$url": $error');
        return _imagePlaceholder();
      },
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
    );
  }
}
