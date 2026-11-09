import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../models/movie_category.dart';
import '../models/movie_detail.dart';
import '../models/movie_page.dart';

class TmdbService {
  static const String _apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  void _ensureApiKey() {
    if (_apiKey.isEmpty) {
      throw Exception(
        'API key belum diatur. Jalankan dengan --dart-define-from-file=env.json',
      );
    }
  }

  Future<MoviePage> fetchMovies(MovieCategory category, {int page = 1}) {
    return _getMoviePage('/movie/${category.path}', {}, page);
  }

  Future<List<Movie>> searchMovies(String query) async {
    final result = await _getMoviePage('/search/movie', {'query': query}, 1);
    return result.movies;
  }

  Future<MovieDetail> fetchMovieDetail(int id) async {
    _ensureApiKey();

    final uri = Uri.parse('$_baseUrl/movie/$id')
        .replace(queryParameters: {'api_key': _apiKey, 'language': 'id-ID'});

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat detail (kode ${response.statusCode})');
    }

    return MovieDetail.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<MoviePage> _getMoviePage(
    String path,
    Map<String, String> params,
    int page,
  ) async {
    _ensureApiKey();

    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: {
        'api_key': _apiKey,
        'language': 'id-ID',
        'page': '$page',
        ...params,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat film (kode ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;

    return MoviePage(
      movies: results
          .map((json) => Movie.fromJson(json as Map<String, dynamic>))
          .toList(),
      page: data['page'] as int? ?? page,
      totalPages: data['total_pages'] as int? ?? 1,
    );
  }
}
