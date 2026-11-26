import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service penyimpanan lokal menggunakan SharedPreferences
/// untuk menyimpan lokasi favorit, riwayat pencarian, lokasi aktif,
/// dan preferensi tampilan pengguna secara persisten.
class LocalStorageService {
  LocalStorageService({SharedPreferences? preferences})
      : _prefsInstance = preferences;

  static const String _favoritesKey = 'skycast_favorite_locations_v1';
  static const String _historyKey = 'skycast_search_history_v1';
  static const String _selectedLocationKey = 'skycast_selected_location_v1';
  static const String _isFahrenheitKey = 'skycast_is_fahrenheit_v1';
  static const String _isDarkModeKey = 'skycast_is_dark_mode_v1';
  static const int maxHistoryItems = 10;

  SharedPreferences? _prefsInstance;

  Future<SharedPreferences> get _prefs async =>
      _prefsInstance ??= await SharedPreferences.getInstance();

  Future<List<LocationModel>> getFavoriteLocations() async {
    final prefs = await _prefs;
    return _decodeLocationList(prefs.getString(_favoritesKey));
  }

  Future<void> saveFavoriteLocations(List<LocationModel> locations) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(locations.map((e) => e.toJson()).toList());
    await prefs.setString(_favoritesKey, encoded);
  }

  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await _prefs;
    return _decodeLocationList(prefs.getString(_historyKey));
  }

  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await _prefs;
    final trimmed = history.take(maxHistoryItems).toList();
    final encoded = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<LocationModel?> getSelectedLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_selectedLocationKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return LocationModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSelectedLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(_selectedLocationKey, jsonEncode(location.toJson()));
  }

  Future<bool> getIsFahrenheit() async {
    final prefs = await _prefs;
    return prefs.getBool(_isFahrenheitKey) ?? false;
  }

  Future<void> saveIsFahrenheit(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_isFahrenheitKey, value);
  }

  Future<bool?> getIsDarkMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_isDarkModeKey);
  }

  Future<void> saveIsDarkMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_isDarkModeKey, value);
  }

  List<LocationModel> _decodeLocationList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
