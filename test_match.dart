import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://kemitgetitbackend101-production.up.railway.app/api/guides/match');
  final body = {
    "startDate": "2026-07-01",
    "endDate": "2026-07-07",
    "preferredLanguage": "English",
    "placeIds": [1, 2],
    "numberOfTravelers": 2,
    "maxPrice": 5000.0
  };
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
