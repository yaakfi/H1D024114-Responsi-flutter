import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

/// Repository yang menghubungkan sumber data jarak jauh (Open-Meteo API)
/// dan penyimpanan lokal (SharedPreferences) untuk dikonsumsi oleh ViewModel.
class WeatherRepository {
  WeatherRepository({
    required this._apiService,
    required this._storageService,
  });

  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  Future<WeatherModel> getWeatherForLocation(LocationModel location) {
    return _apiService.fetchWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  Future<List<LocationModel>> searchCities(String query) {
    return _apiService.searchLocations(query);
  }

  Future<LocationModel?> loadSelectedLocation() =>
      _storageService.getSelectedLocation();

  Future<void> persistSelectedLocation(LocationModel location) =>
      _storageService.saveSelectedLocation(location);

  Future<List<LocationModel>> loadFavorites() =>
      _storageService.getFavoriteLocations();

  Future<void> persistFavorites(List<LocationModel> favorites) =>
      _storageService.saveFavoriteLocations(favorites);

  Future<List<LocationModel>> loadSearchHistory() =>
      _storageService.getSearchHistory();

  Future<void> persistSearchHistory(List<LocationModel> history) =>
      _storageService.saveSearchHistory(history);

  Future<bool> loadIsFahrenheit() => _storageService.getIsFahrenheit();

  Future<void> persistIsFahrenheit(bool value) =>
      _storageService.saveIsFahrenheit(value);

  Future<bool?> loadIsDarkMode() => _storageService.getIsDarkMode();

  Future<void> persistIsDarkMode(bool value) =>
      _storageService.saveIsDarkMode(value);
}
