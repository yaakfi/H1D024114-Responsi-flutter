import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code_helper.dart';
import '../../models/location_model.dart';
import '../../models/weather_model.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/sky_top_header.dart';
import '../widgets/state_views.dart';
import '../widgets/weather_outline_icon.dart';

/// Screen 2: Search / Location Screen (StatefulWidget).
/// Menyediakan pencarian kota berbasis Open-Meteo Geocoding API,
/// daftar Kota Populer, Lokasi Tersimpan (Favorit), dan Riwayat Pencarian
/// yang tersimpan secara persisten di Local Storage.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.autoFocusSearch = false,
  });

  final bool autoFocusSearch;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<String> _popularCities = [
    'Purwokerto',
    'Bandung',
    'Yogyakarta',
    'Jakarta',
    'Surabaya',
    'Denpasar',
  ];

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SearchViewModel>().clearSearch();
      context.read<WeatherViewModel>().prefetchFavoritesWeather();
      if (widget.autoFocusSearch) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectLocation(LocationModel location) {
    Navigator.of(context).pop(location);
  }

  Future<void> _toggleFavorite(
    WeatherViewModel weatherVm,
    LocationModel location,
  ) async {
    final added = await weatherVm.toggleFavorite(location);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${location.name} disimpan ke favorit'
                : '${location.name} dihapus dari favorit',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  void _searchSuggestedCity(String cityName) {
    _controller.text = cityName;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: cityName.length),
    );
    context.read<SearchViewModel>().searchNow(cityName);
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    final skyType = weatherVm.weather != null
        ? WeatherCodeHelper.fromCode(
            weatherVm.weather!.current.weatherCode,
            isDay: weatherVm.weather!.current.isDay,
          ).skyType
        : WeatherSkyType.rain;

    return Scaffold(
      body: AtmosphericBackground(
        skyType: skyType,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header konsisten seperti pada desain
                  SkyTopHeader(
                    location: weatherVm.selectedLocation,
                    isFahrenheit: weatherVm.isFahrenheit,
                    isDarkMode: weatherVm.isDarkMode,
                    onCityTap: () => Navigator.of(context).pop(),
                    onToggleUnit: weatherVm.toggleTemperatureUnit,
                    onToggleTheme: weatherVm.toggleThemeMode,
                    onSearchTap: () => _focusNode.requestFocus(),
                  ),

                  // Sub-header: tombol kembali + judul Lokasi & Favorit
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 2, 22, 14),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Kembali',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            size: 26,
                            color: textColor,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lokasi & Favorit',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),

                  // Input pencarian kota minimalis
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: textColor,
                      ),
                      onChanged: searchVm.onQueryChanged,
                      onSubmitted: (value) => searchVm.searchNow(value),
                      decoration: InputDecoration(
                        hintText: 'Cari kota (mis. Bandung, Surabaya)...',
                        hintStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: textColor.withValues(alpha: 0.45),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.85),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 19,
                          color: textColor.withValues(alpha: 0.45),
                        ),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Bersihkan pencarian',
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: textColor.withValues(alpha: 0.55),
                                ),
                                onPressed: () {
                                  _controller.clear();
                                  searchVm.clearSearch();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppTheme.darkPrimary.withValues(alpha: 0.55)
                                : const Color(0xFF0EA5E9)
                                    .withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Konten utama: hasil pencarian API atau kota populer + favorit + riwayat
                  Expanded(
                    child: _buildBody(context, searchVm, weatherVm),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    switch (searchVm.status) {
      case SearchUiStatus.loading:
        return WeatherLoadingView(
          message: 'Mencari "${searchVm.query}"...',
        );
      case SearchUiStatus.error:
        return WeatherErrorView(
          title: 'Pencarian Gagal',
          message: searchVm.errorMessage ??
              'Tidak dapat menghubungi layanan Geocoding Open-Meteo.',
          onRetry: () => searchVm.searchNow(),
        );
      case SearchUiStatus.empty:
        return WeatherEmptyView(
          icon: Icons.location_off_outlined,
          title: 'Kota Tidak Ditemukan',
          subtitle:
              'Tidak ada kota yang cocok dengan "${searchVm.query}". Coba ejaan atau nama kota lain.',
          actionLabel: 'Reset Pencarian',
          onAction: () {
            _controller.clear();
            searchVm.clearSearch();
          },
        );
      case SearchUiStatus.loaded:
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
          children: [
            _ListSectionHeader(
              title: 'HASIL PENCARIAN',
              trailingText: '${searchVm.results.length} ditemukan',
            ),
            const SizedBox(height: 6),
            ..._buildHairlineRows(
              context,
              searchVm.results.map(
                (city) => _CityRow(
                  location: city,
                  cachedWeather: weatherVm.getCachedWeather(city),
                  isFahrenheit: weatherVm.isFahrenheit,
                  isActive: city == weatherVm.selectedLocation,
                  isFavorite: weatherVm.isFavorite(city),
                  onTap: () => _selectLocation(city),
                  onToggleFavorite: () => _toggleFavorite(weatherVm, city),
                ),
              ),
            ),
          ],
        );
      case SearchUiStatus.idle:
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 36),
          children: [
            // Kota Populer (memicu request Open-Meteo Geocoding API)
            Text(
              'KOTA POPULER',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularCities.map((cityName) {
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => _searchSuggestedCity(cityName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.black.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Text(
                      cityName,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFE4E4E7)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),

            // Lokasi Tersimpan (Favorit)
            _ListSectionHeader(
              title: 'LOKASI TERSIMPAN',
              trailingText: '${weatherVm.favorites.length} kota',
            ),
            const SizedBox(height: 6),
            if (weatherVm.favorites.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Belum ada lokasi favorit. Cari kota lalu ketuk ikon bintang untuk menyimpannya.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    color: textColor.withValues(alpha: 0.50),
                  ),
                ),
              )
            else
              ..._buildHairlineRows(
                context,
                weatherVm.favorites.map(
                  (city) => _CityRow(
                    location: city,
                    cachedWeather: weatherVm.getCachedWeather(city),
                    isFahrenheit: weatherVm.isFahrenheit,
                    isActive: city == weatherVm.selectedLocation,
                    isFavorite: true,
                    onTap: () => _selectLocation(city),
                    onToggleFavorite: () => _toggleFavorite(weatherVm, city),
                  ),
                ),
              ),

            // Riwayat Pencarian (hanya tampil jika ada item di Local Storage)
            if (weatherVm.searchHistory.isNotEmpty) ...[
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RIWAYAT PENCARIAN',
                    style: theme.textTheme.labelMedium,
                  ),
                  GestureDetector(
                    onTap: weatherVm.clearSearchHistory,
                    child: Text(
                      'Hapus Semua',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.rainAccent(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ..._buildHairlineRows(
                context,
                weatherVm.searchHistory.map(
                  (city) => _CityRow(
                    location: city,
                    cachedWeather: weatherVm.getCachedWeather(city),
                    isFahrenheit: weatherVm.isFahrenheit,
                    isActive: city == weatherVm.selectedLocation,
                    isFavorite: weatherVm.isFavorite(city),
                    isHistoryItem: true,
                    onTap: () => _selectLocation(city),
                    onToggleFavorite: () => _toggleFavorite(weatherVm, city),
                    onRemoveHistory: () =>
                        weatherVm.removeFromSearchHistory(city),
                  ),
                ),
              ),
            ],
          ],
        );
    }
  }

  List<Widget> _buildHairlineRows(
    BuildContext context,
    Iterable<Widget> rows,
  ) {
    final list = rows.toList();
    final result = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      result.add(list[i]);
      if (i < list.length - 1) {
        result.add(Divider(height: 1, color: AppTheme.hairlineColor(context)));
      }
    }
    return result;
  }
}

