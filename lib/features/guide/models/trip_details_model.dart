class TripDetailsModel {
  final String image;
  final String status;
  final String title;
  final String date;

  final String startPoint;
  final String endPoint;

  final int currentTourists;
  final int maxTourists;

  final List<String> currentTouristsImages;

  final double price;

  final String overview;

  final List<String> categories;

  final List<ItineraryModel> itinerary;

  final List<RequestModel> pendingRequests;

  final List<String> participatingTourists;

  final List<TripReviewModel> reviews;

  final double rating;
  final int reviewsCount;

  TripDetailsModel({
    required this.image,
    required this.status,
    required this.title,
    required this.date,
    required this.startPoint,
    required this.endPoint,
    required this.currentTourists,
    required this.maxTourists,
    required this.price,
    required this.overview,
    required this.categories,
    required this.itinerary,
    required this.pendingRequests,
    required this.participatingTourists,
    required this.reviews,
    required this.rating,
    required this.reviewsCount,
    required this.currentTouristsImages
  });
}

class ItineraryModel {
  final String dayTitle;
  final String description;

  ItineraryModel({required this.dayTitle, required this.description});
}

class RequestModel {
  final String name;
  final String image;
  final String info;

  RequestModel({required this.name, required this.image, required this.info});
}

class TripReviewModel {
  final String name;
  final String image;
  final double rating;
  final String review;

  TripReviewModel({
    required this.name,
    required this.image,
    required this.rating,
    required this.review,
  });
}


//list

