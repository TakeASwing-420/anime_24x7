import 'dart:convert';
import 'package:http/http.dart' as http;

class DBMSHelper {
  static String baseUrl = 'http://127.0.0.1:5000';

  static Future<String> registerUser(String username, String password,
      String confirmPassword, String favoriteAnime) async {
    await Future.delayed(Duration(seconds: 2));

    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
        'confirmPassword': confirmPassword,
        'favoriteAnime': favoriteAnime,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'];
    } else {
      throw Exception('Failed to register user');
    }
  }

  static Future<String> loginUser(String username, String password) async {
    await Future.delayed(Duration(seconds: 2));

    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"];
    } else {
      throw Exception('Failed to login user');
    }
  }

  static Future<List<Map<String, dynamic>>> getUsersWithSimilarFavoriteAnime(
      String favoriteAnime) async {
    final url = Uri.parse(
        '$baseUrl/get_users_with_similar_favorite_anime?favoriteAnime=$favoriteAnime');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data.map((user) => {
            'username': user['username'],
            'favoriteAnime': user['favoriteAnime'],
          }));
    } else {
      throw Exception('Failed to get users with similar favorite anime.');
    }
  }

  static Future<List<String>> getAnimeRecommendations(String animeName) async {
    final url =
        Uri.parse('$baseUrl/get_anime_recommendations?anime_name=$animeName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data);
    } else {
      throw Exception('Failed to get anime recommendations.');
    }
  }
}
