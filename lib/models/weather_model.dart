/// Model lengkap respons cuaca dari Open-Meteo Weather Forecast API.
class WeatherModel {
  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.current,
    required this.dailyForecasts,
    required this.hourlyForecasts,
    required this.fetchedAt,
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final String timezoneAbbreviation;
  final CurrentWeatherModel current;
  final List<DailyForecastModel> dailyForecasts;
  final List<HourlyForecastModel> hourlyForecasts;
  final DateTime fetchedAt;

  /// Mengambil prakiraan hari ini (indeks pertama) jika tersedia.
  DailyForecastModel? get todayForecast =>
      dailyForecasts.isNotEmpty ? dailyForecasts.first : null;

  /// Mengambil 24 jam ke depan mulai dari jam waktu terkini lokasi.
  List<HourlyForecastModel> get next24Hours {
    if (hourlyForecasts.isEmpty) return const [];
    final currentTime = DateTime.tryParse(current.time);
    if (currentTime == null) {
      return hourlyForecasts.take(24).toList();
    }
    final startIndex = hourlyForecasts.indexWhere(
      (item) => !item.time.isBefore(
        DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          currentTime.hour,
        ),
      ),
    );
    if (startIndex == -1) return hourlyForecasts.take(24).toList();
    return hourlyForecasts.skip(startIndex).take(24).toList();
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>?;
    final dailyMap = json['daily'] as Map<String, dynamic>?;
    final hourlyMap = json['hourly'] as Map<String, dynamic>?;

    if (currentMap == null) {
      throw const FormatException('Data cuaca terkini (current) tidak tersedia.');
    }

    final dailyList = _parseDaily(dailyMap);
    final hourlyList = _parseHourly(hourlyMap);

    return WeatherModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      timezoneAbbreviation: (json['timezone_abbreviation'] as String?) ?? '',
      current: CurrentWeatherModel.fromJson(currentMap),
      dailyForecasts: dailyList,
      hourlyForecasts: hourlyList,
      fetchedAt: DateTime.now(),
    );
  }

  static List<DailyForecastModel> _parseDaily(Map<String, dynamic>? daily) {
    if (daily == null) return const [];
    final times = (daily['time'] as List<dynamic>?) ?? const [];
    final codes = (daily['weather_code'] as List<dynamic>?) ?? const [];
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final rainProbs =
        (daily['precipitation_probability_max'] as List<dynamic>?) ?? const [];
    final sunrises = (daily['sunrise'] as List<dynamic>?) ?? const [];
    final sunsets = (daily['sunset'] as List<dynamic>?) ?? const [];
    final uvIndexes = (daily['uv_index_max'] as List<dynamic>?) ?? const [];

    final count = times.length;
    return List<DailyForecastModel>.generate(count, (i) {
      return DailyForecastModel(
        date: DateTime.tryParse(times[i].toString()) ?? DateTime.now(),
        weatherCode: i < codes.length ? (codes[i] as num?)?.toInt() ?? 0 : 0,
        temperatureMax:
            i < maxTemps.length ? (maxTemps[i] as num?)?.toDouble() ?? 0 : 0,
        temperatureMin:
            i < minTemps.length ? (minTemps[i] as num?)?.toDouble() ?? 0 : 0,
        precipitationProbabilityMax:
            i < rainProbs.length ? (rainProbs[i] as num?)?.toInt() ?? 0 : 0,
        sunrise: i < sunrises.length ? sunrises[i]?.toString() : null,
        sunset: i < sunsets.length ? sunsets[i]?.toString() : null,
        uvIndexMax:
            i < uvIndexes.length ? (uvIndexes[i] as num?)?.toDouble() : null,
      );
    });
  }

  static List<HourlyForecastModel> _parseHourly(Map<String, dynamic>? hourly) {
    if (hourly == null) return const [];
    final times = (hourly['time'] as List<dynamic>?) ?? const [];
    final temps = (hourly['temperature_2m'] as List<dynamic>?) ?? const [];
    final codes = (hourly['weather_code'] as List<dynamic>?) ?? const [];
    final rainProbs =
        (hourly['precipitation_probability'] as List<dynamic>?) ?? const [];
    final isDays = (hourly['is_day'] as List<dynamic>?) ?? const [];

    final count = times.length;
    return List<HourlyForecastModel>.generate(count, (i) {
      return HourlyForecastModel(
        time: DateTime.tryParse(times[i].toString()) ?? DateTime.now(),
        temperature: i < temps.length ? (temps[i] as num?)?.toDouble() ?? 0 : 0,
        weatherCode: i < codes.length ? (codes[i] as num?)?.toInt() ?? 0 : 0,
        precipitationProbability:
            i < rainProbs.length ? (rainProbs[i] as num?)?.toInt() ?? 0 : 0,
        isDay: i < isDays.length ? ((isDays[i] as num?)?.toInt() ?? 1) == 1 : true,
      );
    });
  }
}

/// Model data cuaca terkini (`current` dari Open-Meteo).
class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.time,
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
    this.windDirection,
    this.surfacePressure,
  });

  final String time;
  final double temperature; // current.temperature_2m (°C)
  final int relativeHumidity; // current.relative_humidity_2m (%)
  final double apparentTemperature; // current.apparent_temperature (°C)
  final double precipitation; // current.precipitation (mm)
  final int weatherCode; // current.weather_code (WMO)
  final double windSpeed; // current.wind_speed_10m (km/h)
  final bool isDay; // current.is_day (1 = siang, 0 = malam)
  final int? windDirection; // current.wind_direction_10m (°)
  final double? surfacePressure; // current.surface_pressure (hPa)

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      time: (json['time'] as String?) ?? '',
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      isDay: ((json['is_day'] as num?)?.toInt() ?? 1) == 1,
      windDirection: (json['wind_direction_10m'] as num?)?.toInt(),
      surfacePressure: (json['surface_pressure'] as num?)?.toDouble(),
    );
  }
}

/// Model prakiraan cuaca harian (`daily` dari Open-Meteo).
class DailyForecastModel {
  const DailyForecastModel({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    this.sunrise,
    this.sunset,
    this.uvIndexMax,
  });

  final DateTime date;
  final int weatherCode; // daily.weather_code
  final double temperatureMax; // daily.temperature_2m_max
  final double temperatureMin; // daily.temperature_2m_min
  final int precipitationProbabilityMax; // daily.precipitation_probability_max
  final String? sunrise;
  final String? sunset;
  final double? uvIndexMax;
}

/// Model prakiraan cuaca per jam (`hourly` dari Open-Meteo).
class HourlyForecastModel {
  const HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
  final bool isDay;
}
