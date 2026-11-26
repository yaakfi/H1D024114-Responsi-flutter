import 'package:flutter/material.dart';

import '../../core/utils/weather_code_helper.dart';

/// Latar belakang gradien atmosfer adaptif sesuai kondisi cuaca (rain/clear/cloudy)
/// dan tema (light/dark) mengikuti desain SkyCast Cuaca Redesigned.
class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({
    super.key,
    required this.skyType,
    required this.child,
  });

  final WeatherSkyType skyType;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linearColors = _linearGradientColors(skyType, isDark);
    final radialColor = _radialGlowColor(skyType, isDark);
    final radialAlignment = _radialAlignment(skyType, isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: isDark ? const [0.0, 0.48, 1.0] : const [0.0, 0.40, 1.0],
          colors: linearColors,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: radialAlignment,
            radius: 0.95,
            colors: [
              radialColor,
              radialColor.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.65],
          ),
        ),
        child: child,
      ),
    );
  }

  List<Color> _linearGradientColors(WeatherSkyType type, bool isDark) {
    if (isDark) {
      switch (type) {
        case WeatherSkyType.clear:
          return const [
            Color(0xFF171615),
            Color(0xFF111112),
            Color(0xFF0B0C0E),
          ];
        case WeatherSkyType.cloudy:
          return const [
            Color(0xFF161719),
            Color(0xFF101113),
            Color(0xFF0B0C0E),
          ];
        case WeatherSkyType.rain:
          return const [
            Color(0xFF15171A),
            Color(0xFF101114),
            Color(0xFF0B0C0E),
          ];
      }
    }

    switch (type) {
      case WeatherSkyType.clear:
        return const [
          Color(0xFFEEF4FB),
          Color(0xFFF7F9FC),
          Color(0xFFFAFBFD),
        ];
      case WeatherSkyType.cloudy:
        return const [
          Color(0xFFEAEFF5),
          Color(0xFFF4F6F9),
          Color(0xFFF8FAFC),
        ];
      case WeatherSkyType.rain:
        return const [
          Color(0xFFE6EFF7),
          Color(0xFFF4F7FA),
          Color(0xFFF8FAFC),
        ];
    }
  }

  Color _radialGlowColor(WeatherSkyType type, bool isDark) {
    if (isDark) {
      switch (type) {
        case WeatherSkyType.clear:
          return const Color(0xFFD6B48A).withValues(alpha: 0.09);
        case WeatherSkyType.cloudy:
          return const Color(0xFFA1A1AA).withValues(alpha: 0.08);
        case WeatherSkyType.rain:
          return const Color(0xFF94A3B8).withValues(alpha: 0.10);
      }
    }

    switch (type) {
      case WeatherSkyType.clear:
        return const Color(0xFFFBBF24).withValues(alpha: 0.18);
      case WeatherSkyType.cloudy:
        return const Color(0xFF94A3B8).withValues(alpha: 0.16);
      case WeatherSkyType.rain:
        return const Color(0xFF38BDF8).withValues(alpha: 0.15);
    }
  }

  Alignment _radialAlignment(WeatherSkyType type, bool isDark) {
    if (type == WeatherSkyType.clear) {
      return isDark ? const Alignment(0.5, -1.0) : const Alignment(0.5, -0.92);
    }
    return isDark ? const Alignment(0.0, -1.1) : const Alignment(0.0, -1.0);
  }
}
