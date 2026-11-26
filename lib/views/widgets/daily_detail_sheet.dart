import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/weather_model.dart';
import 'weather_outline_icon.dart';

/// Bottom sheet detail prakiraan harian bergaya editorial minimalis
/// sesuai desain SkyCast Cuaca Redesigned.
class DailyDetailSheet extends StatelessWidget {
  const DailyDetailSheet({
    super.key,
    required this.locationName,
    required this.forecast,
    required this.dayIndex,
    required this.isFahrenheit,
  });

  final String locationName;
  final DailyForecastModel forecast;
  final int dayIndex;
  final bool isFahrenheit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final info = WeatherCodeHelper.fromCode(forecast.weatherCode);

    final advisoryBorderColor = info.isWarning
        ? const Color(0xFFF59E0B)
        : const Color(0xFF0EA5E9);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSheetBg : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: isDark
            ? Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              )
            : null,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header: Outline icon + Hari + Kota · Tanggal + Tombol tutup X
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeatherOutlineIcon(
                    kind: info.iconKind,
                    size: 42,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          WeatherFormatter.formatDailyLabel(
                            forecast.date,
                            index: dayIndex,
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$locationName · ${WeatherFormatter.formatFullDate(forecast.date)}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup detail',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: textColor.withValues(alpha: 0.75),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Advisory block dengan garis aksen kiri 2px
              Container(
                padding: const EdgeInsets.only(left: 14, top: 2, bottom: 2),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: advisoryBorderColor, width: 2.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.5,
                        height: 1.45,
                        color: textColor.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Divider atas
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 18),

              // Grid 2 kolom lapang (tanpa kotak pill)
              Row(
                children: [
                  Expanded(
                    child: _SheetStatItem(
                      icon: Icons.thermostat_outlined,
                      label: 'Suhu Maksimum',
                      value: WeatherFormatter.formatTemperature(
                        forecast.temperatureMax,
                        isFahrenheit: isFahrenheit,
                        decimals: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _SheetStatItem(
                      icon: Icons.thermostat_outlined,
                      label: 'Suhu Minimum',
                      value: WeatherFormatter.formatTemperature(
                        forecast.temperatureMin,
                        isFahrenheit: isFahrenheit,
                        decimals: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SheetStatItem(
                      icon: Icons.grain_rounded,
                      label: 'Peluang Hujan',
                      value: '${forecast.precipitationProbabilityMax}%',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _SheetStatItem(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Indeks UV',
                      value: forecast.uvIndexMax != null
                          ? '${forecast.uvIndexMax!.toStringAsFixed(1)} (${WeatherFormatter.uvCategory(forecast.uvIndexMax!)})'
                          : '-',
                    ),
                  ),
                ],
              ),
              if (forecast.sunrise != null || forecast.sunset != null) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SheetStatItem(
                        icon: Icons.wb_twilight_rounded,
                        label: 'Matahari Terbit',
                        value: forecast.sunrise != null
                            ? WeatherFormatter.formatTime(forecast.sunrise!)
                            : '-',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _SheetStatItem(
                        icon: Icons.wb_twilight_rounded,
                        label: 'Matahari Terbenam',
                        value: forecast.sunset != null
                            ? WeatherFormatter.formatTime(forecast.sunset!)
                            : '-',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetStatItem extends StatelessWidget {
  const _SheetStatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: textColor.withValues(alpha: 0.50)),
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
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: textColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
