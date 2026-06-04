import '../models/guide.dart';

class GuidesService {
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
