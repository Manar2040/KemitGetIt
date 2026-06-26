import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/trip_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/core/constants/api_constants.dart';
import 'package:kemit_get_it/features/guide/screens/trip_details_view.dart';

class TripCard extends StatelessWidget {
  final ActiveTripModel trip;
  const TripCard({super.key, required this.trip});

  String _resolveImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('/')) {
      return '${ApiConstants.baseUrl}$trimmed';
    }
    return trimmed;
  }

  Color _statusColor() {
    switch (trip.status.toLowerCase()) {
      case 'active':
        return const Color(0xFF4CAF50);
      case 'completed':
        return Colors.blue;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  String _statusLabel() {
    final s = trip.status.toLowerCase();
    if (s == 'active') return 'Active';
    if (s == 'completed') return 'Completed';
    if (s == 'canceled' || s == 'cancelled') return 'Canceled';
    return trip.status;
  }

  String _formatDateRange() {
    if (trip.startDate == null || trip.endDate == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final s = trip.startDate!;
    final e = trip.endDate!;
    return '${months[s.month - 1]} ${s.day} - ${months[e.month - 1]} ${e.day}';
  }

  // ── View Details ───────────────────────────────────────────
  Future<void> _openTripDetails(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final tripDetails = await TripService.getTripById(trip.id);

      if (!context.mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TripDetailsView(trip: tripDetails)),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل تفاصيل الرحلة: $e')),
      );
    }
  }

  // ── Edit — بيفتح الـ sheet مباشرة ─────────────────────────
  Future<void> _openEditSheet(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final tripDetails = await TripService.getTripById(trip.id);

      if (!context.mounted) return;
      Navigator.pop(context); // قفل اللودينج

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EditTripSheet(trip: tripDetails),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trip: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(trip.coverImageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                _buildImage(imageUrl),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _statusLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        trip.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trip.price > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${trip.price.toStringAsFixed(0)} ${trip.currency}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB9975B),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.currentParticipants}/${trip.maxParticipants} Tourists',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateRange(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trip.location,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (trip.status.toLowerCase() == 'active') ...[
                      Expanded(
                        child: OutlinedButton(
                          // ✅ بيفتح الـ Edit sheet مباشرة
                          onPressed: () => _openEditSheet(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _openTripDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB9975B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
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

  Widget _buildImage(String url) {
    if (url.isEmpty) return _placeholder();
    return Image.network(
      url,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: 160,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: const Color(0xFFB9975B),
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        height: 160,
        color: Colors.grey.shade200,
        child:
            const Icon(Icons.image_outlined, color: Colors.grey, size: 48),
      );
}