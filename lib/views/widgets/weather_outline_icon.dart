import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/weather_code_helper.dart';

/// Ikon cuaca garis halus (outline vector) yang digambar langsung via CustomPainter
/// agar presisi mengikuti gaya ikon SVG minimalis pada desain SkyCast Cuaca.
class WeatherOutlineIcon extends StatelessWidget {
  const WeatherOutlineIcon({
    super.key,
    required this.kind,
    this.size = 24,
    this.isDay = true,
  });

  final WeatherIconKind kind;
  final double size;
  final bool isDay;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WeatherOutlinePainter(
          kind: kind,
          isDark: isDark,
          isDay: isDay,
        ),
      ),
    );
  }
}

class _WeatherOutlinePainter extends CustomPainter {
  const _WeatherOutlinePainter({
    required this.kind,
    required this.isDark,
    required this.isDay,
  });

  final WeatherIconKind kind;
  final bool isDark;
  final bool isDay;

  @override
  void paint(Canvas canvas, Size size) {
    // Koordinat kanvas referensi 64x64 sesuai SVG desain
    final scale = size.width / 64.0;
    canvas.save();
    canvas.scale(scale, scale);

    final strokeWidth = size.width >= 56
        ? 2.2
        : size.width >= 34
            ? 2.5
            : 3.1;

    final strokeColor =
        isDark ? const Color(0xFFE4E4E7) : const Color(0xFF334155);
    final rainColor =
        isDark ? const Color(0xFF93B8E8) : const Color(0xFF0284C7);
    final boltColor =
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    const sunColor = Color(0xFFF59E0B);

    final cloudFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          strokeColor.withValues(alpha: 0.14),
          strokeColor.withValues(alpha: 0.03),
        ],
      ).createShader(const Rect.fromLTWH(8, 12, 46, 32));

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (kind) {
      case WeatherIconKind.clear:
        if (isDay) {
          _drawSun(canvas, const Offset(32, 32), 11, sunColor, strokeWidth);
        } else {
          _drawMoon(canvas, strokePaint, strokeColor);
        }
        break;
      case WeatherIconKind.partly:
        if (isDay) {
          _drawPartlySun(canvas, sunColor, strokeWidth);
        }
        final maskPaint = Paint()
          ..color = isDark ? const Color(0xFF15171A) : const Color(0xFFEEF4FB)
          ..style = PaintingStyle.fill;
        final cloud = _buildCloudPath(offsetY: 4, scaleX: 0.92);
        canvas.drawPath(cloud, maskPaint);
        canvas.drawPath(cloud, cloudFillPaint);
        canvas.drawPath(cloud, strokePaint);
        break;
      case WeatherIconKind.cloudy:
        final cloud = _buildCloudPath(offsetY: 2);
        canvas.drawPath(cloud, cloudFillPaint);
        canvas.drawPath(cloud, strokePaint);
        break;
      case WeatherIconKind.fog:
        final cloud = _buildCloudPath(offsetY: -2);
        canvas.drawPath(cloud, cloudFillPaint);
        canvas.drawPath(cloud, strokePaint);
        final fogPaint = Paint()
          ..color = strokeColor.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(16, 44), const Offset(48, 44), fogPaint);
        canvas.drawLine(const Offset(21, 50), const Offset(43, 50), fogPaint);
        break;
      case WeatherIconKind.drizzle:
        final cloud = _buildCloudPath(offsetY: 0);
        canvas.drawPath(cloud, cloudFillPaint);
        canvas.drawPath(cloud, strokePaint);
        final dropPaint = Paint()
          ..color = rainColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(23, 45), const Offset(23, 49), dropPaint);
        canvas.drawLine(const Offset(32, 47), const Offset(32, 51), dropPaint);
        canvas.drawLine(const Offset(41, 45), const Offset(41, 49), dropPaint);
        break;
      case WeatherIconKind.rain:
        final cloud = _buildCloudPath(offsetY: -2);
        canvas.drawPath(cloud, cloudFillPaint);
        canvas.drawPath(cloud, strokePaint);
        final rainPaint = Paint()
          ..color = rainColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(23, 43), const Offset(21, 50), rainPaint);
        canvas.drawLine(
          const Offset(32.5, 43),
          const Offset(30.5, 50),
          rainPaint,
        );
        canvas.drawLine(const Offset(42, 43), const Offset(40, 50), rainPaint);
        break;
      case WeatherIconKind.snow:
        final cloud = _buildCloudPath(offsetY: -2);
        canvas.drawPath(cloud, cloudFillPaint);
        canvas.drawPath(cloud, strokePaint);
        final snowPaint = Paint()
          ..color = rainColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(const Offset(22, 46), 2.1, snowPaint);
        canvas.drawCircle(const Offset(32, 49), 2.1, snowPaint);
        canvas.drawCircle(const Offset(42, 46), 2.1, snowPaint);
        break;
      case WeatherIconKind.storm:
        final cloud = _buildCloudPath(offsetY: -2);
        canvas.drawPath(cloud, cloudFillPaint);
        canvas.drawPath(cloud, strokePaint);

        final boltPath = Path()
          ..moveTo(33.5, 36)
          ..lineTo(28.0, 45)
          ..lineTo(34.0, 45)
          ..lineTo(31.0, 54.5)
          ..lineTo(40.5, 43)
          ..lineTo(34.5, 43)
          ..close();

        canvas.drawPath(
          boltPath,
          Paint()
            ..color = boltColor.withValues(alpha: 0.20)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          boltPath,
          Paint()
            ..color = boltColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width < 28 ? 2.4 : 2.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
        break;
    }

    canvas.restore();
  }

  Path _buildCloudPath({double offsetY = 0, double scaleX = 1.0}) {
    final path = Path()
      ..moveTo(20, 38 + offsetY)
      ..lineTo(45, 38 + offsetY)
      ..cubicTo(
        51.2,
        38 + offsetY,
        55.2,
        33.4 + offsetY,
        55.0,
        27.8 + offsetY,
      )
      ..cubicTo(
        54.8,
        22.5 + offsetY,
        51.0,
        18.6 + offsetY,
        46.2,
        18.1 + offsetY,
      )
      ..cubicTo(
        44.5,
        11.2 + offsetY,
        38.4,
        7.0 + offsetY,
        31.8,
        7.8 + offsetY,
      )
      ..cubicTo(
        25.3,
        8.5 + offsetY,
        20.6,
        13.6 + offsetY,
        19.2,
        21.0 + offsetY,
      )
      ..cubicTo(
        13.5,
        21.2 + offsetY,
        9.5,
        25.4 + offsetY,
        9.8,
        30.5 + offsetY,
      )
      ..cubicTo(
        10.1,
        35.0 + offsetY,
        14.2,
        38 + offsetY,
        20,
        38 + offsetY,
      )
      ..close();

    if (scaleX != 1.0) {
      final matrix = Matrix4.identity()
        ..translateByDouble(-2.0, 0.0, 0.0, 1.0)
        ..scaleByDouble(scaleX, 0.94, 1.0, 1.0);
      return path.transform(matrix.storage);
    }
    return path;
  }

  void _drawPartlySun(Canvas canvas, Color sunColor, double strokeWidth) {
    const center = Offset(42, 22);
    const radius = 8.5;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..color = sunColor.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = sunColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final rayPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final angleDeg in [-90.0, -45.0, 0.0, -135.0]) {
      final rad = angleDeg * math.pi / 180.0;
      final start = center + Offset(math.cos(rad) * 12, math.sin(rad) * 12);
      final end = center + Offset(math.cos(rad) * 15, math.sin(rad) * 15);
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawSun(
    Canvas canvas,
    Offset center,
    double radius,
    Color sunColor,
    double strokeWidth,
  ) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = sunColor.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = sunColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final rayPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final rad = (i * 45.0) * math.pi / 180.0;
      final start =
          center + Offset(math.cos(rad) * (radius + 4.5), math.sin(rad) * (radius + 4.5));
      final end =
          center + Offset(math.cos(rad) * (radius + 8.5), math.sin(rad) * (radius + 8.5));
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawMoon(Canvas canvas, Paint strokePaint, Color strokeColor) {
    final moonPath = Path()
      ..moveTo(39, 14)
      ..arcToPoint(
        const Offset(49, 41),
        radius: const Radius.circular(18),
        largeArc: true,
        clockwise: false,
      )
      ..arcToPoint(
        const Offset(39, 14),
        radius: const Radius.circular(14),
        largeArc: false,
        clockwise: true,
      )
      ..close();

    canvas.drawPath(
      moonPath,
      Paint()..color = strokeColor.withValues(alpha: 0.14),
    );
    canvas.drawPath(moonPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _WeatherOutlinePainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isDay != isDay;
  }
}
