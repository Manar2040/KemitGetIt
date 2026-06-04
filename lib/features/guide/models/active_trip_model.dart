class ActiveTrip {
  final String image;
  final String title;
  final int tourists;
  final String timeLeft;

  ActiveTrip({
    required this.image,
    required this.title,
    required this.tourists,
    required this.timeLeft,
  });
}



final List<ActiveTrip> activeTrips = [
  ActiveTrip(
    image: "lib/features/guide/images/i (5).webp",
    title: "Historical center Walk",
    tourists: 4,
    timeLeft: "2h left",
  ),
  ActiveTrip(
    image: "lib/features/guide/images/i (4).webp",
    title: "Old Town Tour",
    tourists: 2,
    timeLeft: "4h left",
  ),
];