import 'package:flutter/material.dart';

import '../../models/location_model.dart';

/// Header navigasi tunggal yang bersih sesuai desain SkyCast Cuaca Redesigned:
/// Kiri: Pin lokasi + Nama Kota + chevron + Wilayah.
/// Kanan: Toggle °C/°F, Toggle Tema (Bulan/Matahari), dan tombol Cari.
class SkyTopHeader extends StatelessWidget {
  const SkyTopHeader({
    super.key,
    required this.location,
    required this.isFahrenheit,
    required this.isDarkMode,
    required this.onCityTap,
    required this.onToggleUnit,
    required this.onToggleTheme,
    required this.onSearchTap,
  });

  final LocationModel location;
  final bool isFahrenheit;
  final bool isDarkMode;
  final VoidCallback onCityTap;
  final VoidCallback onToggleUnit;
  final VoidCallback onToggleTheme;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pinColor =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF0284C7);
    final textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onCityTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: pinColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  location.name,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                    height: 1.15,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 17,
                                color: textColor.withValues(alpha: 0.50),
                              ),
                            ],
                          ),
                          if (location.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              location.subtitle,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                height: 1.15,
                                color: textColor.withValues(alpha: 0.55),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            tooltip: 'Ubah satuan suhu',
            onPressed: onToggleUnit,
            child: Text(
              isFahrenheit ? '°F' : '°C',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: textColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _HeaderIconButton(
            tooltip: isDarkMode ? 'Mode Terang' : 'Mode Gelap',
            onPressed: onToggleTheme,
            child: Icon(
              isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.dark_mode_outlined,
              size: 19,
              color: textColor,
            ),
          ),
          _HeaderIconButton(
            tooltip: 'Cari Kota & Favorit',
            onPressed: onSearchTap,
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(child: child),
        ),
      ),
    );
  }
}
