import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/movie.dart';
import '../models/cast.dart'; // Import cast model too

class Api {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey = Constants.apiKey;

  Future<List<Movie>> getTrendingMovies() async {
    final url = Uri.parse('$baseUrl/trending/movie/day?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final url = Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final url = Uri.parse('$baseUrl/movie/upcoming?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  Future<String?> getTrailerKey(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      if (results.isNotEmpty) {
        final trailer = results.firstWhere(
          (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
          orElse: () => null,
        );
        return trailer?['key'];
      }
    }
    return null;
  }

  Future<List<Cast>> getCast(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/credits?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final castList =
          (data['cast'] as List).map((json) => Cast.fromJson(json)).toList();
      return castList;
    }
    return [];
  }
}
