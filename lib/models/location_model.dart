/// Model data lokasi hasil pencarian Open-Meteo Geocoding API
/// sekaligus digunakan untuk penyimpanan Lokal (Favorit & Riwayat Pencarian).
class LocationModel {
  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country = '',
    this.countryCode = '',
    this.admin1 = '',
    this.admin2 = '',
    this.timezone = 'auto',
    this.population,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String admin1;
  final String admin2;
  final String timezone;
  final int? population;

  /// Membentuk subtitle lokasi yang mudah dibaca, misalnya "Jawa Tengah, Indonesia".
  String get subtitle {
    final parts = <String>[];
    if (admin1.isNotEmpty && admin1.toLowerCase() != name.toLowerCase()) {
      parts.add(admin1);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    return parts.join(', ');
  }

  /// Menampilkan koordinat dalam format singkat untuk informasi tambahan.
  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ??
          Object.hash(json['name'], json['latitude'], json['longitude']),
      name: (json['name'] as String?)?.trim() ?? 'Lokasi Tidak Dikenal',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: (json['country'] as String?) ?? '',
      countryCode: (json['country_code'] as String?) ?? '',
      admin1: (json['admin1'] as String?) ?? '',
      admin2: (json['admin2'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? 'auto',
      population: (json['population'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'admin2': admin2,
      'timezone': timezone,
      'population': population,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.id == id &&
        (other.latitude - latitude).abs() < 0.001 &&
        (other.longitude - longitude).abs() < 0.001;
  }

  @override
  int get hashCode => Object.hash(id, latitude.toStringAsFixed(3), longitude.toStringAsFixed(3));
}
