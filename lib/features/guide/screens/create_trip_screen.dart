import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kemit_get_it/features/guide/core/create_trip_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/features/guide/models/chat_model.dart';
import 'package:kemit_get_it/features/guide/widgets/create_trip_widget.dart';

class CreateTripScreen extends StatefulWidget {
  final VoidCallback? onTripCreated; // ✅
  const CreateTripScreen({super.key, this.onTripCreated});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // ── Controllers ──────────────────────────────────────────
  final _tripNameController = TextEditingController();
  final _startingPointController = TextEditingController();
  final _endingPointController = TextEditingController();
  final _descriptionController = TextEditingController();

  // ── Model ─────────────────────────────────────────────────
  late CreateTripModel _trip;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _trip = CreateTripModel();
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _startingPointController.dispose();
    _endingPointController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Image Picker ──────────────────────────────────────────
  bool _isPicking = false;

  Future<void> _pickCoverImage() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _trip.coverImage = File(image.path));
      }
    } catch (e) {
      _showSnack("Failed to pick image", isError: true);
    } finally {
      _isPicking = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFFB9975B),
      ),
    );
  }

  void _addDay() {
    setState(() {
      _trip.itinerary.add(
        DayItineraryModel(dayNumber: _trip.itinerary.length + 1),
      );
    });
  }

  void _removeDay(int index) {
    if (_trip.itinerary.length == 1) {
      _showSnack("You must have at least one day");
      return;
    }
    setState(() {
      _trip.itinerary.removeAt(index);
      for (int i = 0; i < _trip.itinerary.length; i++) {
        _trip.itinerary[i].dayNumber = i + 1;
      }
    });
  }

  // ── Publish ───────────────────────────────────────────────
  Future<void> _onPublish() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack("Please fill all required fields", isError: true);
      return;
    }
    if (_trip.selectedTripTypes.isEmpty) {
      _showSnack("Please select at least one trip type", isError: true);
      return;
    }
    if (_trip.selectedLanguages.isEmpty) {
      _showSnack("Please select at least one language", isError: true);
      return;
    }
    if (_trip.coverImage == null) {
      _showSnack("Please add a cover photo", isError: true);
      return;
    }
    if (_trip.startingDate == null || _trip.endingDate == null) {
      _showSnack("Please select start and end dates", isError: true);
      return;
    }

    // ── sync controllers → model ──
    _trip.tripName = _tripNameController.text;
    _trip.startingPoint = _startingPointController.text;
    _trip.endingPoint = _endingPointController.text;
    _trip.longDescription = _descriptionController.text;

    setState(() => _isPublishing = true);

    try {
      debugPrint('=== Starting createTripWithImage ===');
      debugPrint('tripName: ${_trip.tripName}');
      debugPrint('startingDate: ${_trip.startingDate}');
      debugPrint('coverImage: ${_trip.coverImage?.path}');
      debugPrint('itinerary count: ${_trip.itinerary.length}');

      final created = await CreateTripService.createTripWithImage(trip: _trip);

      debugPrint('=== Success: ${created.id} ===');
      debugPrint('=== Status: ${created.status} ==='); // ✅ أضيفيه هنا

      if (mounted) {
        setState(() => _isPublishing = false);
        _showSnack("Trip published successfully! 🎉");
        // ✅ بدل Navigator.pop
        widget.onTripCreated?.call();
      }
    } on ProblemDetails catch (e) {
      debugPrint('=== ProblemDetails: ${e.detail} ===');
      if (mounted) {
        setState(() => _isPublishing = false);
        _showSnack(e.detail, isError: true);
      }
    } catch (e, stack) {
      debugPrint('=== Unknown error: $e ===');
      debugPrint('=== Stack: $stack ===');
      if (mounted) {
        setState(() => _isPublishing = false);
        _showSnack("An error occurred. Please try again.", isError: true);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Create Trip Plan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Trip Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Fill in the information to list your tour services.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              BasicInfoSection(
                tripNameController: _tripNameController,
                startingPointController: _startingPointController,
                endingPointController: _endingPointController,
                startingDate: _trip.startingDate,
                endingDate: _trip.endingDate,
                onStartDateChanged:
                    (date) => setState(() => _trip.startingDate = date),
                onEndDateChanged:
                    (date) => setState(() => _trip.endingDate = date),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              OverviewSection(
                descriptionController: _descriptionController,
                selectedTypes: _trip.selectedTripTypes,
                onTypeToggled: (type, isSelected) {
                  setState(() {
                    isSelected
                        ? _trip.selectedTripTypes.add(type)
                        : _trip.selectedTripTypes.remove(type);
                  });
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              ItineraryBuilderSection(
                itinerary: _trip.itinerary,
                onAddDay: _addDay,
                onRemoveDay: _removeDay,
                onTitleChanged:
                    (index, val) => _trip.itinerary[index].dayTitle = val,
                onDescriptionChanged:
                    (index, val) => _trip.itinerary[index].description = val,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              PricingSection(
                currency: _trip.currency,
                price: _trip.price,
                isPerPerson: _trip.isPerPersonPrice,
                maxPersons: _trip.maxPersons,
                onCurrencyChanged:
                    (val) => setState(() => _trip.currency = val),
                onPriceChanged:
                    (val) => _trip.price = double.tryParse(val) ?? 0.0,
                onPerPersonToggled:
                    (val) => setState(() => _trip.isPerPersonPrice = val),
                onIncrease: () => setState(() => _trip.maxPersons++),
                onDecrease: () {
                  if (_trip.maxPersons > 1) {
                    setState(() => _trip.maxPersons--);
                  }
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              DurationSection(
                days: _trip.days,
                nights: _trip.nights,
                onDaysChanged:
                    (val) =>
                        setState(() => _trip.days = int.tryParse(val) ?? 0),
                onNightsChanged:
                    (val) =>
                        setState(() => _trip.nights = int.tryParse(val) ?? 0),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              LanguagesSection(
                selectedLanguages: _trip.selectedLanguages,
                onLanguageToggled: (lang, isSelected) {
                  setState(() {
                    isSelected
                        ? _trip.selectedLanguages.add(lang)
                        : _trip.selectedLanguages.remove(lang);
                  });
                },
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              PhotoSection(
                coverImage: _trip.coverImage,
                onPickImage: _pickCoverImage,
              ),

              const SizedBox(height: 32),

              // ── Publish Button ──────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isPublishing ? null : _onPublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB9975B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isPublishing
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : const Text(
                            "Publish Trip",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
