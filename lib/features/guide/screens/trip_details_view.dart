import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/trip_service.dart';
import 'package:kemit_get_it/features/guide/core/review_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/features/guide/models/review_model.dart';
import 'package:kemit_get_it/features/guide/screens/trip_reviews_screen.dart';
import '../widgets/itinerary_card.dart';
import '../widgets/review_card.dart';

// ─────────────────────────────────────────────
// Edit Trip Bottom Sheet
// ─────────────────────────────────────────────
class EditTripSheet extends StatefulWidget {
  final TripDetailsModel trip;
  const EditTripSheet({required this.trip});

  @override
  State<EditTripSheet> createState() => EditTripSheetState();
}

class EditTripSheetState extends State<EditTripSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _startingPointCtrl;
  late final TextEditingController _endingPointCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _maxParticipantsCtrl;
  late DateTime _startDate;
  late DateTime _endDate;

  late List<Map<String, TextEditingController>> _itineraryControllers;

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    _titleCtrl = TextEditingController(text: t.title);
    _descCtrl = TextEditingController(text: t.description);
    _locationCtrl = TextEditingController(text: t.location);
    _startingPointCtrl = TextEditingController(text: t.startingPoint);
    _endingPointCtrl = TextEditingController(text: t.endingPoint);
    _priceCtrl = TextEditingController(text: t.price.toStringAsFixed(0));
    _maxParticipantsCtrl = TextEditingController(
      text: t.maxParticipants.toString(),
    );
    _startDate = t.startDate;
    _endDate = t.endDate;

    _itineraryControllers =
        t.itineraryDays.map((day) {
          return {
            'title': TextEditingController(text: day.title),
            'description': TextEditingController(text: day.description),
          };
        }).toList();

    if (_itineraryControllers.isEmpty) {
      _addItineraryDay();
    }
  }

  void _addItineraryDay() {
    setState(() {
      _itineraryControllers.add({
        'title': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _removeItineraryDay(int index) {
    if (_itineraryControllers.length <= 1) return;
    setState(() {
      _itineraryControllers[index]['title']!.dispose();
      _itineraryControllers[index]['description']!.dispose();
      _itineraryControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _startingPointCtrl.dispose();
    _endingPointCtrl.dispose();
    _priceCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    for (final day in _itineraryControllers) {
      day['title']!.dispose();
      day['description']!.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final first = isStart ? DateTime.now() : _startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFFB9975B)),
            ),
            child: child!,
          ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
      }
    });
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final t = widget.trip;
    final durationDays = _endDate.difference(_startDate).inDays.clamp(1, 9999);

    final itineraryDays = List.generate(
      _itineraryControllers.length,
      (i) => ItineraryDayRequest(
        dayNumber: i + 1,
        title: _itineraryControllers[i]['title']!.text.trim(),
        description: _itineraryControllers[i]['description']!.text.trim(),
      ),
    );

    final request = CreateTripRequest(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      tripType: t.tripType,
      languages: t.languages,
      location: _locationCtrl.text.trim(),
      locationLat: t.locationLat,
      locationLng: t.locationLng,
      startingPoint: _startingPointCtrl.text.trim(),
      endingPoint: _endingPointCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      price: double.tryParse(_priceCtrl.text.trim()) ?? t.price,
      currency: t.currency,
      durationDays: durationDays,
      durationNights: (durationDays - 1).clamp(0, 9999),
      maxParticipants:
          int.tryParse(_maxParticipantsCtrl.text.trim()) ?? t.maxParticipants,
      itineraryDays: itineraryDays,
    );

    setState(() => _loading = true);

    TripDetailsModel? updated;
    try {
      updated = await TripService.updateTrip(t.id, request);
    } catch (e) {
      updated = null;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (updated != null) {
      Navigator.pop(context, updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update trip. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(color: Color(0xFFB9975B)),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFB9975B)),
    ),
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder:
          (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Trip',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // ── Basic fields ──────────────────────
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: _dec('Title'),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descCtrl,
                          decoration: _dec('Description'),
                          maxLines: 3,
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _locationCtrl,
                          decoration: _dec('Location'),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _startingPointCtrl,
                                decoration: _dec('Starting Point'),
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _endingPointCtrl,
                                decoration: _dec('Ending Point'),
                                validator:
                                    (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Required'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceCtrl,
                                decoration: _dec('Price', hint: '0'),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(v.trim()) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _maxParticipantsCtrl,
                                decoration: _dec('Max Participants'),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(v.trim()) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _DatePickerField(
                                label: 'Start Date',
                                value: _formatDate(_startDate),
                                onTap: () => _pickDate(isStart: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DatePickerField(
                                label: 'End Date',
                                value: _formatDate(_endDate),
                                onTap: () => _pickDate(isStart: false),
                              ),
                            ),
                          ],
                        ),

                        // ── Itinerary Days ────────────────────
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Itinerary Days',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addItineraryDay,
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Color(0xFFB9975B),
                              ),
                              label: const Text(
                                'Add Day',
                                style: TextStyle(color: Color(0xFFB9975B)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ...List.generate(_itineraryControllers.length, (i) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Day ${i + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFB9975B),
                                      ),
                                    ),
                                    if (_itineraryControllers.length > 1)
                                      GestureDetector(
                                        onTap: () => _removeItineraryDay(i),
                                        child: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _itineraryControllers[i]['title'],
                                  decoration: _dec('Day Title'),
                                  validator:
                                      (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Required'
                                              : null,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller:
                                      _itineraryControllers[i]['description'],
                                  decoration: _dec('Day Description'),
                                  maxLines: 2,
                                  validator:
                                      (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Required'
                                              : null,
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        // ── Save Button ───────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB9975B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                _loading
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// ─────────────────────────────────────────────
// Date Picker Field Widget (helper)
// ─────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFFB9975B)),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cancel Trip Confirmation Dialog
// ─────────────────────────────────────────────
Future<bool> _showCancelConfirmDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Cancel Trip',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you sure you want to cancel this trip?',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2B98B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD2B98B)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFB9975B),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A cancellation penalty will be deducted from your wallet, and all confirmed bookings will be refunded.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A6030),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Keep Trip',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Yes, Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      ) ??
      false;
}

// ─────────────────────────────────────────────
// TripDetailsView — Main Screen
// ─────────────────────────────────────────────
class TripDetailsView extends StatefulWidget {
  final TripDetailsModel trip;
  const TripDetailsView({super.key, required this.trip});

  @override
  State<TripDetailsView> createState() => _TripDetailsViewState();
}

class _TripDetailsViewState extends State<TripDetailsView> {
  late TripDetailsModel _trip;
  late Future<ReviewsPageModel> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _reviewsFuture = ReviewService.getTripReviews(_trip.id);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _openAllReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TripReviewsScreen(tripId: _trip.id, tripTitle: _trip.title),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // ── Edit ──────────────────────────────────
  Future<void> _openEditSheet() async {
    final updated = await showModalBottomSheet<TripDetailsModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTripSheet(trip: _trip), // ✅ شيلي الـ underscore
    );
    if (updated != null && mounted) {
      setState(() => _trip = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip updated successfully'),
          backgroundColor: Color(0xFFB9975B),
        ),
      );
    }
  }

  // ── Cancel (فيه participants) ──────────────
  Future<void> _handleCancelTrip() async {
    final confirmed = await _showCancelConfirmDialog(context);
    if (!confirmed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await TripService.cancelTrip(_trip.id);

    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip has been cancelled.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context); // go back to trips list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel trip. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Delete (مفيش participants) ─────────────
  Future<void> _handleDeleteTrip() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Delete Trip',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Are you sure you want to permanently delete this trip?',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'No participants have joined yet, so no penalty or refunds will apply.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(
                      'Keep Trip',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await TripService.deleteTrip(_trip.id);

    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip deleted successfully.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context); // go back to trips list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete trip. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Trip Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Trip Image with overlay ────────────
            Stack(
              children: [
                Image.network(
                  TripService.resolveImageUrl(trip.coverImageUrl),
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 230,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                ),
                Container(
                  height: 230,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(trip.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trip.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${_formatDate(trip.startDate.toLocal())} - ${_formatDate(trip.endDate.toLocal())}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "${trip.startingPoint} → ${trip.endingPoint}",
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.people,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${trip.currentParticipants}/${trip.maxParticipants} Tourists",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            "${trip.price} \$ per person",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Trip Overview ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Trip Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                trip.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // ── Languages chips ────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trip.languages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Chip(
                        label: Text(
                          trip.languages[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFFB9975B),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Itinerary ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Itinerary Builder",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children:
                  trip.itineraryDays
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ItineraryCard(itinerary: item),
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 24),

            // ── Reviews — Completed trips only ────
            if (trip.status.toLowerCase() == 'completed') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Trip Reviews",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _openAllReviews,
                      child: const Text(
                        "See All",
                        style: TextStyle(color: Color(0xFFB9975B)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<ReviewsPageModel>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Failed to load reviews.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }
                  final reviews = snapshot.data?.items ?? [];
                  if (reviews.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "No reviews yet for this trip.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return Column(
                    children:
                        reviews
                            .take(2)
                            .map(
                              (review) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: ReviewCard(review: review),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ],

            const SizedBox(height: 32),

            // ── Action Buttons ─────────────────────
            // مش بيظهروا لو completed أو cancelled
            if (![
              'completed',
              'cancelled',
            ].contains(trip.status.toLowerCase())) ...[
              // Edit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openEditSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB9975B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel أو Delete حسب عدد المشتركين
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child:
                      trip.currentParticipants > 0
                          // ── فيه توريستس → Cancel مع penalty
                          ? OutlinedButton(
                            onPressed: _handleCancelTrip,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Cancel Trip",
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          )
                          // ── مفيش توريستس → Delete بدون penalty
                          : OutlinedButton(
                            onPressed: _handleDeleteTrip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.red.shade900,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Delete Trip",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
