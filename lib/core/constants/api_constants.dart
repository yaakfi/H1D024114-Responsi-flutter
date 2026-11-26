import '../../models/location_model.dart';

/// Konstanta konfigurasi endpoint Open-Meteo API dan nilai bawaan aplikasi.
class ApiConstants {
  ApiConstants._();

  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const Duration requestTimeout = Duration(seconds: 15);

  /// Parameter `current` sesuai ketentuan Open-Meteo Weather Forecast API.
  static const List<String> currentFields = [
    'temperature_2m',
    'relative_humidity_2m',
    'apparent_temperature',
    'is_day',
    'precipitation',
    'weather_code',
    'wind_speed_10m',
    'wind_direction_10m',
    'surface_pressure',
  ];

  /// Parameter `hourly` untuk prakiraan cuaca per jam (24 jam ke depan).
  static const List<String> hourlyFields = [
    'temperature_2m',
    'weather_code',
    'precipitation_probability',
    'is_day',
  ];

  /// Parameter `daily` sesuai ketentuan Open-Meteo Weather Forecast API.
  static const List<String> dailyFields = [
    'weather_code',
    'temperature_2m_max',
    'temperature_2m_min',
    'precipitation_probability_max',
    'sunrise',
    'sunset',
    'uv_index_max',
  ];

  /// Lokasi default awal ketika belum ada lokasi tersimpan di Local Storage.
  /// Data cuaca tetap diambil langsung dari Open-Meteo API berdasarkan koordinat ini.
  static const LocationModel defaultLocation = LocationModel(
    id: 1630328,
    name: 'Purwokerto',
    latitude: -7.4243,
    longitude: 109.2391,
    country: 'Indonesia',
    countryCode: 'ID',
    admin1: 'Jawa Tengah',
    timezone: 'Asia/Jakarta',
  );
}
