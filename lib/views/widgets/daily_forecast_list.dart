import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/weather_model.dart';
import 'daily_detail_sheet.dart';
import 'weather_outline_icon.dart';

/// Daftar prakiraan cuaca 7 hari ke depan bergaya lapang dengan pembatas hairline
/// tanpa kotak kartu luar, sesuai desain SkyCast Cuaca Redesigned.
class DailyForecastList extends StatelessWidget {
  const DailyForecastList({
    super.key,
    required this.locationName,
    required this.forecasts,
    required this.isFahrenheit,
  });

  final String locationName;
  final List<DailyForecastModel> forecasts;
  final bool isFahrenheit;

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final globalMin =
        forecasts.map((e) => e.temperatureMin).reduce(math.min);
    final globalMax =
        forecasts.map((e) => e.temperatureMax).reduce(math.max);
    final totalSpan = math.max(1.0, globalMax - globalMin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRAKIRAAN ${forecasts.length} HARI',
              style: theme.textTheme.labelMedium,
            ),
            Text(
              'Ketuk hari untuk detail',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 11,
                color: textColor.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forecasts.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: AppTheme.hairlineColor(context),
          ),
          itemBuilder: (context, index) {
            final item = forecasts[index];
            final info = WeatherCodeHelper.fromCode(item.weatherCode);
            final startFraction =
                ((item.temperatureMin - globalMin) / totalSpan)
                    .clamp(0.0, 1.0);
            final endFraction =
                ((item.temperatureMax - globalMin) / totalSpan)
                    .clamp(0.0, 1.0);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => DailyDetailSheet(
                    locationName: locationName,
                    forecast: item,
                    dayIndex: index,
                    isFahrenheit: isFahrenheit,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    // Hari & tanggal singkat
                    SizedBox(
                      width: 82,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            WeatherFormatter.formatDailyLabel(
                              item.date,
                              index: index,
                            ),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            WeatherFormatter.formatShortDate(item.date),
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ikon cuaca outline & peluang hujan
                    SizedBox(
                      width: 70,
                      child: Row(
                        children: [
                          WeatherOutlineIcon(
                            kind: info.iconKind,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${item.precipitationProbabilityMax}%',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.rainAccent(context),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Suhu minimum, bar rentang suhu, dan suhu maksimum
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              WeatherFormatter.formatTemperature(
                                item.temperatureMin,
                                isFahrenheit: isFahrenheit,
                              ),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                color: textColor.withValues(alpha: 0.50),
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: SizedBox(
                                height: 6,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final barWidth = constraints.maxWidth;
                                    final left = barWidth * startFraction;
                                    final width = math.max(
                                      barWidth * 0.20,
                                      barWidth * (endFraction - startFraction),
                                    );

                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.08)
                                                : const Color(0xFFE2E8F0)
                                                    .withValues(alpha: 0.85),
                                            borderRadius:
                                                BorderRadius.circular(99),
                                          ),
                                        ),
                                        Positioned(
                                          left:
                                              left.clamp(0.0, barWidth - width),
                                          width: width,
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF38BDF8),
                                                  Color(0xFFFBBF24),
                                                  Color(0xFFFB923C),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(99),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 30,
                            child: Text(
                              WeatherFormatter.formatTemperature(
                                item.temperatureMax,
                                isFahrenheit: isFahrenheit,
                              ),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
