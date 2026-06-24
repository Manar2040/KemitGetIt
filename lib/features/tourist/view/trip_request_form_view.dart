import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../routes/app_routes.dart';

import '../../../data/models/trip_models.dart';
import '../../../data/models/hold_request_models.dart';
import '../viewmodel/hold_request_viewmodel.dart';
import '../../../data/models/place.dart';
import 'dart:convert';

class Companion {
  String name;
  String nationality;
  Companion({this.name = '', this.nationality = ''});

  Map<String, dynamic> toJson() => {
        'name': name,
        'nationality': nationality,
      };
}

class TripRequestFormView extends StatefulWidget {
  final bool isFromTripPlan;
  final TripDetails? tripPlan;
  final Place? place;

  const TripRequestFormView({
    super.key,
    this.isFromTripPlan = false,
    this.tripPlan,
    this.place,
  });

  @override
  State<TripRequestFormView> createState() => _TripRequestFormViewState();
}

class _TripRequestFormViewState extends State<TripRequestFormView> {
  String? _tripType = 'Solo';
  String? _preferredLanguage = 'English';
  final Set<String> _additionalServices = {'Meals Included'}; // just for mock default
  DateTime? _startDate;
  DateTime? _endDate;
  final _vm = HoldRequestViewModel();
  String _numTravelers = '1-5';
  final TextEditingController _budgetController = TextEditingController();
  final List<Companion> _companions = [];