class _ListSectionHeader extends StatelessWidget {
  const _ListSectionHeader({
    required this.title,
    required this.trailingText,
  });

  final String title;
  final String trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.labelMedium),
        Text(
          trailingText,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _CityRow extends StatelessWidget {
  const _CityRow({
    required this.location,
    required this.cachedWeather,
    required this.isFahrenheit,
    required this.isActive,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.isHistoryItem = false,
    this.onRemoveHistory,
  });

  final LocationModel location;
  final WeatherModel? cachedWeather;
  final bool isFahrenheit;
  final bool isActive;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final bool isHistoryItem;
  final VoidCallback? onRemoveHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    final weatherInfo = cachedWeather != null
        ? WeatherCodeHelper.fromCode(
            cachedWeather!.current.weatherCode,
            isDay: cachedWeather!.current.isDay,
          )
        : null;

    final subtitleText = weatherInfo != null
        ? (location.subtitle.isNotEmpty
            ? '${location.subtitle} · ${weatherInfo.label}'
            : weatherInfo.label)
        : (location.subtitle.isNotEmpty
            ? '${location.subtitle} · ${location.coordinatesLabel}'
            : location.coordinatesLabel);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Ikon kiri: outline cuaca jika sudah ter-cache dari API, atau ikon lokasi/riwayat
            if (weatherInfo != null)
              WeatherOutlineIcon(
                kind: weatherInfo.iconKind,
                size: 24,
                isDay: cachedWeather!.current.isDay,
              )
            else
              Icon(
                isHistoryItem
                    ? Icons.history_rounded
                    : Icons.location_on_outlined,
                size: 20,
                color: textColor.withValues(alpha: 0.50),
              ),
            const SizedBox(width: 14),

            // Nama kota, badge Aktif, dan subtitle wilayah / kondisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          location.name,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : const Color(0xFF0EA5E9)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Aktif',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFE4E4E7)
                                  : const Color(0xFF0369A1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitleText,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Suhu live (jika sudah ada dari Open-Meteo API)
            if (cachedWeather != null) ...[
              const SizedBox(width: 10),
              Text(
                WeatherFormatter.formatTemperature(
                  cachedWeather!.current.temperature,
                  isFahrenheit: isFahrenheit,
                ),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
            const SizedBox(width: 6),

            // Tombol bintang favorit
            IconButton(
              tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan favorit',
              onPressed: onToggleFavorite,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 20,
                color: isFavorite
                    ? const Color(0xFFF59E0B)
                    : textColor.withValues(alpha: 0.45),
              ),
            ),

            if (onRemoveHistory != null)
              IconButton(
                tooltip: 'Hapus dari riwayat',
                onPressed: onRemoveHistory,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: textColor.withValues(alpha: 0.40),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
