import '../models/place.dart';

class PlacesService {
  static List<Place> getFamousPlaces() {
    return [
      Place(
        id: '1',
        name: 'Pyramids of Giza',
        description: 'One of the Seven Wonders of the Ancient World',
        imageUrl: 'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?w=400',
        rating: 4.3,
        reviewCount: 548,
      ),
      Place(
        id: '2',
        name: 'Luxor Temple',
        description: 'Ancient Egyptian temple complex',
        imageUrl: 'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?w=400',
        rating: 4.5,
        reviewCount: 324,
      ),
      Place(
        id: '3',
        name: 'Abu Simbel',
        description: 'Massive rock-cut temples',
        imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=400',
        rating: 4.7,
        reviewCount: 289,
      ),
    ];
  }

  static List<Place> getRecommendedPlaces() {
    return [
      Place(
        id: '4',
        name: 'Karnak Temple',
        description: 'Largest ancient religious site',
        imageUrl: 'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=400',
        rating: 4.4,
        reviewCount: 412,
      ),
      Place(
        id: '5',
        name: 'Valley of the Kings',
        description: 'Royal tombs of pharaohs',
        imageUrl: 'https://images.unsplash.com/photo-1562679299-266819f93a06?w=400',
        rating: 4.6,
        reviewCount: 567,
      ),
      Place(
        id: '6',
        name: 'Sphinx',
        description: 'Iconic limestone statue',
        imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=400',
        rating: 4.5,
        reviewCount: 623,
      ),
      Place(
        id: '7',
        name: 'Egyptian Museum',
        description: 'World-famous antiquities collection',
        imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=400',
        rating: 4.3,
        reviewCount: 445,
      ),
    ];
  }
}
