import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://kemitgetitbackend101-production.up.railway.app/api/places?pageSize=2');
  final response = await http.get(url);
  print(response.body);
}
