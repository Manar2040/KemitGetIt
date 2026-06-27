import '../../core/services/api_client.dart';
import '../models/guide.dart';

class GuidesService {
  GuidesService._();
  static final GuidesService instance = GuidesService._();
  final _client = ApiClient.instance;

  Future<Guide> getGuideProfile(int userId) async {
    final data = await _client.get('/api/guides/$userId', auth: false);
    final j = data as Map<String, dynamic>;
    
    // Parse specialization into certifications/specialties
    final specStr = j['specialization'] as String? ?? '';
    final specs = specStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    // Parse recentReviews into FeedbackItem
    final reviewsList = j['recentReviews'] as List? ?? [];
    final feedback = reviewsList.map((r) {
      final rm = r as Map<String, dynamic>;
      return FeedbackItem(
        id: (rm['id'] ?? '').toString(),
        reviewerName: rm['touristName'] != null && (rm['touristName'] as String).isNotEmpty
            ? rm['touristName'] as String
            : 'Tourist',
        rating: (rm['guideRating'] as num?)?.toDouble() ?? (rm['rating'] as num?)?.toDouble() ?? 5.0,
        comment: rm['comment'] as String? ?? '',
        reviewerImageUrl: rm['touristImageUrl'] as String? ?? '',
      );
    }).toList();

    return Guide(
      id: (j['userId'] ?? userId).toString(),
      name: j['displayName'] as String? ?? '${j['firstName'] ?? ''} ${j['lastName'] ?? ''}'.trim(),
      location: j['workingRegions'] as String? ?? 'Egypt',
      rating: (j['averageRating'] as num?)?.toDouble() ?? (j['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: j['totalReviews'] as int? ?? j['reviewCount'] as int? ?? 0,
      sharedInterests: [],
      imageUrl: j['profileImageUrl'] as String? ?? '',
      description: j['bio'] as String? ?? '',
      aboutMe: j['bio'] as String? ?? '',
      certifications: specs,
      recentFeedback: feedback,
      recentTrips: [], // The backend doesn't return guide trips in this endpoint.
    );
  }

  Future<List<Guide>> getGuides({double minRating = 0.0, String? language}) async {
    final queryParams = <String, String>{
      'page': '1',
      'pageSize': '50',
    };
    if (minRating > 0) {
      queryParams['minRating'] = minRating.toString();
    }
    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
    }
    
    final data = await _client.get('/api/guides', auth: false, queryParams: queryParams);
    final j = data as Map<String, dynamic>;
    final items = j['items'] as List? ?? [];
    
    return items.map((g) {
      final rm = g as Map<String, dynamic>;
      final specStr = rm['specialization'] as String? ?? '';
      final specs = specStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      return Guide(
        id: (rm['userId'] ?? rm['id'] ?? '').toString(),
        name: rm['displayName'] as String? ?? '${rm['firstName'] ?? ''} ${rm['lastName'] ?? ''}'.trim(),
        location: rm['workingRegions'] as String? ?? 'Egypt',
        rating: (rm['averageRating'] as num?)?.toDouble() ?? (rm['rating'] as num?)?.toDouble() ?? 0.0,
        reviews: rm['totalReviews'] as int? ?? rm['reviewCount'] as int? ?? 0,
        sharedInterests: [],
        imageUrl: rm['profileImageUrl'] as String? ?? '',
        description: rm['bio'] as String? ?? '',
        aboutMe: rm['bio'] as String? ?? '',
        certifications: specs,
        recentFeedback: [],
        recentTrips: [],
      );
    }).toList();
  }

  Future<List<Guide>> matchGuides(Map<String, dynamic> requestData) async {
    final body = <String, dynamic>{};
    if (requestData['startDate'] != null) body['startDate'] = requestData['startDate'];
    if (requestData['endDate'] != null) body['endDate'] = requestData['endDate'];
    if (requestData['preferredLanguage'] != null) body['preferredLanguage'] = requestData['preferredLanguage'];
    if (requestData['placeIds'] != null) body['placeIds'] = requestData['placeIds'];
    if (requestData['numberOfTravelers'] != null) body['numberOfTravelers'] = requestData['numberOfTravelers'];
    if (requestData['maxPrice'] != null) body['maxPrice'] = requestData['maxPrice'];

    final data = await _client.post('/api/guides/match', body: body, auth: false);
    final items = data as List? ?? [];
    
    return items.map((g) {
      final rm = g as Map<String, dynamic>;
      return Guide(
        id: (rm['id'] ?? '').toString(),
        name: rm['name'] as String? ?? 'Unknown Guide',
        location: 'Egypt', // Not returned by match endpoint
        rating: (rm['rating'] as num?)?.toDouble() ?? 0.0,
        reviews: 0,
        sharedInterests: [],
        imageUrl: rm['photoUrl'] as String? ?? '',
        description: '',
        aboutMe: '',
        certifications: (rm['languages'] as List?)?.map((e) => e.toString()).toList() ?? [],
        recentFeedback: [],
        recentTrips: [],
      );
    }).toList();
  }

  static List<Guide> getDummyGuides() {
    return [
      Guide(
        id: '1',
        name: 'Ahmed Hassan',
        location: 'Cairo',
        rating: 4.8,
        reviews: 124,
        sharedInterests: ['History', 'Photography', 'Food'],
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
        description: 'Expert in Islamic Cairo and street photography.',
      ),
      Guide(
        id: '2',
        name: 'Sara Ali',
        location: 'Luxor',
        rating: 4.9,
        reviews: 89,
        sharedInterests: ['Archaeology', 'Culture'],
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        description: 'Passionate about ancient Egyptian history and temples.',
      ),
      Guide(
        id: '3',
        name: 'Omar Farouk',
        location: 'Aswan',
        rating: 4.6,
        reviews: 56,
        sharedInterests: ['Nature', 'Sailing', 'Nubian Culture'],
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        description: 'Enjoy the beauty of the Nile and Nubian villages with me.',
      ),
      Guide(
        id: '4',
        name: 'Mona Youssef',
        location: 'Alexandria',
        rating: 4.7,
        reviews: 112,
        sharedInterests: ['History', 'Food', 'Sea'],
        imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
        description: 'Discover the Greco-Roman monuments and best seafood spots.',
      ),
      Guide(
        id: '5',
        name: 'Khaled Ibrahim',
        location: 'Cairo',
        rating: 4.5,
        reviews: 45,
        sharedInterests: ['Shopping', 'Nightlife', 'Food'],
        imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200',
        description: 'I will show you the vibrant side of Cairo from markets to cafes.',
      ),
    ];
  }
}
