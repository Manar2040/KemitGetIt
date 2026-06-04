class HoldRequest {
  final String title;
  final String from;
  final String timeLeft;

  HoldRequest({
    required this.title,
    required this.from,
    required this.timeLeft,
  });
}



final List<HoldRequest> holdRequests = [
  HoldRequest(
    title: "Old Town Secret Bars",
    from: "Alex Wong",
    timeLeft: "18h left",
  ),
  HoldRequest(
    title: "Pyramids",
    from: "William",
    timeLeft: "23h left",
  ),
  HoldRequest(
    title: "Historical Center Walk",
    from: "Thomas",
    timeLeft: "24h left",
  ),
  HoldRequest(
    title: "Alex",
    from: "Elli",
    timeLeft: "2d",
  ),
  HoldRequest(
    title: "Luxor",
    from: "Billi",
    timeLeft: "7d",
  ),
  HoldRequest(
    title: "Luxor",
    from: "Billi",
    timeLeft: "7d",
  ),
  HoldRequest(
    title: "Luxor",
    from: "Billi",
    timeLeft: "7d",
  ),
  HoldRequest(
    title: "Luxor",
    from: "Billi",
    timeLeft: "7d",
  ),
];