List<TripDetailsModel> tripDetails = [
  TripDetailsModel(
    image: "lib/features/guide/images/i (5).webp",
    status: "Active",
    title: "Historical Center Walk",
    date: "Oct 12 - Oct 15",
    startPoint: "Alex",
    endPoint: "Giza",
    currentTourists: 7,
    maxTourists: 12,
    price: 450,
    overview:
        "A captivating 5-day Historical Center Walk through the heart of Egypt's rich heritage.",
    categories: ["History", "Culture"],
    itinerary: [
      ItineraryModel(
        dayTitle: "Day 01 : Arrival & Welcome Dinner",
        description: "Pick-up from Cairo International Airport",
      ),
      ItineraryModel(
        dayTitle: "Day 02 : The Great Pyramids",
        description: "Giza Plateau, Sphinx, and Camel Ride",
      ),
    ],
    pendingRequests: [
      RequestModel(
        name: "Sarah Jenkins",
        image: "lib/features/guide/images/i (2).webp",
        info: "Solo Traveler • USA",
      ),
    ],
    participatingTourists: [
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/i (2).webp",
    ],
    rating: 4.9,
    reviewsCount: 124,
    reviews: [
      TripReviewModel(
        name: "David K.",
        image: "lib/features/guide/images/i (2).webp",
        rating: 5,
        review:
            "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked.",
      ),
    ],

    currentTouristsImages:[
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",

    ]
  ),

  TripDetailsModel(
    image: "lib/features/guide/images/i (4).webp",
    status: "Draft",
    title: "Desert Safari Adventure",
    date: "Nov 5 - Nov 8",
    startPoint: "Cairo",
    endPoint: "Siwa",
    currentTourists: 4,
    maxTourists: 10,
    price: 600,
    overview: "Explore the beautiful desert landscapes and oases of Egypt.",
    categories: ["Adventure", "Nature"],
    itinerary: [
      ItineraryModel(
        dayTitle: "Day 01 : Arrival & Camp Setup",
        description: "Pick-up and desert camp experience",
      ),
      ItineraryModel(
        dayTitle: "Day 02 : Sandboarding & Camel Trek",
        description: "Enjoy thrilling desert activities",
      ),
    ],
    pendingRequests: [],
    participatingTourists: [],
    rating: 4.5,
    reviewsCount: 32,
    reviews: [
      TripReviewModel(
        name: "David K.",
        image: "lib/features/guide/images/i (2).webp",
        rating: 5,
        review:
            "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked.",
      ),
    ],
    currentTouristsImages:[
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",
      

    ]
  ),

  TripDetailsModel(
    image: "lib/features/guide/images/i (5).webp",
    status: "Completed",
    title: "Nile River Cruise",
    date: "Sep 10 - Sep 15",
    startPoint: "Luxor",
    endPoint: "Aswan",
    currentTourists: 12,
    maxTourists: 12,
    price: 800,
    overview: "Relax and enjoy the Nile River on a luxurious cruise.",
    categories: ["Relaxation", "Culture"],
    itinerary: [
      ItineraryModel(
        dayTitle: "Day 01 : Boarding & Welcome",
        description: "Board the cruise and explore Luxor",
      ),
      ItineraryModel(
        dayTitle: "Day 02 : Temples & Sightseeing",
        description: "Visit Karnak and Luxor Temples",
      ),
    ],
    pendingRequests: [],
    participatingTourists: [],
    rating: 5.0,
    reviewsCount: 50,
    reviews: [
      TripReviewModel(
        name: "David K.",
        image: "lib/features/guide/images/i (2).webp",
        rating: 5,
        review:
            "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked.",
      ),
    ],
    currentTouristsImages:[
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",
     
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      

    

    ]
  ),

  TripDetailsModel(
    image: "lib/features/guide/images/i (4).webp",
    status: "Active",
    title: "Red Sea Diving",
    date: "Dec 1 - Dec 5",
    startPoint: "Hurghada",
    endPoint: "Hurghada",
    currentTourists: 6,
    maxTourists: 8,
    price: 700,
    overview:
        "Discover the underwater world of the Red Sea with guided diving tours.",
    categories: ["Adventure", "Water Sports"],
    itinerary: [
      ItineraryModel(
        dayTitle: "Day 01 : Arrival & Diving Briefing",
        description: "Get ready for your diving adventure",
      ),
      ItineraryModel(
        dayTitle: "Day 02 : Coral Reefs Diving",
        description: "Explore the most beautiful coral reefs",
      ),
    ],
    pendingRequests: [],
    participatingTourists: [],
    rating: 4.8,
    reviewsCount: 40,
    reviews: [
      TripReviewModel(
        name: "David K.",
        image: "lib/features/guide/images/i (2).webp",
        rating: 5,
        review:
            "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked.",
      ),
    ],
    currentTouristsImages:[
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
     
    ]
  ),

  TripDetailsModel(
   image: "lib/features/guide/images/i (5).webp",
    status: "Draft",
    title: "Cairo City Highlights",
    date: "Oct 20 - Oct 22",
    startPoint: "Cairo",
    endPoint: "Cairo",
    currentTourists: 3,
    maxTourists: 5,
    price: 200,
    overview: "Explore the main attractions of Cairo in a short city trip.",
    categories: ["City Tour", "Culture"],
    itinerary: [
      ItineraryModel(
        dayTitle: "Day 01 : Museums & Markets",
        description: "Visit Egyptian Museum and Khan El Khalili",
      ),
      ItineraryModel(
        dayTitle: "Day 02 : Citadel & Mosques",
        description: "Explore the Citadel and historic mosques",
      ),
    ],
    pendingRequests: [],
    participatingTourists: [],
    rating: 4.2,
    reviewsCount: 10,
    reviews: [
      TripReviewModel(
        name: "David K.",
        image: "lib/features/guide/images/i (3).webp",
        rating: 5,
        review:
            "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked.",
      ),
    ],
    currentTouristsImages:[
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      

    ]
  ),

  TripDetailsModel(
    image: "lib/features/guide/images/i (4).webp",
    status: "Completed",
    title: "Alexandria Beach Holiday",
    date: "Aug 15 - Aug 20",
    startPoint: "Alex",
    endPoint: "Alex",
    currentTourists: 5,
    maxTourists: 7,
    price: 350,
    overview:
        "Relax on the beaches of Alexandria and enjoy the Mediterranean views.",
    categories: ["Relaxation", "Beach"],
    itinerary: [
      ItineraryModel(
        dayTitle: "Day 01 : Arrival & Beach Time",
        description: "Settle in and enjoy the beach",
      ),
      ItineraryModel(
        dayTitle: "Day 02 : Local Sightseeing",
        description: "Visit Montaza Palace and Corniche",
      ),
    ],
    pendingRequests: [],
    participatingTourists: [],
    rating: 4.7,
    reviewsCount: 22,
    reviews: [
      TripReviewModel(
        name: "David K.",
        image: "lib/features/guide/images/person1 (1).jpg",
        rating: 5,
        review:
            "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked.",
      ),
      TripReviewModel(
        name: "Emily R.",
        image: "lib/features/guide/images/i (3).webp",
        rating: 2,
        review:
            "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked.",
      ),
    ],
    currentTouristsImages:[
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      "lib/features/guide/images/person1 (1).jpg",
      "lib/features/guide/images/i (3).webp",
      "lib/features/guide/images/i (2).webp",
      

    ]
  ),
];
