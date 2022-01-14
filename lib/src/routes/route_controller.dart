import 'package:flutter/material.dart';

import '../constants/routes_name.dart';
import '../models/city.dart';
import '../screens/location_screen/location_screen.dart';
import '../screens/main_screen/main_screen.dart';
import '../screens/not_found_screen/not_found_screen.dart';
import '../screens/weather_forecast_screen/weather_forecast_screen.dart';

class RouteController {
  MaterialPageRoute routePage(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) {
        switch (settings.name) {
          case RouteNames.main:
            return MainScreen(settings.arguments as City);
          case RouteNames.location:
            return LocationScreen(cityName: settings.arguments as String);
          case RouteNames.weatherForecast:
            return WeatherForecastScreen(city: settings.arguments as City);
          default:
            return const NotFoundScreen();
        }
      },
      settings: settings,
    );
  }
}
