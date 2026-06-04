class MatchedGuide {
  final String id;
  final String name;
  final String imageUrl;

  MatchedGuide({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

final List<MatchedGuide> mockMatchedGuides = [
  MatchedGuide(id: '1', name: 'Ahmed Nasser', imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg'),
  MatchedGuide(id: '2', name: 'Arwa Gamal', imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg'),
  MatchedGuide(id: '3', name: 'Amira Hassan', imageUrl: 'https://randomuser.me/api/portraits/women/68.jpg'),
  MatchedGuide(id: '4', name: 'Ahmed Ayman', imageUrl: 'https://randomuser.me/api/portraits/men/46.jpg'),
  MatchedGuide(id: '5', name: 'Youssef Mohamed', imageUrl: 'https://randomuser.me/api/portraits/men/97.jpg'),
];
