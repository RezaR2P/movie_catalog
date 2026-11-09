import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../models/movie_category.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/movie_grid_skeleton.dart';
import '../services/movie_cache.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = TmdbService();
  final _cache = MovieCache();
  bool _isOffline = false;
  final _scrollController = ScrollController();

  MovieCategory _selected = MovieCategory.popular;
  final List<Movie> _movies = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false; // muat pertama / ganti kategori
  bool _isLoadingMore = false; // muat halaman berikutnya
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  void _selectCategory(MovieCategory category) {
    if (category == _selected) return;
    _selected = category;
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    final category = _selected;

    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _isOffline = false;
      _error = null;
      _movies.clear();
      _page = 1;
      _hasMore = true;
    });

    try {
      final result = await _service.fetchMovies(category, page: 1);
      if (!mounted || category != _selected) return;

      _cache.save(category, result.movies);

      setState(() {
        _movies.addAll(result.movies);
        _hasMore = result.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      // Gagal dari internet: coba pakai data tersimpan
      final cached = await _cache.load(category);
      if (!mounted || category != _selected) return;

      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _movies.addAll(cached);
          _hasMore = false; // data tersimpan hanya halaman pertama
          _isOffline = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _error != null) return;

    final category = _selected;
    setState(() => _isLoadingMore = true);

    try {
      final result = await _service.fetchMovies(category, page: _page + 1);
      if (!mounted || category != _selected) return;
      setState(() {
        _page += 1;
        _movies.addAll(result.movies);
        _hasMore = result.hasMore;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted || category != _selected) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat halaman berikutnya')),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const MovieGridSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Terjadi kesalahan:\n$_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFirstPage,

                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_isOffline)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Mode offline: menampilkan data tersimpan'),
                ),
                TextButton(
                  onPressed: _loadFirstPage,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemCount: _movies.length,
            itemBuilder: (context, index) => MovieCard(movie: _movies[index]),
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Film'),
        actions: [
          IconButton(
            tooltip: 'Tentang',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Katalog Film',
              applicationVersion: '1.0.0',
              children: const [
                Text('Proyek belajar Flutter.'),
                SizedBox(height: 12),
                Text(
                  'This product uses the TMDB API but is not endorsed or '
                  'certified by TMDB.',
                ),
              ],
            ),
          ),
          const ThemeToggleButton(),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: MovieCategory.values
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category.label),
                        selected: category == _selected,
                        onSelected: (_) => _selectCategory(category),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
