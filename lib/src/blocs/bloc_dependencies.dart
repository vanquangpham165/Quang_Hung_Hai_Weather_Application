import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:quang_hung_hai_weather_application/src/blocs/current_weather_bloc/current_weather_bloc.dart';
import 'package:quang_hung_hai_weather_application/src/blocs/location/location_bloc.dart';
import 'package:quang_hung_hai_weather_application/src/blocs/week_forecast_weather_bloc/week_forecast_weather_bloc.dart';
import 'package:quang_hung_hai_weather_application/src/services/location/location_service.dart';
import 'package:quang_hung_hai_weather_application/src/services/weather_service/weather_service.dart';

class BlocsDependencies {
  static Injector initialise(Injector injector) {
    injector.map<WeekForeCastWeatherBloc>(
        (injector) =>
            WeekForeCastWeatherBloc(service: injector.get<WeatherService>()));
    injector.map<CurrentWeatherBloc>(
        (injector) =>
            CurrentWeatherBloc(service: injector.get<WeatherService>()),
        isSingleton: true);
    injector.map<LocationBloc>(
        (injector) => LocationBloc(service: injector.get<LocationService>()),
        isSingleton: true);
    return injector;
  }
}