class Guide {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final List<String> sharedInterests;
  final String imageUrl;
  final String description;

  Guide({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.sharedInterests,
    required this.imageUrl,
    required this.description,
  });
}
