import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Exception khusus untuk menangani berbagai kegagalan permintaan API.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Service jaringan (Networking Layer) yang melakukan HTTP GET
/// ke Open-Meteo Weather Forecast API dan Geocoding API.
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Mengambil data cuaca terkini, per jam, dan prakiraan 7 hari ke depan
  /// dari Open-Meteo Forecast API berdasarkan koordinat lintang dan bujur.
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
    int forecastDays = 7,
  }) async {
    final uri = Uri.parse(ApiConstants.weatherBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': ApiConstants.currentFields.join(','),
        'hourly': ApiConstants.hourlyFields.join(','),
        'daily': ApiConstants.dailyFields.join(','),
        'timezone': 'auto',
        'forecast_days': forecastDays.toString(),
      },
    );

    final jsonMap = await _getJson(uri);
    return WeatherModel.fromJson(jsonMap);
  }

  /// Mencari daftar lokasi/kota berdasarkan nama melalui Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchLocations(
    String query, {
    int count = 15,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.parse(ApiConstants.geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': count.toString(),
        'language': 'id',
        'format': 'json',
      },
    );

    final jsonMap = await _getJson(uri);
    final rawResults = jsonMap['results'] as List<dynamic>?;
    if (rawResults == null || rawResults.isEmpty) {
      return const [];
    }

    return rawResults
        .whereType<Map<String, dynamic>>()
        .map(LocationModel.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'Server mengembalikan kode status ${response.statusCode}. Silakan coba lagi.',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException('Format respons dari server tidak valid.');
      }

      if (decoded['error'] == true) {
        final reason = decoded['reason']?.toString() ??
            'Permintaan ditolak oleh Open-Meteo API.';
        throw ApiException(reason);
      }

      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'Koneksi ke server Open-Meteo melebihi batas waktu. Periksa jaringan Anda.',
      );
    } on SocketException {
      throw const ApiException(
        'Tidak ada koneksi internet. Pastikan perangkat terhubung ke jaringan.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Gagal menghubungi server cuaca. Periksa koneksi internet Anda.',
      );
    } on FormatException catch (e) {
      throw ApiException('Gagal memproses data cuaca: ${e.message}');
    }
  }

  void dispose() {
    _client.close();
  }
}
