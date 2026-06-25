import 'dart:io';
import 'package:flutter/material.dart';

// ── Constants used by the form ──────────────────────────────

const List<String> availableTripTypes = [
  'Cultural',
  'Historical',
  'Adventure',
  'Religious',
  'Nature',
  'Desert',
  'Coastal',
  'City Tour',
];

const List<String> availableLanguages = [
  'Arabic',
  'English',
  'French',
  'German',
  'Spanish',
  'Italian',
  'Russian',
  'Chinese',
  'Japanese',
];

const List<String> availableCurrencies = [
  'USD',
  'EUR',
  'EGP',
  'GBP',
  'SAR',
  'AED',
];

// ── Local UI model for itinerary day builder ────────────────
class DayItineraryModel {
  int dayNumber;       
  String dayTitle;
  String description;

  DayItineraryModel({
    required this.dayNumber,
    this.dayTitle = '',
    this.description = '',
  });
}

// ════════════════════════════════════════════════════════
// 1. SECTION HEADER WIDGET
// ════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB9975B), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// 2. STYLED TEXT FIELD WIDGET
// ════════════════════════════════════════════════════════
class TripTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const TripTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB9975B)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// 3. BASIC INFORMATION SECTION
// ════════════════════════════════════════════════════════
class BasicInfoSection extends StatelessWidget {
  final TextEditingController tripNameController;
  final TextEditingController startingPointController;
  final TextEditingController endingPointController;
  final DateTime? startingDate;
  final DateTime? endingDate;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;

