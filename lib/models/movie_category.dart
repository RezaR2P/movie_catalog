enum MovieCategory {
  popular('Popular', 'popular'),
  topRated('Top Rated', 'top_rated'),
  nowPlaying('Now Playing', 'now_playing');

  final String label; // teks di tab
  final String path; // bagian alamat API

  const MovieCategory(this.label, this.path);
}
