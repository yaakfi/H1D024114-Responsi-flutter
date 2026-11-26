import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../repositories/weather_repository.dart';

/// Status pencarian lokasi pada Search / Location Screen.
enum SearchUiStatus { idle, loading, loaded, empty, error }

/// ViewModel khusus untuk Search / Location Screen (pola MVVM).
/// Menangani debounce pencarian, request ke Open-Meteo Geocoding API,
/// serta status loading, hasil kosong, dan error.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required this._repository});

  final WeatherRepository _repository;

  SearchUiStatus _status = SearchUiStatus.idle;
  String _query = '';
  List<LocationModel> _results = const [];
  String? _errorMessage;
  Timer? _debounce;
  int _requestSequence = 0;

  SearchUiStatus get status => _status;
  String get query => _query;
  List<LocationModel> get results => List.unmodifiable(_results);
  String? get errorMessage => _errorMessage;

  /// Dipanggil saat teks pencarian berubah; menerapkan debounce agar hemat request API.
  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _requestSequence++;
      _results = const [];
      _errorMessage = null;
      _status = SearchUiStatus.idle;
      notifyListeners();
      return;
    }

    if (trimmed.length < 2) {
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchNow(trimmed);
    });
    notifyListeners();
  }

  /// Melakukan pencarian kota secara langsung ke Open-Meteo Geocoding API.
  Future<void> searchNow([String? overrideQuery]) async {
    _debounce?.cancel();
    final targetQuery = (overrideQuery ?? _query).trim();
    _query = targetQuery;

    if (targetQuery.isEmpty) {
      _results = const [];
      _errorMessage = null;
      _status = SearchUiStatus.idle;
      notifyListeners();
      return;
    }

    final currentRequestId = ++_requestSequence;
    _status = SearchUiStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final locations = await _repository.searchCities(targetQuery);
      // Abaikan respons usang jika pengguna sudah mengetik query baru.
      if (currentRequestId != _requestSequence) return;

      _results = locations;
      _status =
          locations.isEmpty ? SearchUiStatus.empty : SearchUiStatus.loaded;
    } catch (e) {
      if (currentRequestId != _requestSequence) return;
      _results = const [];
      _errorMessage = e.toString();
      _status = SearchUiStatus.error;
    } finally {
      if (currentRequestId == _requestSequence) {
        notifyListeners();
      }
    }
  }

  /// Membersihkan input dan hasil pencarian.
  void clearSearch() {
    _debounce?.cancel();
    _requestSequence++;
    _query = '';
    _results = const [];
    _errorMessage = null;
    _status = SearchUiStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
