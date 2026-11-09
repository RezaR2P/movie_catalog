import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_notifier.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Saya')),
      body: favorites.isEmpty
          ? const Center(child: Text('Belum ada film favorit'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.55,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) =>
                  MovieCard(movie: favorites[index]),
            ),
    );
  }
}
