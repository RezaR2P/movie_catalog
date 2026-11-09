class Movie {
  final int id;
  final String title;
  final double rating;
  final int year;
  final String overview;
  final String posterUrl;

  const Movie({
    required this.id,
    required this.title,
    required this.rating,
    required this.year,
    required this.overview,
    required this.posterUrl,
  });

  // Dari JSON TMDB
  factory Movie.fromJson(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final releaseDate = json['release_date'] as String? ?? '';

    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '-',
      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      year: releaseDate.length >= 4
          ? int.tryParse(releaseDate.substring(0, 4)) ?? 0
          : 0,
      overview: json['overview'] as String? ?? '',
      posterUrl: posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : '',
    );
  }

  // Untuk disimpan di HP
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'rating': rating,
    'year': year,
    'overview': overview,
    'posterUrl': posterUrl,
  };

  // Dari data yang tersimpan di HP
  factory Movie.fromMap(Map<String, dynamic> map) => Movie(
    id: map['id'] as int,
    title: map['title'] as String,
    rating: (map['rating'] as num).toDouble(),
    year: map['year'] as int,
    overview: map['overview'] as String,
    posterUrl: map['posterUrl'] as String,
  );
}
