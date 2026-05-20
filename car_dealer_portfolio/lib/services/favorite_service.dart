import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  FavoriteService._();

  static const String _favoritesKey = 'favorite_car_ids';

  static final ValueNotifier<Set<String>> favoriteIds = ValueNotifier<Set<String>>({});

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_favoritesKey) ?? <String>[];

    favoriteIds.value = savedIds.toSet();
    _isInitialized = true;
  }

  static bool isFavorite(String carId) {
    return favoriteIds.value.contains(carId);
  }

  static Future<void> toggleFavorite(String carId) async {
    await init();

    final updatedIds = Set<String>.from(favoriteIds.value);

    if (updatedIds.contains(carId)) {
      updatedIds.remove(carId);
    } else {
      updatedIds.add(carId);
    }

    favoriteIds.value = updatedIds;
    await _save();
  }

  static Future<void> removeFavorite(String carId) async {
    await init();

    final updatedIds = Set<String>.from(favoriteIds.value)..remove(carId);
    favoriteIds.value = updatedIds;
    await _save();
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteIds.value.toList());
  }
}
