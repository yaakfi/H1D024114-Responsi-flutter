import 'package:flutter/material.dart';

/// Kategori atmosfer langit untuk gradien latar belakang adaptif.
enum WeatherSkyType { clear, cloudy, rain }

/// Jenis ikon outline minimalis untuk dirender oleh `WeatherOutlineIcon`.
enum WeatherIconKind {
  clear,
  partly,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  storm,
}

/// Informasi visual dan deskripsi kondisi cuaca berdasarkan kode WMO Open-Meteo.
class WeatherCodeInfo {
  const WeatherCodeInfo({
    required this.code,
    required this.label,
    required this.description,
    required this.icon,
    required this.iconKind,
    required this.skyType,
    this.isWarning = false,
  });

  final int code;
  final String label;
  final String description;
  final IconData icon;
  final WeatherIconKind iconKind;
  final WeatherSkyType skyType;
  final bool isWarning;
}

/// Helper untuk memetakan `weather_code` (WMO) dari Open-Meteo
/// menjadi label bahasa Indonesia, tipe ikon outline minimalis, dan atmosfer langit.
class WeatherCodeHelper {
  WeatherCodeHelper._();

  static WeatherCodeInfo fromCode(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return WeatherCodeInfo(
          code: code,
          label: 'Cerah',
          description: isDay
              ? 'Langit cerah dengan sinar matahari optimal sepanjang hari.'
              : 'Langit malam cerah tanpa awan.',
          icon: isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
          iconKind: WeatherIconKind.clear,
          skyType: WeatherSkyType.clear,
        );
      case 1:
        return WeatherCodeInfo(
          code: code,
          label: 'Cerah Berawan',
          description: 'Sebagian besar langit cerah, cocok untuk aktivitas luar ruang.',
          icon: isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
          iconKind: WeatherIconKind.partly,
          skyType: WeatherSkyType.clear,
        );
      case 2:
        return const WeatherCodeInfo(
          code: 2,
          label: 'Berawan Sebagian',
          description: 'Awan tersebar di sebagian wilayah langit dengan suhu nyaman.',
          icon: Icons.cloud_queue_rounded,
          iconKind: WeatherIconKind.partly,
          skyType: WeatherSkyType.cloudy,
        );
      case 3:
        return const WeatherCodeInfo(
          code: 3,
          label: 'Mendung',
          description: 'Langit tertutup awan tebal dan udara terasa lebih teduh.',
          icon: Icons.cloud_outlined,
          iconKind: WeatherIconKind.cloudy,
          skyType: WeatherSkyType.cloudy,
        );
      case 45:
      case 48:
        return WeatherCodeInfo(
          code: code,
          label: code == 48 ? 'Kabut Embun Beku' : 'Berkabut',
          description: 'Jarak pandang berkurang karena kabut tipis di sekitar area.',
          icon: Icons.foggy,
          iconKind: WeatherIconKind.fog,
          skyType: WeatherSkyType.cloudy,
        );
      case 51:
      case 53:
      case 55:
        return WeatherCodeInfo(
          code: code,
          label: code == 51
              ? 'Gerimis Ringan'
              : code == 53
                  ? 'Gerimis Sedang'
                  : 'Gerimis Lebat',
          description: 'Hujan gerimis halus, siapkan payung bila beraktivitas di luar.',
          icon: Icons.grain_rounded,
          iconKind: WeatherIconKind.drizzle,
          skyType: WeatherSkyType.rain,
        );
      case 56:
      case 57:
        return WeatherCodeInfo(
          code: code,
          label: 'Gerimis Beku',
          description: 'Gerimis dingin dengan suhu rendah, gunakan pakaian hangat.',
          icon: Icons.ac_unit_rounded,
          iconKind: WeatherIconKind.drizzle,
          skyType: WeatherSkyType.rain,
        );
      case 61:
      case 63:
      case 65:
        return WeatherCodeInfo(
          code: code,
          label: code == 61
              ? 'Hujan Ringan'
              : code == 63
                  ? 'Hujan Sedang'
                  : 'Hujan Lebat',
          description: 'Curah hujan terdeteksi, bawa payung atau jas hujan saat keluar.',
          icon: Icons.water_drop_outlined,
          iconKind: WeatherIconKind.rain,
          skyType: WeatherSkyType.rain,
          isWarning: code == 65,
        );
      case 66:
      case 67:
        return WeatherCodeInfo(
          code: code,
          label: 'Hujan Beku',
          description: 'Hujan sangat dingin, berhati-hati saat berkendara.',
          icon: Icons.cloudy_snowing,
          iconKind: WeatherIconKind.rain,
          skyType: WeatherSkyType.rain,
          isWarning: true,
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return WeatherCodeInfo(
          code: code,
          label: code == 75 ? 'Salju Lebat' : 'Salju',
          description: 'Turun salju di area sekitar dengan suhu rendah.',
          icon: Icons.snowing,
          iconKind: WeatherIconKind.snow,
          skyType: WeatherSkyType.cloudy,
        );
      case 80:
      case 81:
      case 82:
        return WeatherCodeInfo(
          code: code,
          label: code == 80
              ? 'Hujan Lokal Ringan'
              : code == 81
                  ? 'Hujan Lokal Sedang'
                  : 'Hujan Deras',
          description: 'Hujan bersifat lokal dapat turun sewaktu-waktu.',
          icon: Icons.umbrella_outlined,
          iconKind: WeatherIconKind.rain,
          skyType: WeatherSkyType.rain,
          isWarning: code == 82,
        );
      case 85:
      case 86:
        return WeatherCodeInfo(
          code: code,
          label: 'Hujan Salju',
          description: 'Hujan salju turun secara berkala.',
          icon: Icons.ac_unit_rounded,
          iconKind: WeatherIconKind.snow,
          skyType: WeatherSkyType.cloudy,
        );
      case 95:
      case 96:
      case 99:
        return WeatherCodeInfo(
          code: code,
          label: code == 95 ? 'Badai Petir' : 'Badai Petir & Hujan Es',
          description: 'Potensi petir dan angin kencang, hindari area terbuka.',
          icon: Icons.thunderstorm_outlined,
          iconKind: WeatherIconKind.storm,
          skyType: WeatherSkyType.rain,
          isWarning: true,
        );
      default:
        return WeatherCodeInfo(
          code: code,
          label: 'Kondisi Berubah',
          description: 'Kode kondisi cuaca WMO: $code.',
          icon: Icons.wb_cloudy_outlined,
          iconKind: WeatherIconKind.cloudy,
          skyType: WeatherSkyType.cloudy,
        );
    }
  }
}
