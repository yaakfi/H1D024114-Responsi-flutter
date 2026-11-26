import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/weather_model.dart';
import 'weather_outline_icon.dart';

/// Strip horizontal interaktif tanpa batas kartu untuk prakiraan 24 jam ke depan.
class HourlyForecastStrip extends StatelessWidget {
  const HourlyForecastStrip({
    super.key,
    required this.hourlyForecasts,
    required this.isFahrenheit,
    required this.selectedIndex,
    required this.onSelectHour,
  });

  final List<HourlyForecastModel> hourlyForecasts;
  final bool isFahrenheit;
  final int selectedIndex;
  final ValueChanged<int> onSelectHour;

  @override
  Widget build(BuildContext context) {
    if (hourlyForecasts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final safeIndex = selectedIndex.clamp(0, hourlyForecasts.length - 1);
    final selectedItem = hourlyForecasts[safeIndex];
    final selectedLabel = safeIndex == 0
        ? 'Sekarang'
        : '${selectedItem.time.hour.toString().padLeft(2, '0')}:00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRAKIRAAN PER JAM',
              style: theme.textTheme.labelMedium,
            ),
            Text(
              '$selectedLabel · Hujan ${selectedItem.precipitationProbability}%',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: textColor.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyForecasts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = hourlyForecasts[index];
              final info = WeatherCodeHelper.fromCode(
                item.weatherCode,
                isDay: item.isDay,
              );
              final isActive = index == safeIndex;
              final hourText = index == 0
                  ? 'Sekarang'
                  : '${item.time.hour.toString().padLeft(2, '0')}:00';

              final activeBg = isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFF0EA5E9).withValues(alpha: 0.14);
              final activeBorder = isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : const Color(0xFF0EA5E9).withValues(alpha: 0.35);

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelectHour(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 66,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? activeBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isActive
                        ? Border.all(color: activeBorder, width: 1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hourText,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11,
                          fontWeight: isActive && !isDark
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive && !isDark
                              ? const Color(0xFF075985)
                              : textColor.withValues(
                                  alpha: isActive ? 0.95 : 0.60,
                                ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      WeatherOutlineIcon(
                        kind: info.iconKind,
                        size: 22,
                        isDay: item.isDay,
                      ),
                      Text(
                        WeatherFormatter.formatTemperature(
                          item.temperature,
                          isFahrenheit: isFahrenheit,
                        ),
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? textColor
                              : textColor.withValues(alpha: 0.85),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '${item.precipitationProbability}%',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.rainAccent(context),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
