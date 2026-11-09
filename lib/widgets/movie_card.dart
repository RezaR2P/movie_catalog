import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../screens/detail_screen.dart';

import 'package:cached_network_image/cached_network_image.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  // Tanda pengenal unik milik kartu ini, dipakai untuk animasi Hero
  final Object _heroTag = Object();

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(movie: movie, heroTag: _heroTag),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: _heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: movie.posterUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text('⭐ ${movie.rating.toStringAsFixed(1)} · ${movie.year}'),
        ],
      ),
    );
  }
}
