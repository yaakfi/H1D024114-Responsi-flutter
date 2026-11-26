import 'package:flutter/material.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/weather_model.dart';
import 'weather_outline_icon.dart';

/// Bagian Hero atmosferik tanpa kotak kartu berat:
/// menampilkan timestamp real-time, ikon cuaca garis halus, suhu besar tipografi ringan,
/// kondisi cuaca, ringkasan terasa/maks/min, dan pill konteks peluang hujan.
class WeatherHeroCard extends StatelessWidget {
  const WeatherHeroCard({
    super.key,
    required this.weather,
    required this.isFahrenheit,
  });

  final WeatherModel weather;
  final bool isFahrenheit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final current = weather.current;
    final today = weather.todayForecast;
    final info = WeatherCodeHelper.fromCode(
      current.weatherCode,
      isDay: current.isDay,
    );
    final rainChance = today?.precipitationProbabilityMax ?? 0;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Timestamp dengan indikator titik hijau halus
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                WeatherFormatter.formatHeroTimestamp(
                  current.time,
                  timezoneAbbr: weather.timezoneAbbreviation,
                ),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: textColor.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Baris utama: ikon outline cuaca + angka suhu ringan berukuran besar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WeatherOutlineIcon(
                kind: info.iconKind,
                size: 76,
                isDay: current.isDay,
              ),
              const SizedBox(width: 20),
              Text(
                WeatherFormatter.formatTemperature(
                  current.temperature,
                  isFahrenheit: isFahrenheit,
                ),
                style: theme.textTheme.displayLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama kondisi cuaca
          Text(
            info.label,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Subline: Terasa · Maks · Min
          Text(
            _buildSubline(current, today),
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textColor.withValues(alpha: 0.60),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            textAlign: TextAlign.center,
          ),

          // Pill kontekstual peluang hujan
          if (rainChance >= 35 || current.precipitation > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFF0EA5E9).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: isDark
                    ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop_outlined,
                    size: 14,
                    color: isDark
                        ? const Color(0xFFE4E4E7)
                        : const Color(0xFF0369A1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Peluang hujan $rainChance% hari ini',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFE4E4E7)
                          : const Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _buildSubline(
    CurrentWeatherModel current,
    DailyForecastModel? today,
  ) {
    final terasa = WeatherFormatter.formatTemperature(
      current.apparentTemperature,
      isFahrenheit: isFahrenheit,
    );
    if (today == null) return 'Terasa $terasa';
    final maks = WeatherFormatter.formatTemperature(
      today.temperatureMax,
      isFahrenheit: isFahrenheit,
    );
    final min = WeatherFormatter.formatTemperature(
      today.temperatureMin,
      isFahrenheit: isFahrenheit,
    );
    return 'Terasa $terasa  ·  Maks $maks  ·  Min $min';
  }
}
