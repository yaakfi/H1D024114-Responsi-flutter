import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/models/location_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/repositories/weather_repository.dart';
import 'package:weather_app/services/local_storage_service.dart';
import 'package:weather_app/services/weather_api_service.dart';
import 'package:weather_app/viewmodels/search_viewmodel.dart';
import 'package:weather_app/viewmodels/weather_viewmodel.dart';

Map<String, dynamic> _sampleWeatherJson({
  double temp = 28.4,
  int humidity = 78,
  double apparent = 31.2,
  double precipitation = 0.6,
  int weatherCode = 61,
  double windSpeed = 12.5,
}) {
  return {
    'latitude': -7.42,
    'longitude': 109.24,
    'timezone': 'Asia/Jakarta',
    'timezone_abbreviation': 'GMT+7',
    'current': {
      'time': '2026-11-25T14:00',
      'temperature_2m': temp,
      'relative_humidity_2m': humidity,
      'apparent_temperature': apparent,
      'is_day': 1,
      'precipitation': precipitation,
      'weather_code': weatherCode,
      'wind_speed_10m': windSpeed,
      'wind_direction_10m': 135,
      'surface_pressure': 1008.2,
    },
    'hourly': {
      'time': [
        '2026-11-25T14:00',
        '2026-11-25T15:00',
        '2026-11-25T16:00',
      ],
      'temperature_2m': [28.4, 27.9, 26.8],
      'weather_code': [61, 80, 3],
      'precipitation_probability': [80, 65, 40],
      'is_day': [1, 1, 1],
    },
    'daily': {
      'time': [
        '2026-11-25',
        '2026-11-26',
        '2026-11-27',
      ],
      'weather_code': [61, 95, 2],
      'temperature_2m_max': [31.0, 30.2, 32.1],
      'temperature_2m_min': [23.4, 22.9, 23.8],
      'precipitation_probability_max': [85, 90, 35],
      'sunrise': [
        '2026-11-25T05:15',
        '2026-11-26T05:15',
        '2026-11-27T05:16',
      ],
      'sunset': [
        '2026-11-25T17:44',
        '2026-11-26T17:45',
        '2026-11-27T17:45',
      ],
      'uv_index_max': [8.2, 7.1, 9.0],
    },
  };
}

