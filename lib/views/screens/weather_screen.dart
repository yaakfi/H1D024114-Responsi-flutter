import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/weather_code_helper.dart';
import '../../models/location_model.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/hourly_forecast_strip.dart';
import '../widgets/sky_top_header.dart';
import '../widgets/state_views.dart';
import '../widgets/weather_hero_card.dart';
import '../widgets/weather_metrics_grid.dart';
import 'search_screen.dart';

/// Screen 1: Home / Weather Screen (StatefulWidget).
/// Menerapkan desain minimalis atmosferik SkyCast Cuaca dengan latar gradien adaptif,
/// hero tipografi ringan, prakiraan per jam interaktif, prakiraan 7 hari,
/// dan grid kondisi saat ini berbasis data live Open-Meteo API.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<WeatherViewModel>();
      if (vm.status == WeatherUiStatus.initial) {
        vm.initialize();
      }
    });
  }

  Future<void> _openSearchScreen({bool autoFocusSearch = false}) async {
    final selected = await Navigator.of(context).push<LocationModel>(
      MaterialPageRoute(
        builder: (_) => SearchScreen(autoFocusSearch: autoFocusSearch),
      ),
    );
    if (!mounted || selected == null) return;
    await context.read<WeatherViewModel>().selectLocation(selected);
  }

  Future<void> _handleToggleUnit(WeatherViewModel vm) async {
    await vm.toggleTemperatureUnit();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Satuan suhu diubah ke ${vm.isFahrenheit ? '°F' : '°C'}',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(milliseconds: 1600),
          width: 240,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final skyType = vm.weather != null
        ? WeatherCodeHelper.fromCode(
            vm.weather!.current.weatherCode,
            isDay: vm.weather!.current.isDay,
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
                children: [
                  SkyTopHeader(
                    location: vm.selectedLocation,
                    isFahrenheit: vm.isFahrenheit,
                    isDarkMode: vm.isDarkMode,
                    onCityTap: () => _openSearchScreen(autoFocusSearch: false),
                    onToggleUnit: () => _handleToggleUnit(vm),
                    onToggleTheme: vm.toggleThemeMode,
                    onSearchTap: () => _openSearchScreen(autoFocusSearch: true),
                  ),
                  Expanded(child: _buildBody(context, vm)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    switch (vm.status) {
      case WeatherUiStatus.initial:
      case WeatherUiStatus.loading:
        return WeatherLoadingView(
          message: 'Memuat cuaca untuk ${vm.selectedLocation.name}...',
        );
      case WeatherUiStatus.error:
        return WeatherErrorView(
          message: vm.errorMessage ??
              'Terjadi kendala saat mengambil informasi cuaca.',
          onRetry: () => vm.fetchWeatherForSelectedLocation(),
        );
      case WeatherUiStatus.empty:
        return WeatherEmptyView(
          icon: Icons.wb_cloudy_outlined,
          title: 'Data Cuaca Kosong',
          subtitle:
              'Tidak ada data prakiraan yang diterima untuk ${vm.selectedLocation.name}.',
          actionLabel: 'Cari Lokasi Lain',
          onAction: () => _openSearchScreen(autoFocusSearch: true),
        );
      case WeatherUiStatus.loaded:
        final weather = vm.weather;
        if (weather == null) {
          return WeatherEmptyView(
            icon: Icons.wb_cloudy_outlined,
            title: 'Data Cuaca Tidak Tersedia',
            subtitle: 'Silakan muat ulang atau pilih kota lain.',
            actionLabel: 'Muat Ulang',
            onAction: () => vm.fetchWeatherForSelectedLocation(),
          );
        }

        final theme = Theme.of(context);
        return RefreshIndicator(
          onRefresh: () => vm.fetchWeatherForSelectedLocation(isRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vm.errorMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      vm.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],

                // 1. Atmospheric Hero
                WeatherHeroCard(
                  weather: weather,
                  isFahrenheit: vm.isFahrenheit,
                ),
                const SizedBox(height: 28),

                // 2. Prakiraan Per Jam (Interaktif)
                HourlyForecastStrip(
                  hourlyForecasts: weather.next24Hours,
                  isFahrenheit: vm.isFahrenheit,
                  selectedIndex: vm.selectedHourIndex,
                  onSelectHour: vm.selectHour,
                ),
                const SizedBox(height: 28),

                // 3. Prakiraan 7 Hari (Hairline dividers)
                DailyForecastList(
                  locationName: vm.selectedLocation.name,
                  forecasts: weather.dailyForecasts,
                  isFahrenheit: vm.isFahrenheit,
                ),
                const SizedBox(height: 28),

                // 4. Kondisi Saat Ini (Calm 2-column hairline grid + Daylight Bar)
                WeatherMetricsGrid(
                  weather: weather,
                  isFahrenheit: vm.isFahrenheit,
                ),
                const SizedBox(height: 24),

                // Footer sumber data API
                Text(
                  'Data real-time oleh Open-Meteo API',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.40),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
