import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

class FavoritesNotifier extends Notifier<List<Movie>> {
  static const _storageKey = 'favorites';

  @override
  List<Movie> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];

    state = saved
        .map((text) => Movie.fromMap(jsonDecode(text) as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggle(Movie movie) async {
    final alreadyFavorite = state.any((m) => m.id == movie.id);

    if (alreadyFavorite) {
      state = state.where((m) => m.id != movie.id).toList();
    } else {
      state = [movie, ...state];
    }

    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      state.map((m) => jsonEncode(m.toMap())).toList(),
    );
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<Movie>>(
  FavoritesNotifier.new,
);
