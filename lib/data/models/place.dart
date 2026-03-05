class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final String fullDescription;
  final String location;
  final String openingHours;
  final String entryFee;
  final String bestTimeToVisit;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.categories = const [],
    this.fullDescription = 'No description available',
    this.location = 'Location not specified',
    this.openingHours = 'Opening hours not available',
    this.entryFee = 'Free',
    this.bestTimeToVisit = 'Year round',
  });
}