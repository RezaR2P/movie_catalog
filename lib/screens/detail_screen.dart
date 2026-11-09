import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/movie_detail.dart';
import '../providers/favorites_notifier.dart';
import '../services/tmdb_service.dart';

import 'package:cached_network_image/cached_network_image.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Movie movie;
  final Object heroTag;

  const DetailScreen({super.key, required this.movie, required this.heroTag});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late Future<MovieDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = TmdbService().fetchMovieDetail(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final isFavorite = ref.watch(
      favoritesProvider.select((list) => list.any((m) => m.id == movie.id)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.redAccent : null,
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(movie),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.heroTag,
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: double.infinity,
                height: 360,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const SizedBox(
                  height: 360,
                  child: Center(child: Icon(Icons.broken_image, size: 48)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('⭐ ${movie.rating.toStringAsFixed(1)} · ${movie.year}'),
                  const SizedBox(height: 12),
                  FutureBuilder<MovieDetail>(
                    future: _detailFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final detail = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (detail.runtime > 0)
                            Text('${detail.runtime} menit'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: detail.genres
                                .map((genre) => Chip(label: Text(genre)))
                                .toList(),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sinopsis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.overview.isEmpty
                        ? 'Sinopsis belum tersedia.'
                        : movie.overview,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
