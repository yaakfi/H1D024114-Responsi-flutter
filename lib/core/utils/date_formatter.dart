/// Helper pemformatan tanggal, hari, jam, suhu, dan arah angin dalam bahasa Indonesia.
class WeatherFormatter {
  WeatherFormatter._();

  static const List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String formatFullDate(DateTime date) {
    final dayName = _dayNames[date.weekday - 1];
    final monthName = _monthNames[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  /// Format ringkas untuk timestamp hero, misalnya: "Rabu, 25 Nov · 19:30 GMT+7".
  static String formatHeroTimestamp(
    String isoTime, {
    String timezoneAbbr = '',
  }) {
    final date = DateTime.tryParse(isoTime) ?? DateTime.now();
    final dayName = _dayNames[date.weekday - 1];
    final monthName = _monthNames[date.month - 1];
    final timeStr = formatTime(isoTime);
    final tz = timezoneAbbr == 'GMT+7'
        ? 'WIB'
        : timezoneAbbr == 'GMT+8'
            ? 'WITA'
            : timezoneAbbr == 'GMT+9'
                ? 'WIT'
                : timezoneAbbr;
    return tz.isNotEmpty
        ? '$dayName, ${date.day} $monthName · $timeStr $tz'
        : '$dayName, ${date.day} $monthName · $timeStr';
  }

  static String formatDailyLabel(DateTime date, {required int index}) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';
    return _dayNames[date.weekday - 1];
  }

  static String formatShortDate(DateTime date) {
    final monthName = _monthNames[date.month - 1];
    return '${date.day} $monthName';
  }

  static String formatTime(String isoString) {
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) {
      final parts = isoString.split('T');
      return parts.length > 1 ? parts[1] : isoString;
    }
    final h = parsed.hour.toString().padLeft(2, '0');
    final m = parsed.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String formatTemperature(
    double celsius, {
    bool isFahrenheit = false,
    int decimals = 0,
  }) {
    final value = isFahrenheit ? (celsius * 9 / 5) + 32 : celsius;
    return '${decimals == 0 ? value.round() : value.toStringAsFixed(decimals)}°';
  }

  static String formatTemperatureWithUnit(
    double celsius, {
    bool isFahrenheit = false,
  }) {
    final value = isFahrenheit ? (celsius * 9 / 5) + 32 : celsius;
    final unit = isFahrenheit ? '°F' : '°C';
    return '${value.toStringAsFixed(1)}$unit';
  }

  static String windDirectionLabel(int? degrees) {
    if (degrees == null) return '-';
    const directions = [
      'Utara',
      'Timur Laut',
      'Timur',
      'Tenggara',
      'Selatan',
      'Barat Daya',
      'Barat',
      'Barat Laut',
    ];
    final index = ((degrees % 360) / 45).round() % 8;
    return directions[index];
  }

  static String uvCategory(double uv) {
    if (uv < 3) return 'Rendah';
    if (uv < 6) return 'Sedang';
    if (uv < 8) return 'Tinggi';
    if (uv < 11) return 'Sangat Tinggi';
    return 'Ekstrem';
  }
}