  @override
  void initState() {
    super.initState();
    if (widget.isFromTripPlan && widget.tripPlan != null) {
      _startDate = widget.tripPlan!.startDate;
      _endDate = widget.tripPlan!.endDate;
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _vm.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark),
          iconSize: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us more about your trip',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Please fill the following details so we can find a guide who best matches your interests and needs.',
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
            ),
            if (widget.place != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.place!.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.place!.imageUrl.startsWith('http')
                                  ? widget.place!.imageUrl
                                  : 'https://placehold.co/600x600/png',
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 60,
                                color: AppColors.borderLight,
                                child: const Icon(Icons.image, color: AppColors.textHint),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 60,
                              color: AppColors.borderLight,
                              child: const Icon(Icons.image, color: AppColors.textHint),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.place!.name,
                            style: AppTextStyles.label.copyWith(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.place!.location != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.place!.location!,
                              style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // Cancellation Policy Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC4AD85), // matching mock color
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Cancellation Policy',
                            style: AppTextStyles.label.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      const Icon(Icons.close, color: Colors.white, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can cancel your booking and receive a full refund if the cancellation is made at least 24 hours before the trip starts.',
                    style: AppTextStyles.bodyTextSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trip Type
            Text('Trip Type', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            _buildRadioOption('Solo', _tripType, (val) => setState(() => _tripType = val)),
            _buildRadioOption('Group', _tripType, (val) => setState(() => _tripType = val)),
            if (_tripType == 'Group') ...[
               Padding(
                 padding: const EdgeInsets.only(left: 32, top: 4, bottom: 8),
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   decoration: BoxDecoration(
                     border: Border.all(color: AppColors.borderLight),
                     borderRadius: BorderRadius.circular(24),
                     color: Colors.white,
                   ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _numTravelers,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['1-5', '6-10', '10+'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text('Number Of Travelers: $value', style: AppTextStyles.bodyTextSmall),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _numTravelers = val);
                        },
                      ),
                    ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(left: 32, bottom: 8),
                 child: Text('Companions Details (Optional)', style: AppTextStyles.label),
               ),
               ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: _companions.length,
                 itemBuilder: (context, index) {
                   return Padding(
                     padding: const EdgeInsets.only(left: 32, bottom: 12.0),
                     child: Row(
                       children: [
                         Expanded(
                           child: TextField(
                             onChanged: (val) => _companions[index].name = val,
                             decoration: InputDecoration(
                               labelText: 'Name',
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             ),
                           ),
                         ),
                         const SizedBox(width: 8),
                         Expanded(
                           child: TextField(
                             onChanged: (val) => _companions[index].nationality = val,
                             decoration: InputDecoration(
                               labelText: 'Nationality',
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             ),
                           ),
                         ),
                         IconButton(
                           icon: const Icon(Icons.remove_circle, color: Colors.red),
                           onPressed: () {
                             setState(() {
                               _companions.removeAt(index);
                             });
                           },
                         ),
                       ],
                     ),
                   );
                 },
               ),
               Padding(
                 padding: const EdgeInsets.only(left: 32, bottom: 8),
                 child: Align(
                   alignment: Alignment.centerLeft,
                   child: TextButton.icon(
                     onPressed: () {
                       setState(() {
                         _companions.add(Companion());
                       });
                     },
                     icon: const Icon(Icons.add, size: 18),
                     label: const Text('Add Companion'),
                     style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
                   ),
                 ),
               ),
            ],
            const SizedBox(height: 16),

            // Preferred Language
            Text('Preferred Language', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            _buildRadioOption('English', _preferredLanguage, (val) => setState(() => _preferredLanguage = val)),
            _buildRadioOption('Arabic', _preferredLanguage, (val) => setState(() => _preferredLanguage = val)),
            _buildRadioOption('French', _preferredLanguage, (val) => setState(() => _preferredLanguage = val)),
            _buildRadioOption('Other', _preferredLanguage, (val) => setState(() => _preferredLanguage = val)),
            const SizedBox(height: 16),

            if (!widget.isFromTripPlan) ...[
              // Additional Services
              Text('Additional Services', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              _buildCheckboxOption('Transportation'),
              _buildCheckboxOption('Accommodation'),
              _buildCheckboxOption('Meals Included'),
              const SizedBox(height: 16),
            ],

            // Dates (Always visible, but read-only for pre-planned trips)
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text('Start Date', style: AppTextStyles.label),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.isFromTripPlan
                              ? null // Date is fixed for pre-planned trips
                              : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setState(() => _startDate = picked);
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(20),
                              color: widget.isFromTripPlan ? Colors.grey[100] : Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDate(_startDate), style: AppTextStyles.hint),
                                Icon(Icons.calendar_today, size: 16, color: widget.isFromTripPlan ? Colors.grey : AppColors.textHint),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text('End Date', style: AppTextStyles.label),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.isFromTripPlan
                              ? null // Date is fixed for pre-planned trips
                              : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate ?? _startDate ?? DateTime.now(),
                                    firstDate: _startDate ?? DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (picked != null) {
                                    setState(() => _endDate = picked);
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(20),
                              color: widget.isFromTripPlan ? Colors.grey[100] : Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDate(_endDate), style: AppTextStyles.hint),
                                Icon(Icons.calendar_today, size: 16, color: widget.isFromTripPlan ? Colors.grey : AppColors.textHint),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 24),

            // Budget Field
            Text('Max Budget (EGP)', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
              ),
              child: TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter your budget in EGP',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB39256),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _vm.isSending ? null : () async {
                  if (_startDate == null || _endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select start and end dates.')));
                    return;
                  }
                  if (_budgetController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your budget.')));
                    return;
                  }

                  int parsedTravelers = 1;
                  if (_tripType == 'Group') {
                    if (_numTravelers == '1-5') parsedTravelers = 5;
                    else if (_numTravelers == '6-10') parsedTravelers = 10;
                    else parsedTravelers = 15;
                  }

                  final requestData = {
                    'requestType': widget.isFromTripPlan ? RequestType.readyTrip : RequestType.privateTrip,
                    'travelerType': _tripType == 'Solo' ? TravelerType.solo : TravelerType.group,
                    'numberOfTravelers': parsedTravelers,
                    'preferredLanguage': _preferredLanguage ?? 'English',
                    'transportPreference': _additionalServices.contains('Transportation') ? TransportPreference.privateCar : TransportPreference.noTransport,
                    'startDate': _startDate,
                    'endDate': _endDate,
                    'accommodationNeeded': _additionalServices.contains('Accommodation'),
                    'mealsIncluded': _additionalServices.contains('Meals Included'),
                    'maxPrice': double.tryParse(_budgetController.text.trim()) ?? 0.0,
                    'companionsInfo': jsonEncode(_companions.map((c) => c.toJson()).toList()),
                  };

                  if (widget.isFromTripPlan && widget.tripPlan != null) {
                    // Send ReadyTrip request directly
                    final dto = SendHoldRequestDto(
                      guideUserId: int.tryParse(widget.tripPlan!.guide?.id ?? '') ?? widget.tripPlan!.guideId,
                      tripId: widget.tripPlan!.id,
                      requestType: requestData['requestType'] as RequestType,
                      travelerType: requestData['travelerType'] as TravelerType,
                      numberOfTravelers: requestData['numberOfTravelers'] as int,
                      preferredLanguage: requestData['preferredLanguage'] as String,
                      transportPreference: requestData['transportPreference'] as TransportPreference,
                      startDate: requestData['startDate'] as DateTime,
                      endDate: requestData['endDate'] as DateTime,
                      accommodationNeeded: requestData['accommodationNeeded'] as bool,
                      mealsIncluded: requestData['mealsIncluded'] as bool,
                      companionsInfo: requestData['companionsInfo'] as String,
                    );
                    
                    final success = await _vm.sendRequest(dto);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Trip Request Sent!'),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_vm.errorMessage ?? 'Failed to send request')),
                      );
                    }
                  } else {
                    // Pass to matched guides for PrivateTrip
                    Navigator.pushNamed(
                      context,
                      AppRoutes.matchedGuides,
                      arguments: requestData,
                    );
                  }
                },
                child: _vm.isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.isFromTripPlan ? 'Send' : 'Show Matching Guides',
                        style: const TextStyle(
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
    );
  }

  Widget _buildRadioOption(String title, String? groupValue, ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: RadioListTile<String>(
        title: Text(title, style: AppTextStyles.bodyTextSmall),
        value: title,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Colors.grey,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildCheckboxOption(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
      ),
      child: CheckboxListTile(
        title: Text(title, style: AppTextStyles.bodyTextSmall),
        value: _additionalServices.contains(title),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _additionalServices.add(title);
            } else {
              _additionalServices.remove(title);
            }
          });
        },
        activeColor: Colors.grey,
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
