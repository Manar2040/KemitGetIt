import 'dart:io';
import 'package:kemit_get_it/features/guide/widgets/create_trip_widget.dart'
    show DayItineraryModel;

/// Mutable form-state model used only inside CreateTripScreen.
/// مفيش لها fromJson/toJson لأنها مش بتتبعت زي ما هي —
/// TripService هو اللي بيحوّلها لـ multipart FormData.
class CreateTripModel {
  String tripName = '';
  String startingPoint = '';
  String endingPoint = '';
  String longDescription = '';

  DateTime? startingDate;
  DateTime? endingDate;

  final List<String> selectedTripTypes = [];
  final List<String> selectedLanguages = [];

  String currency = 'USD';
  double price = 0.0;
  bool isPerPersonPrice = false;
  int maxPersons = 1;

  // مش بيتبعتوا للـ API — السيرفر بيحسب الـ duration تلقائي من التواريخ.
  // سايباهم هنا بس لعرضهم في الفورم كمعلومة استرشادية للجايد.
  int days = 0;
  int nights = 0;

  double locationLat = 0.0;
  double locationLng = 0.0;

  File? coverImage;

  List<DayItineraryModel> itinerary = [DayItineraryModel(dayNumber: 1)];
}