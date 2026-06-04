import '../../../data/models/guide.dart';
import 'guide_profile_repository.dart';

class MockGuideProfileRepository implements GuideProfileRepository {
  @override
  Future<Guide> getGuideProfile(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return the mock guide based on the mockup
    return Guide(
      id: id,
      name: "Ahmed Ashraf",
      location: "Cairo",
      rating: 4.9,
      reviews: 124,
      sharedInterests: [],
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
      description: "Expert Mountain Guide",
      aboutMe: "Passionate mountain guide with 10+ years of experience in technical climbing and alpine trekking. Specializing in high-altitude logistics and wilderness first aid. I've led over 200 successful expeditions across the Rockies and the Alps.",
      certifications: ["Alpine Climbing", "First Aid Certified", "Photography"],
      recentTrips: [
        TripItem(
          id: '1',
          title: 'Pyramids',
          dateRange: 'October 12 - 14 , 2032',
          price: 450.00,
          status: 'Completed',
          imageUrl: 'https://images.unsplash.com/photo-1539650116574-8efeb43e2b50?w=200',
        ),
        TripItem(
          id: '2',
          title: 'Luxor Temple',
          dateRange: 'November 1 - 5 , 2032',
          price: 600.00,
          status: 'Upcoming',
          imageUrl: 'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=200',
        ),
      ],
      recentFeedback: [
        FeedbackItem(
          id: '1',
          reviewerName: 'David K.',
          rating: 5.0,
          comment: "The guide's knowledge of the terrain was incredible. Every campsite was perfectly picked for the best views. Highly recommended for experienced trekkers.",
          reviewerImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
        ),
        FeedbackItem(
          id: '2',
          reviewerName: 'Emily R.',
          rating: 4.8,
          comment: "Amazing experience! The guide was patient and supportive the whole time even during the more challenging climbs.",
          reviewerImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
        ),
      ],
    );
  }
}
