import 'package:kemit_get_it/data/models/hold_request_models.dart';
import 'package:kemit_get_it/data/models/tourist_models.dart';

/// Seed data matching the Backend Seed Data Testing Guide
class TouristSeedData {
  
  // 1. Omar (Fresh Account - Empty State)
  static final omarProfile = TouristProfileResponse(
    id: 1,
    userId: 10,
    email: 'omar@test.com',
    phoneNumber: '01011112222',
    preferredLanguage: 'Arabic',
    countryOfResidence: 'Egypt',
    age: 22,
    interests: [],
    profileImageUrl: '',
  );
  static final List<HoldRequestDto> omarRequests = [];

  // 2. Sara (Active Tourist - Private Options)
  static final saraProfile = TouristProfileResponse(
    id: 2,
    userId: 11,
    email: 'sara@test.com',
    phoneNumber: '01222223333',
    preferredLanguage: 'English',
    countryOfResidence: 'UAE',
    age: 28,
    interests: ['Adventure', 'Nature'],
    profileImageUrl: '',
  );
  
  static final List<HoldRequestDto> saraRequests = [
    HoldRequestDto(
      id: 101,
      touristUserId: 5,
      guideUserId: 2,
      guideName: 'Khaled Nasser',
      tripId: null,
      requestType: 'PrivateTrip',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 12)),
      numberOfTravelers: 2,
      travelerType: 'Group',
      transportPreference: 'PrivateCar',
      companionsInfo: '',
      preferredLanguage: 'English',
      accommodationNeeded: false,
      mealsIncluded: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      totalPrice: 0.0,
      status: 'Declined',
      currency: 'EGP',
    ),
    HoldRequestDto(
      id: 102,
      touristUserId: 5,
      guideUserId: 3,
      guideName: 'Nour Ibrahim',
      tripId: null,
      requestType: 'PrivateTrip',
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 18)),
      numberOfTravelers: 1,
      travelerType: 'Solo',
      transportPreference: 'PublicTransport',
      companionsInfo: '',
      preferredLanguage: 'English',
      accommodationNeeded: false,
      mealsIncluded: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      totalPrice: 0.0,
      status: 'PendingRequest',
      currency: 'EGP',
    ),
  ];

  // 3. John (Power User)
  static final johnProfile = TouristProfileResponse(
    id: 3,
    userId: 12,
    email: 'john@test.com',
    phoneNumber: '01555556666',
    preferredLanguage: 'English',
    countryOfResidence: 'UK',
    age: 35,
    interests: ['History', 'Culture'],
    profileImageUrl: '',
  );

  static final List<HoldRequestDto> johnRequests = [
    HoldRequestDto(
      id: 201,
      touristUserId: 6,
      guideUserId: 2,
      guideName: 'Khaled Nasser',
      tripTitle: 'Giza Pyramids Tour',
      tripId: 1,
      requestType: 'ReadyTrip',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      numberOfTravelers: 1,
      travelerType: 'Solo',
      transportPreference: 'PrivateCar',
      companionsInfo: '',
      preferredLanguage: 'English',
      accommodationNeeded: false,
      mealsIncluded: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      totalPrice: 350.0,
      status: 'Active',
      currency: 'EGP',
    ),
  ];

  // 4. Lena (History User - Completed past trips)
  static final lenaProfile = TouristProfileResponse(
    id: 4,
    userId: 13,
    email: 'lena@test.com',
    phoneNumber: '01044445555',
    preferredLanguage: 'German',
    countryOfResidence: 'Germany',
    age: 40,
    interests: ['History', 'Photography'],
    profileImageUrl: '',
  );

  static final List<HoldRequestDto> lenaRequests = [
    HoldRequestDto(
      id: 301,
      touristUserId: 7,
      guideUserId: 4,
      guideName: 'Hassan Farouk',
      tripTitle: 'Aswan & Abu Simbel Express',
      tripId: 4,
      requestType: 'ReadyTrip',
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      endDate: DateTime.now().subtract(const Duration(days: 18)),
      numberOfTravelers: 2,
      travelerType: 'Group',
      transportPreference: 'PrivateCar',
      companionsInfo: '',
      preferredLanguage: 'German',
      accommodationNeeded: false,
      mealsIncluded: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      totalPrice: 1500.0,
      status: 'Completed',
      currency: 'EGP',
    ),
  ];
}
