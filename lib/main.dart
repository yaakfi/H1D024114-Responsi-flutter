import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'repositories/weather_repository.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/screens/weather_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = WeatherApiService();
  final storageService = LocalStorageService();
  final repository = WeatherRepository(
    apiService: apiService,
    storageService: storageService,
  );

  runApp(SkyCastApp(repository: repository));
}

/// Root widget aplikasi (StatelessWidget) yang mengonfigurasi MultiProvider MVVM
/// serta ThemeData Material 3 (Light & Dark Mode).
class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key, required this.repository});

  final WeatherRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(repository: repository),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(repository: repository),
        ),
      ],
      child: Consumer<WeatherViewModel>(
        builder: (context, weatherVm, _) {
          return MaterialApp(
            title: 'SkyCast Cuaca',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: weatherVm.themeMode,
            home: const WeatherScreen(),
          );
        },
      ),
    );
  }
}
