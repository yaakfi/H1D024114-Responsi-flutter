import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/weather_model.dart';

/// Grid 2 kolom terpadu dengan pembatas hairline tenang (`Kondisi Saat Ini`),
/// menampilkan kelembapan, angin, curah hujan, indeks UV, suhu dirasakan, dan bar matahari.
class WeatherMetricsGrid extends StatelessWidget {
  const WeatherMetricsGrid({
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
    final current = weather.current;
    final today = weather.todayForecast;
    final windDir = WeatherFormatter.windDirectionLabel(current.windDirection);
    final hairline = AppTheme.hairlineColor(context, subtle: true);
    final outerBorder = AppTheme.hairlineColor(context);

    final humidityNote = current.relativeHumidity >= 75
        ? 'Udara cukup lembap'
        : current.relativeHumidity <= 40
            ? 'Relatif kering'
            : 'Sejuk dan nyaman';

    final sunriseText =
        today?.sunrise != null ? WeatherFormatter.formatTime(today!.sunrise!) : '-';
    final sunsetText =
        today?.sunset != null ? WeatherFormatter.formatTime(today!.sunset!) : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KONDISI SAAT INI',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: outerBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Baris 1: Kelembapan | Angin
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.water_drop_outlined,
                        label: 'Kelembapan',
                        value: '${current.relativeHumidity}%',
                        note: humidityNote,
                      ),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: hairline),
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.air_rounded,
                        label: 'Angin',
                        value: '${current.windSpeed.toStringAsFixed(1)} km/j',
                        note: 'Arah $windDir',
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              // Baris 2: Curah Hujan | Indeks UV Maks
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.grain_rounded,
                        label: 'Curah Hujan',
                        value: '${current.precipitation.toStringAsFixed(1)} mm',
                        note:
                            'Peluang ${today?.precipitationProbabilityMax ?? 0}%',
                      ),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: hairline),
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.wb_sunny_outlined,
                        label: today?.uvIndexMax != null
                            ? 'Indeks UV Maks'
                            : 'Tekanan Udara',
                        value: today?.uvIndexMax != null
                            ? today!.uvIndexMax!.toStringAsFixed(1)
                            : '${current.surfacePressure?.round() ?? '-'} hPa',
                        note: today?.uvIndexMax != null
                            ? WeatherFormatter.uvCategory(today!.uvIndexMax!)
                            : 'Permukaan laut',
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: hairline),

              // Baris 3: Suhu Dirasakan | Matahari (Terbit · Terbenam)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _MetricCell(
                        icon: Icons.thermostat_outlined,
                        label: 'Suhu Dirasakan',
                        value: WeatherFormatter.formatTemperature(
                          current.apparentTemperature,
                          isFahrenheit: isFahrenheit,
                          decimals: 1,
                        ),
                        note: 'Indeks panas tubuh',
                      ),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: hairline),
                    Expanded(
                      child: _DaylightCell(
                        sunrise: sunriseText,
                        sunset: sunsetText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: textColor.withValues(alpha: 0.55)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            note,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              color: textColor.withValues(alpha: 0.55),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DaylightCell extends StatelessWidget {
  const _DaylightCell({
    required this.sunrise,
    required this.sunset,
  });

  final String sunrise;
  final String sunset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_twilight_rounded,
                size: 14,
                color: textColor.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 6),
              Text(
                'Matahari',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sunrise,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    sunset,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: textColor.withValues(alpha: 0.65),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFCD34D).withValues(alpha: 0.85),
                        const Color(0xFFFBBF24).withValues(alpha: 0.85),
                        const Color(0xFF818CF8).withValues(alpha: 0.80),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Terbit · Terbenam',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 11,
              color: textColor.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
