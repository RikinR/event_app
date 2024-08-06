import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  final String _apiKey = 'pYimFBEUKuaHhMA7QhFP25t7MpTmvuQBaAm-ra4zHrc';
  final String _baseUrl = 'https://api.unsplash.com/photos';

  Future<List<String>> fetchRandomPhotos({int count = 5}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/random?count=$count&client_id=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse
          .map((photo) => photo['urls']['regular'] as String)
          .toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }
}
