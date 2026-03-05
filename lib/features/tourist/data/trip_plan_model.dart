class TripPlanModel {
  final String id;
  final String title;
  final String imageUrl;
  final String guideName;
  final String duration;
  final String price;
  final double rating;
  final int reviewsCount;
  final String status; // 'Available', 'Almost Full', 'Closed', 'Upcoming'

  TripPlanModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.guideName,
    required this.duration,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.status,
  });
}

class TripPlanDetailsModel {
  final String id;
  final String title;
  final String imageUrl;
  final String guideName;
  final String guideUserId;
  final String guideTitle;
  final double rating;
  final int reviewsCount;
  final List<String> tags;
  final String overview;

  final String startDate;
  final String startPoint;
  final String endPoint;
  final String duration;
  final String groupSize;
  final String price;

  final List<ItineraryDay> itinerary;
  
  // Add a few dummy reviews
  final List<ReviewModel> reviews;

  TripPlanDetailsModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.guideName,
    required this.guideUserId,
    required this.guideTitle,
    required this.rating,
    required this.reviewsCount,
    required this.tags,
    required this.overview,
    required this.startDate,
    required this.startPoint,
    required this.endPoint,
    required this.duration,
    required this.groupSize,
    required this.price,
    required this.itinerary,
    required this.reviews,
  });
}

class ItineraryDay {
  final int day;
  final String description;

  ItineraryDay({required this.day, required this.description});
}

class ReviewModel {
  final String reviewerName;
  final String location;
  final String comment;

  ReviewModel({
    required this.reviewerName,
    required this.location,
    required this.comment,
  });
}

// --- Dummy Data ---

final List<TripPlanModel> dummyTripPlans = [
  TripPlanModel(
    id: '1',
    title: 'Discover Luxor & Aswan',
    imageUrl: 'https://images.unsplash.com/photo-1539667468225-eebb663053e6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    guideName: 'Ahmed Nasser',
    duration: '5 Days',
    price: '\$450',
    rating: 4.7,
    reviewsCount: 358,
    status: 'Almost Full',
  ),
  TripPlanModel(
    id: '2',
    title: 'Cairo Highlights Tour',
    imageUrl: 'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    guideName: 'Sarah Mohamed',
    duration: '3 Days',
    price: '\$300',
    rating: 4.7,
    reviewsCount: 410,
    status: 'Closed',
  ),
  TripPlanModel(
    id: '3',
    title: 'Alexandria Cultural Getaway',
    imageUrl: 'https://images.unsplash.com/photo-1601366533287-5ee4c763ae4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    guideName: 'Mariam Fathy',
    duration: '2 Days',
    price: '\$250',
    rating: 4.5,
    reviewsCount: 200,
    status: 'Available',
  ),
  TripPlanModel(
    id: '4',
    title: 'Red Sea Adventure "Hurghada"',
    imageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    guideName: 'Omar Khaled',
    duration: '4 Days',
    price: '\$550',
    rating: 4.8,
    reviewsCount: 518,
    status: 'Upcoming',
  ),
];

final TripPlanDetailsModel dummyTripDetails = TripPlanDetailsModel(
  id: '1',
  title: 'Discover Luxor & Aswan',
  imageUrl: 'https://images.unsplash.com/photo-1539667468225-eebb663053e6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
  guideName: 'Ahmed Nasser',
  guideUserId: 'g1',
  guideTitle: 'Expert in Ancient Egyptian Tours',
  rating: 4.7,
  reviewsCount: 358,
  tags: ['Historical', 'Cultural'],
  overview:
      'Embark on a 5-day journey through the wonders of Upper Egypt, exploring ancient temples, the Nile River, and the charm of traditional villages. This guided trip combines history, culture, and comfort — ideal for tourists who want to experience Egypt\'s timeless beauty.',
  startDate: 'November 12, 2025',
  startPoint: 'Luxor',
  endPoint: 'Aswan',
  duration: '5 Days / 4 Nights',
  groupSize: 'Up to 10 tourists',
  price: '\$450 per person',
  itinerary: [
    ItineraryDay(
      day: 1,
      description: 'Arrival in Luxor, visit Karnak Temple, evening Nile cruise dinner',
    ),
    ItineraryDay(
      day: 2,
      description: 'Explore the Valley of the Kings & Hatshepsut Temple',
    ),
    ItineraryDay(
      day: 3,
      description: 'Travel to Edfu & Kom Ombo temples',
    ),
    ItineraryDay(
      day: 4,
      description: 'Arrive in Aswan, visit Philae Temple & the High Dam',
    ),
    ItineraryDay(
      day: 5,
      description: 'Free morning & departure',
    ),
  ],
  reviews: [
    ReviewModel(
      reviewerName: 'Emma',
      location: 'UK',
      comment: 'Amazing experience! The guide was very knowledgeable.',
    ),
    ReviewModel(
      reviewerName: 'Lucas',
      location: 'Brazil',
      comment: 'Perfect organization and unforgettable views.',
    ),
  ],
);
