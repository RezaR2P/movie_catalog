import 'movie.dart';

class MoviePage {
  final List<Movie> movies;
  final int page;
  final int totalPages;

  const MoviePage({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
