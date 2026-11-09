# Katalog Film

Aplikasi katalog film Flutter yang mengambil data dari TMDB API.
Dibuat sebagai proyek belajar Flutter dari nol.

## Fitur

- Daftar film per kategori (Popular, Top Rated, Now Playing) dengan infinite scroll
- Detail film: poster, rating, genre, durasi, sinopsis
- Pencarian dengan debounce
- Favorit yang tersimpan di perangkat
- Tema terang dan gelap
- Mode offline (data dan poster tersimpan)
- Animasi Hero dan loading shimmer

## Teknologi

Flutter, Dart, Riverpod, http, shared_preferences, cached_network_image, shimmer

## Cara menjalankan

1. Daftar dan ambil API key (v3) di https://www.themoviedb.org/settings/api
2. Salin `env.example.json` menjadi `env.json`, lalu isi API key Anda
3. Jalankan:
   ```bash
   flutter pub get
   flutter run --dart-define-from-file=env.json
   ```

## Struktur

- `lib/models` : bentuk data
- `lib/services` : akses API dan cache
- `lib/providers` : state management (Riverpod)
- `lib/screens` : halaman
- `lib/widgets` : komponen yang dipakai ulang

## Atribusi

This product uses the TMDB API but is not endorsed or certified by TMDB.
