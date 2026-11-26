import 'package:flutter/material.dart';

/// Konfigurasi Material 3 Theme (Light & Dark) bergaya minimalis atmosferik
/// sesuai desain SkyCast Cuaca Redesigned.
class AppTheme {
  AppTheme._();

  static const Color lightPrimary = Color(0xFF0284C7); // sky-600
  static const Color lightText = Color(0xFF0F172A); // slate-900
  static const Color lightTextMuted = Color(0xFF64748B); // slate-500
  static const Color lightSurface = Color(0xFFF8FAFC);

  static const Color darkPrimary = Color(0xFF93B8E8);
  static const Color darkText = Color(0xFFF4F4F5); // zinc-100
  static const Color darkTextMuted = Color(0xFFA1A1AA); // zinc-400
  static const Color darkSurface = Color(0xFF0B0C0E);
  static const Color darkSheetBg = Color(0xFF16181C);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: lightPrimary,
      brightness: Brightness.light,
      primary: lightPrimary,
      surface: lightSurface,
      onSurface: lightText,
      onSurfaceVariant: lightTextMuted,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightSurface,
      textTheme: _buildTextTheme(Brightness.light, lightText),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: lightText,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightText,
          letterSpacing: -0.3,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.black.withValues(alpha: 0.06),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: lightText,
        contentTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
      primary: darkPrimary,
      surface: darkSurface,
      onSurface: darkText,
      onSurfaceVariant: darkTextMuted,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkSurface,
      textTheme: _buildTextTheme(Brightness.dark, darkText),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
          letterSpacing: -0.3,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF27272A),
        contentTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: darkText,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness, Color textColor) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return base
        .apply(
          fontFamily: 'Roboto',
          bodyColor: textColor,
          displayColor: textColor,
        )
        .copyWith(
          displayLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 78,
            fontWeight: FontWeight.w300,
            letterSpacing: -3.2,
            height: 1.0,
            color: textColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
            color: textColor,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: textColor,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: textColor,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: textColor.withValues(alpha: 0.50),
          ),
          labelSmall: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor.withValues(alpha: 0.55),
          ),
        );
  }

  /// Hairline divider color konsisten di seluruh screen.
  static Color hairlineColor(BuildContext context, {bool subtle = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.white.withValues(alpha: subtle ? 0.06 : 0.08);
    }
    return Colors.black.withValues(alpha: subtle ? 0.05 : 0.06);
  }

  /// Warna aksen hujan & persentase presipitasi (sky-600 light, soft blue dark).
  static Color rainAccent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPrimary : lightPrimary;
  }
}