Map<String, dynamic> _sampleGeocodingJson() {
  return {
    'results': [
      {
        'id': 1650357,
        'name': 'Bandung',
        'latitude': -6.92222,
        'longitude': 107.60694,
        'country': 'Indonesia',
        'country_code': 'ID',
        'admin1': 'Jawa Barat',
        'timezone': 'Asia/Jakarta',
      },
      {
        'id': 1642911,
        'name': 'Jakarta',
        'latitude': -6.21462,
        'longitude': 106.84513,
        'country': 'Indonesia',
        'country_code': 'ID',
        'admin1': 'Daerah Khusus Ibukota Jakarta',
        'timezone': 'Asia/Jakarta',
      },
    ],
  };
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Model & API Service Tests', () {
    test('WeatherModel mem-parsing seluruh field wajib Open-Meteo dengan tepat', () {
      final model = WeatherModel.fromJson(_sampleWeatherJson());

      expect(model.current.temperature, 28.4);
      expect(model.current.relativeHumidity, 78);
      expect(model.current.apparentTemperature, 31.2);
      expect(model.current.precipitation, 0.6);
      expect(model.current.weatherCode, 61);
      expect(model.current.windSpeed, 12.5);
      expect(model.dailyForecasts.length, 3);
      expect(model.dailyForecasts.first.temperatureMax, 31.0);
      expect(model.dailyForecasts.first.temperatureMin, 23.4);
      expect(model.dailyForecasts.first.precipitationProbabilityMax, 85);
    });

    test('WeatherApiService mengirim HTTP GET dengan parameter Open-Meteo yang sesuai', () async {
      Uri? capturedUri;
      String? capturedMethod;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedMethod = request.method;
        return http.Response(jsonEncode(_sampleWeatherJson()), 200);
      });

      final api = WeatherApiService(client: mockClient);
      final weather = await api.fetchWeather(latitude: -7.42, longitude: 109.24);

      expect(capturedMethod, 'GET');
      expect(capturedUri?.host, 'api.open-meteo.com');
      expect(capturedUri?.queryParameters['latitude'], '-7.42');
      expect(capturedUri?.queryParameters['longitude'], '109.24');
      expect(capturedUri?.queryParameters['timezone'], 'auto');
      expect(
        capturedUri?.queryParameters['current'],
        contains('temperature_2m'),
      );
      expect(
        capturedUri?.queryParameters['daily'],
        contains('precipitation_probability_max'),
      );
      expect(weather.current.temperature, 28.4);
    });

    test('WeatherApiService menangani error HTTP status non-200', () async {
      final mockClient = MockClient((_) async => http.Response('Error', 503));
      final api = WeatherApiService(client: mockClient);

      expect(
        () => api.fetchWeather(latitude: -7.42, longitude: 109.24),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('LocalStorage & ViewModel MVVM Tests', () {
    test('Favorit dan riwayat pencarian tersimpan persisten di SharedPreferences', () async {
      final storage = LocalStorageService();
      const bandung = LocationModel(
        id: 1650357,
        name: 'Bandung',
        latitude: -6.92222,
        longitude: 107.60694,
        country: 'Indonesia',
        admin1: 'Jawa Barat',
      );

      final api = WeatherApiService(
        client: MockClient((_) async => http.Response(jsonEncode(_sampleWeatherJson()), 200)),
      );
      final repo = WeatherRepository(apiService: api, storageService: storage);

      final vm1 = WeatherViewModel(repository: repo);
      await vm1.initialize();
      await vm1.toggleFavorite(bandung);
      await vm1.selectLocation(bandung);

      // Simulasi membuka ulang aplikasi dengan ViewModel baru
      final vm2 = WeatherViewModel(repository: repo);
      await vm2.initialize();

      expect(vm2.selectedLocation.name, 'Bandung');
      expect(vm2.favorites.length, 1);
      expect(vm2.favorites.first.name, 'Bandung');
      expect(vm2.searchHistory.first.name, 'Bandung');
    });

    test('SearchViewModel menangani hasil pencarian dan hasil kosong dari Geocoding API', () async {
      final mockClient = MockClient((request) async {
        final name = request.url.queryParameters['name'];
        if (name == 'Bandung') {
          return http.Response(jsonEncode(_sampleGeocodingJson()), 200);
        }
        return http.Response(jsonEncode({'generationtime_ms': 0.1}), 200);
      });

      final repo = WeatherRepository(
        apiService: WeatherApiService(client: mockClient),
        storageService: LocalStorageService(),
      );
      final searchVm = SearchViewModel(repository: repo);

      await searchVm.searchNow('Bandung');
      expect(searchVm.status, SearchUiStatus.loaded);
      expect(searchVm.results.length, 2);

      await searchVm.searchNow('KotaTidakAdaXYZ');
      expect(searchVm.status, SearchUiStatus.empty);
      expect(searchVm.results, isEmpty);
    });
  });

  group('Widget Integration Tests (Home & Search Screen)', () {
    testWidgets('Menampilkan cuaca terkini, mencari kota, dan memilih hasil pencarian', (tester) async {
      final mockClient = MockClient((request) async {
        if (request.url.host == 'geocoding-api.open-meteo.com') {
          return http.Response(jsonEncode(_sampleGeocodingJson()), 200);
        }
        final lat = request.url.queryParameters['latitude'];
        if (lat != null && lat.startsWith('-6.92')) {
          return http.Response(
            jsonEncode(_sampleWeatherJson(temp: 22.1, humidity: 82)),
            200,
          );
        }
        return http.Response(jsonEncode(_sampleWeatherJson()), 200);
      });

      final repo = WeatherRepository(
        apiService: WeatherApiService(client: mockClient),
        storageService: LocalStorageService(),
      );

      await tester.pumpWidget(SkyCastApp(repository: repo));
      await tester.pumpAndSettle();

      // Verifikasi Home / Weather Screen
      expect(find.text('Purwokerto'), findsAtLeastNWidgets(1));
      expect(find.text('28°'), findsAtLeastNWidgets(1));
      expect(find.text('78%'), findsOneWidget);
      expect(find.text('12.5 km/j'), findsOneWidget);

      // Navigasi ke Search / Location Screen
      await tester.tap(find.byTooltip('Cari Kota & Favorit'));
      await tester.pumpAndSettle();

      expect(find.text('Lokasi & Favorit'), findsOneWidget);

      // Cari kota "Bandung"
      await tester.enterText(find.byType(TextField), 'Bandung');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Bandung'), findsAtLeastNWidgets(2));

      // Simpan Bandung sebagai favorit dan pilih Bandung
      await tester.tap(find.byTooltip('Simpan favorit').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bandung').last);
      await tester.pumpAndSettle();

      // Verifikasi Home Screen diperbarui ke kota Bandung
      expect(find.text('Bandung'), findsAtLeastNWidgets(1));
      expect(find.text('22°'), findsAtLeastNWidgets(1));
    });

    testWidgets('Menampilkan tampilan error dan tombol Coba Lagi saat API gagal', (tester) async {
      var shouldFail = true;
      final mockClient = MockClient((_) async {
        if (shouldFail) {
          return http.Response('Service Unavailable', 503);
        }
        return http.Response(jsonEncode(_sampleWeatherJson()), 200);
      });

      final repo = WeatherRepository(
        apiService: WeatherApiService(client: mockClient),
        storageService: LocalStorageService(),
      );

      await tester.pumpWidget(SkyCastApp(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Gagal Memuat Data'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Simulasi jaringan pulih lalu ketuk Coba Lagi
      shouldFail = false;
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('28°'), findsAtLeastNWidgets(1));
    });
  });
}