  const BasicInfoSection({
    super.key,
    required this.tripNameController,
    required this.startingPointController,
    required this.endingPointController,
    required this.startingDate,
    required this.endingDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  Future<void> _pickDate(
    BuildContext context,
    DateTime? initial,
    Function(DateTime) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFB9975B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(icon: Icons.info_outline, title: "Basic Information"),

        const Text("Trip Name",
            style: TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TripTextField(
          hint: "e.g. Alpine Summit Explorer",
          controller: tripNameController,
          validator:
              (v) => v == null || v.isEmpty ? "Trip name is required" : null,
        ),

        const SizedBox(height: 12),
        const Text("Starting Point",
            style: TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TripTextField(
          hint: "City or landmark",
          controller: startingPointController,
          validator: (v) =>
              v == null || v.isEmpty ? "Starting point is required" : null,
        ),

        const SizedBox(height: 12),
        const Text("Ending Point",
            style: TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TripTextField(
          hint: "City or landmark",
          controller: endingPointController,
          validator: (v) =>
              v == null || v.isEmpty ? "Ending point is required" : null,
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Starting date",
                      style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  _DatePickerField(
                    date: startingDate,
                    onTap: () =>
                        _pickDate(context, startingDate, onStartDateChanged),
                    formatDate: _formatDate,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ending date",
                      style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  _DatePickerField(
                    date: endingDate,
                    onTap: () =>
                        _pickDate(context, endingDate, onEndDateChanged),
                    formatDate: _formatDate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;
  final String Function(DateTime?) formatDate;

  const _DatePickerField({
    required this.date,
    required this.onTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(formatDate(date),
                  style: const TextStyle(fontSize: 13)),
            ),
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// 4. OVERVIEW & DETAILS SECTION
// ════════════════════════════════════════════════════════
class OverviewSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final List<String> selectedTypes;
  final Function(String, bool) onTypeToggled;

  const OverviewSection({
    super.key,
    required this.descriptionController,
    required this.selectedTypes,
    required this.onTypeToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.description_outlined,
          title: "Overview & Details",
        ),
        const Text("Long Description", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        TripTextField(
          hint: "Describe the soul of this journey...",
          controller: descriptionController,
          maxLines: 4,
          validator: (v) =>
              v == null || v.isEmpty ? "Description is required" : null,
        ),
        const SizedBox(height: 12),
        const Text("Trip Type", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTripTypes.map((type) {
            final isSelected = selectedTypes.contains(type);
            return GestureDetector(
              onTap: () => onTypeToggled(type, !isSelected),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFB9975B)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// 5. ITINERARY BUILDER SECTION
// ════════════════════════════════════════════════════════
class ItineraryBuilderSection extends StatelessWidget {
  final List<DayItineraryModel> itinerary;
  final VoidCallback onAddDay;
  final Function(int) onRemoveDay;
  final Function(int, String) onTitleChanged;
  final Function(int, String) onDescriptionChanged;

  const ItineraryBuilderSection({
    super.key,
    required this.itinerary,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.map_outlined,
          title: "Itinerary Builder",
          trailing: GestureDetector(
            onTap: onAddDay,
            child: const Row(
              children: [
                Icon(Icons.add_circle_outline,
                    color: Color(0xFFB9975B), size: 18),
                SizedBox(width: 4),
                Text(
                  "Add Day",
                  style: TextStyle(
                    color: Color(0xFFB9975B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        ...itinerary.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          return _DayCard(
            day: day,
            index: index,
            onRemove: () => onRemoveDay(index),
            onTitleChanged: (val) => onTitleChanged(index, val),
            onDescriptionChanged: (val) => onDescriptionChanged(index, val),
          );
        }),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  final DayItineraryModel day;
  final int index;
  final VoidCallback onRemove;
  final Function(String) onTitleChanged;
  final Function(String) onDescriptionChanged;

  const _DayCard({
    required this.day,
    required this.index,
    required this.onRemove,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Day ${day.dayNumber.toString().padLeft(2, '0')}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: day.dayTitle,
            onChanged: onTitleChanged,
            decoration: InputDecoration(
              hintText: "Day Title (e.g. Arrival & Welcome Dinner...)",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFB9975B)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: day.description,
            onChanged: onDescriptionChanged,
            decoration: InputDecoration(
              hintText: "Short description of the day's activities",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFB9975B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// 6. PRICING & CAPACITY SECTION
// ════════════════════════════════════════════════════════
class PricingSection extends StatelessWidget {
  final String currency;
  final double price;
  final bool isPerPerson;
  final int maxPersons;
  final Function(String) onCurrencyChanged;
  final Function(String) onPriceChanged;
  final Function(bool) onPerPersonToggled;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const PricingSection({
    super.key,
    required this.currency,
    required this.price,
    required this.isPerPerson,
    required this.maxPersons,
    required this.onCurrencyChanged,
    required this.onPriceChanged,
    required this.onPerPersonToggled,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            icon: Icons.attach_money, title: "Pricing & capacity"),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Currency", style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currency,
                        isExpanded: true,
                        items: availableCurrencies
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c,
                                      style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) onCurrencyChanged(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Price", style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    initialValue: price.toStringAsFixed(2),
                    keyboardType: TextInputType.number,
                    onChanged: onPriceChanged,
                    decoration: InputDecoration(
                      hintText: "0.00",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFB9975B)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text("Per Person Price", style: TextStyle(fontSize: 13)),
            const Spacer(),
            Switch(
              value: isPerPerson,
              onChanged: onPerPersonToggled,
              activeThumbColor: const Color(0xFFB9975B),
              activeTrackColor: const Color(0xFFB9975B).withOpacity(0.4),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text("Max Persons", style: TextStyle(fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            _CounterButton(icon: Icons.remove, onTap: onDecrease),
            const SizedBox(width: 20),
            Text(
              maxPersons.toString(),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 20),
            _CounterButton(icon: Icons.add, onTap: onIncrease),
          ],
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// 7. DURATION SECTION (display-only — السيرفر بيحسبها تلقائي)
// ════════════════════════════════════════════════════════
class DurationSection extends StatelessWidget {
  final int days;
  final int nights;
  final Function(String) onDaysChanged;
  final Function(String) onNightsChanged;

  const DurationSection({
    super.key,
    required this.days,
    required this.nights,
    required this.onDaysChanged,
    required this.onNightsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            icon: Icons.access_time_outlined, title: "Duration"),
        Row(
          children: [
            Expanded(
              child: _DurationInputField(
                label: "Days",
                initialValue: days.toString(),
                onChanged: onDaysChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DurationInputField(
                label: "Nights",
                initialValue: nights.toString(),
                onChanged: onNightsChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DurationInputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final Function(String) onChanged;

  const _DurationInputField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFB9975B)),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// 8. LANGUAGES SECTION
// ════════════════════════════════════════════════════════
class LanguagesSection extends StatefulWidget {
  final List<String> selectedLanguages;
  final Function(String, bool) onLanguageToggled;

  const LanguagesSection({
    super.key,
    required this.selectedLanguages,
    required this.onLanguageToggled,
  });

  @override
  State<LanguagesSection> createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends State<LanguagesSection> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    final displayedLanguages =
        showAll ? availableLanguages : availableLanguages.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(icon: Icons.language, title: "Languages"),
        ...displayedLanguages.map((lang) {
          final isSelected = widget.selectedLanguages.contains(lang);
          return GestureDetector(
            onTap: () => widget.onLanguageToggled(lang, !isSelected),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFDF3E3)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFB9975B)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isSelected
                        ? const Color(0xFFB9975B)
                        : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(lang, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        }),
        if (!showAll && availableLanguages.length > 3)
          GestureDetector(
            onTap: () => setState(() => showAll = true),
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: Color(0xFFB9975B), size: 18),
                  SizedBox(width: 6),
                  Text(
                    "more Languages",
                    style: TextStyle(
                        color: Color(0xFFB9975B), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════
// 9. PHOTO SECTION
// ════════════════════════════════════════════════════════
class PhotoSection extends StatelessWidget {
  final File? coverImage;
  final VoidCallback onPickImage;

  const PhotoSection({
    super.key,
    required this.coverImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            icon: Icons.photo_camera_outlined, title: "Photo"),
        const Text("Cover image",
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: coverImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      coverImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_outlined,
                          size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        "Main Trip Cover",
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}