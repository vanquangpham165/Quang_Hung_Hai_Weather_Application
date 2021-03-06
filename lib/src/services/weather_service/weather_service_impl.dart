import 'dart:convert';

import '../../models/city.dart';

import '../../models/current_weather.dart';
import '../../models/week_forecast_weather.dart';
import '../../utils/rest_client.dart';
import 'weather_service.dart';

class WeatherServiceImpl extends WeatherService {
  @override
  Future<CurrentWeather> getCurrentWeather(
      {required double lon, required double lat}) async {
    final currentWeatherBody = await HttpClientServices.httpClient().getData(
        '/data/2.5/onecall',
        params: {"lat": '$lat', "lon": '$lon', "exclude": "alerts"});
    final responseData = json.decode(currentWeatherBody);

    final currentCityBody = await HttpClientServices.httpClient()
        .getData('/data/2.5/weather', params: {"lat": '$lat', "lon": '$lon'});
    final cityData = json.decode(currentCityBody);

    City city = City.fromJson(cityData);

    CurrentWeather currentWeather = CurrentWeather.fromJson(responseData);

    currentWeather.setCity = city;

    return currentWeather;
  }

  @override
  Future<WeekForeCastWeather> getWeekForecast(
      {required double lon, required double lat}) async {
    final weekWeatherBody = await HttpClientServices.httpClient().getData(
        '/data/2.5/onecall',
        params: {"lat": '$lat', "lon": '$lon', "exclude": "alerts"});
    final responseData = json.decode(weekWeatherBody);

    return WeekForeCastWeather.fromJson(responseData);
  }
}
