import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';
import '../data/dummy_data.dart';

/// Main app state provider managing favorites, filtering, and search
/// This provider handles all anime-related state management
class AppStateProvider extends ChangeNotifier {
  // Favorites state
  List<Anime> _favorites = [];
  static const String _storageKey = 'favorite_anime_list';

  // Filtering state
  String _selectedGenre = "All";

  // Search state (separated by screen)
  String _homeSearchQuery = "";
  String _favoriteSearchQuery = "";

  // Getters
  List<Anime> get favorites => _favorites;
  String get selectedGenre => _selectedGenre;
  String get homeSearchQuery => _homeSearchQuery;
  String get favoriteSearchQuery => _favoriteSearchQuery;

  AppStateProvider() {
    _loadFavorites();
  }

  // ========== FAVORITES MANAGEMENT ==========

  /// Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_storageKey);

      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) {
          return Anime(
            id: item['id'],
            title: item['title'],
            imagePath: item['imagePath'],
            genre: item['genre'],
            rating: item['rating'],
            totalEpisodes: item['totalEpisodes'],
            description: item['description'],
          );
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> favoritesJson = _favorites.map((anime) {
        return {
          'id': anime.id,
          'title': anime.title,
          'imagePath': anime.imagePath,
          'genre': anime.genre,
          'rating': anime.rating,
          'totalEpisodes': anime.totalEpisodes,
          'description': anime.description,
        };
      }).toList();

      await prefs.setString(_storageKey, json.encode(favoritesJson));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  /// Check if anime is in favorites
  bool isFavorite(String animeId) {
    return _favorites.any((anime) => anime.id == animeId);
  }

  /// Toggle favorite status
  void toggleFavorite(Anime anime) {
    if (isFavorite(anime.id)) {
      removeFavorite(anime.id);
    } else {
      addFavorite(anime);
    }
  }

  /// Add anime to favorites
  void addFavorite(Anime anime) {
    if (!isFavorite(anime.id)) {
      _favorites.add(anime);
      _saveFavorites();
      notifyListeners();
    }
  }

  /// Remove anime from favorites
  void removeFavorite(String animeId) {
    _favorites.removeWhere((anime) => anime.id == animeId);
    _saveFavorites();
    notifyListeners();
  }

  /// Get favorites count
  int get favoritesCount => _favorites.length;

  // ========== GENRE FILTER ==========

  /// Set selected genre
  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  // ========== SEARCH FUNCTIONALITY ==========

  /// Set search query for HomeScreen
  void setHomeSearchQuery(String query) {
    _homeSearchQuery = query;
    notifyListeners();
  }

  /// Set search query for FavoriteScreen
  void setFavoriteSearchQuery(String query) {
    _favoriteSearchQuery = query;
    notifyListeners();
  }

  // ========== FILTERING LOGIC ==========

  /// Get filtered anime list for HomeScreen (based on genre and home search)
  List<Anime> getFilteredAnimeForHome() {
    List<Anime> result = DummyData.animeList;

    // Apply genre filter
    if (_selectedGenre != "All") {
      result = result.where((anime) {
        final genres = anime.genre.split(',').map((g) => g.trim()).toList();
        return genres.contains(_selectedGenre);
      }).toList();
    }

    // Apply home search filter (case-insensitive)
    if (_homeSearchQuery.isNotEmpty) {
      result = result.where((anime) {
        return anime.title.toLowerCase().contains(_homeSearchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  /// Get filtered favorites for FavoriteScreen (based on favorite search)
  List<Anime> getFilteredFavorites() {
    List<Anime> result = _favorites;

    // Apply favorite search filter (case-insensitive)
    if (_favoriteSearchQuery.isNotEmpty) {
      result = result.where((anime) {
        return anime.title.toLowerCase().contains(_favoriteSearchQuery.toLowerCase());
        /*searchingan kita buat lower biar gada sensitive case. homesearchquery
         itu buat apabila sesuai kondisi maka dirender di homescreen bagian
         filter anime list*/
      }).toList();
    }

    return result;
  }
}