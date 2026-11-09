class MovieDetail {
  final int runtime; // dalam menit
  final List<String> genres;

  const MovieDetail({required this.runtime, required this.genres});

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final genreList = json['genres'] as List<dynamic>? ?? [];

    return MovieDetail(
      runtime: json['runtime'] as int? ?? 0,
      genres: genreList
          .map((g) => (g as Map<String, dynamic>)['name'] as String)
          .toList(),
    );
  }
}
