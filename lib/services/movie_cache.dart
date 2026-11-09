import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';
import '../models/movie_category.dart';

class MovieCache {
  String _key(MovieCategory category) => 'cache_${category.path}';

  Future<void> save(MovieCategory category, List<Movie> movies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key(category),
      movies.map((m) => jsonEncode(m.toMap())).toList(),
    );
  }

  Future<List<Movie>?> load(MovieCategory category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key(category));
      if (saved == null) return null;

      return saved
          .map(
            (text) => Movie.fromMap(jsonDecode(text) as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      // Data tersimpan rusak? Anggap saja tidak ada cache.
      return null;
    }
  }
}
