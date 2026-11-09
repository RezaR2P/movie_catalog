import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _service = TmdbService();
  final _controller = TextEditingController();
  Timer? _debounce;

  List<Movie> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(text));
  }

  Future<void> _search(String text) async {
    final query = text.trim();

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movies = await _service.searchMovies(query);
      // Abaikan hasil lama jika halaman ditutup atau teks sudah berubah
      if (!mounted || _controller.text.trim() != query) return;
      setState(() {
        _results = movies;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Terjadi kesalahan:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_controller.text.trim().isEmpty) {
      return const Center(child: Text('Ketik judul film untuk mencari'));
    }
    if (_results.isEmpty) {
      return const Center(child: Text('Film tidak ditemukan'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) => MovieCard(movie: _results[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Film')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari judul film',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
