import 'package:flutter/material.dart';

import '../core/constants/api_constants.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../repositories/weather_repository.dart';

/// Status tampilan data cuaca untuk menangani kondisi loading, berhasil, kosong, dan error.
enum WeatherUiStatus { initial, loading, loaded, empty, error }

/// ViewModel utama untuk Home / Weather Screen (mengikuti pola MVVM dengan Provider).
/// Bertanggung jawab memuat data cuaca, mengelola lokasi aktif, daftar favorit,
/// riwayat pencarian, cache preview cuaca favorit (dari API live), serta preferensi tema & unit.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({required this._repository});

  final WeatherRepository _repository;

  WeatherUiStatus _status = WeatherUiStatus.initial;
  WeatherModel? _weather;
  LocationModel _selectedLocation = ApiConstants.defaultLocation;
  List<LocationModel> _favorites = const [];
  List<LocationModel> _searchHistory = const [];
  final Map<int, WeatherModel> _weatherCache = {};
  int _selectedHourIndex = 0;
  String? _errorMessage;
  bool _isRefreshing = false;
  bool _isFahrenheit = false;
  ThemeMode _themeMode = ThemeMode.light;

  WeatherUiStatus get status => _status;
  WeatherModel? get weather => _weather;
  LocationModel get selectedLocation => _selectedLocation;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get searchHistory => List.unmodifiable(_searchHistory);
  int get selectedHourIndex => _selectedHourIndex;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;
  bool get isFahrenheit => _isFahrenheit;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool isFavorite(LocationModel location) {
    return _favorites.any((item) => item == location);
  }

  WeatherModel? getCachedWeather(LocationModel location) {
    return _weatherCache[location.id];
  }

  void selectHour(int index) {
    if (_selectedHourIndex == index) return;
    _selectedHourIndex = index;
    notifyListeners();
  }

  /// Inisialisasi data tersimpan dari Local Storage saat aplikasi pertama dibuka,
  /// kemudian langsung mengambil data cuaca terkini dari Open-Meteo API.
  Future<void> initialize() async {
    _status = WeatherUiStatus.loading;
    notifyListeners();

    final savedLocation = await _repository.loadSelectedLocation();
    _favorites = await _repository.loadFavorites();
    _searchHistory = await _repository.loadSearchHistory();
    _isFahrenheit = await _repository.loadIsFahrenheit();
    final savedDarkMode = await _repository.loadIsDarkMode();
    if (savedDarkMode != null) {
      _themeMode = savedDarkMode ? ThemeMode.dark : ThemeMode.light;
    }

    if (savedLocation != null) {
      _selectedLocation = savedLocation;
    } else if (_favorites.isNotEmpty) {
      _selectedLocation = _favorites.first;
    } else {
      _selectedLocation = ApiConstants.defaultLocation;
    }

    await fetchWeatherForSelectedLocation();
  }

  /// Memilih kota baru, menyimpannya ke Local Storage (lokasi aktif & riwayat),
  /// lalu memuat cuaca terbaru dari API.
  Future<void> selectLocation(
    LocationModel location, {
    bool recordHistory = true,
  }) async {
    _selectedLocation = location;
    _selectedHourIndex = 0;
    await _repository.persistSelectedLocation(location);

    if (recordHistory) {
      await addToSearchHistory(location);
    }

    await fetchWeatherForSelectedLocation();
  }

  /// Mengambil data cuaca terkini & prakiraan harian dari Open-Meteo API.
  Future<void> fetchWeatherForSelectedLocation({
    bool isRefresh = false,
  }) async {
    if (isRefresh && _weather != null) {
      _isRefreshing = true;
    } else {
      _status = WeatherUiStatus.loading;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getWeatherForLocation(_selectedLocation);
      _weatherCache[_selectedLocation.id] = result;
      _selectedHourIndex = 0;

      if (result.dailyForecasts.isEmpty) {
        _weather = result;
        _status = WeatherUiStatus.empty;
      } else {
        _weather = result;
        _status = WeatherUiStatus.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (!isRefresh || _weather == null) {
        _status = WeatherUiStatus.error;
      }
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Memuat preview cuaca terkini (real-time dari Open-Meteo API) untuk kota favorit
  /// yang belum ada di cache agar daftar Lokasi Tersimpan menampilkan suhu & kondisi terkini.
  Future<void> prefetchFavoritesWeather() async {
    final missing =
        _favorites.where((city) => !_weatherCache.containsKey(city.id)).toList();
    if (missing.isEmpty) return;

    await Future.wait(
      missing.map((city) async {
        try {
          final data = await _repository.getWeatherForLocation(city);
          _weatherCache[city.id] = data;
        } catch (_) {
          // Abaikan kegagalan prefetch individual agar tidak mengganggu daftar favorit.
        }
      }),
    );
    notifyListeners();
  }

  /// Menambah atau menghapus lokasi dari daftar favorit dan menyimpannya ke Local Storage.
  Future<bool> toggleFavorite(LocationModel location) async {
    final updated = List<LocationModel>.from(_favorites);
    final existingIndex = updated.indexWhere((item) => item == location);
    late final bool added;

    if (existingIndex >= 0) {
      updated.removeAt(existingIndex);
      added = false;
    } else {
      updated.insert(0, location);
      added = true;
    }

    _favorites = updated;
    notifyListeners();
    await _repository.persistFavorites(_favorites);
    return added;
  }

  /// Menambahkan lokasi yang dipilih ke riwayat pencarian (maksimal 10 terbaru).
  Future<void> addToSearchHistory(LocationModel location) async {
    final updated = List<LocationModel>.from(_searchHistory)
      ..removeWhere((item) => item == location)
      ..insert(0, location);

    _searchHistory = updated.take(10).toList();
    notifyListeners();
    await _repository.persistSearchHistory(_searchHistory);
  }

  /// Menghapus satu item dari riwayat pencarian.
  Future<void> removeFromSearchHistory(LocationModel location) async {
    _searchHistory =
        _searchHistory.where((item) => item != location).toList();
    notifyListeners();
    await _repository.persistSearchHistory(_searchHistory);
  }

  /// Mengosongkan seluruh riwayat pencarian.
  Future<void> clearSearchHistory() async {
    _searchHistory = const [];
    notifyListeners();
    await _repository.persistSearchHistory(_searchHistory);
  }

  /// Mengubah satuan suhu antara Celsius (°C) dan Fahrenheit (°F).
  Future<void> toggleTemperatureUnit() async {
    _isFahrenheit = !_isFahrenheit;
    notifyListeners();
    await _repository.persistIsFahrenheit(_isFahrenheit);
  }

  /// Mengubah tema aplikasi antara Light Mode dan Dark Mode.
  Future<void> toggleThemeMode() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _repository.persistIsDarkMode(isDarkMode);
  }
}
