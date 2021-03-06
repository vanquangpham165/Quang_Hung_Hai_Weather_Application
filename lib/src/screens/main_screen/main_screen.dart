import 'package:after_layout/after_layout.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/current_weather_bloc/current_weather_bloc.dart';
import '../../blocs/current_weather_bloc/current_weather_event.dart';
import '../../blocs/current_weather_bloc/current_weather_state.dart';
import '../../constants/app_assets.dart';
import '../../constants/routes_name.dart';
import '../../dependencies/app_dependentcies.dart';
import '../../helper/day_format.dart';
import '../../models/city.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/day_temp_chart.dart';
import '../../widgets/map.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AfterLayoutMixin {
  final _currentWeatherBloc =
      AppDependencies.injector.get<CurrentWeatherBloc>();

  late City _city;
  final double _heightOfLeadingLogoAppBar = 48.0;

  final double _widthOfLeadingLogoAppBar = 50.0;

  final double _paddingHorizontalOfTitle = 28.0;

  final Color _colorOfChart = AppColors.chartColor.withOpacity(0.8);

  @override
  void afterFirstLayout(BuildContext context) {
    AppDependencies.injector.get<CurrentWeatherBloc>().add(
          CurrentWeatherRequested(
              lat: 30, lon: 30, requireCurrentLocation: true),
        );
  }

  @override
  Widget build(BuildContext context) {
    const double _heightOfColumn = 150;
    const double _heightOfChart = 50;

    double screenWidth = MediaQuery.of(context).size.width;
    TextStyle _titleAppBarStyle = Theme.of(context)
        .textTheme
        .copyWith()
        .subtitle1!
        .copyWith(
            fontWeight: AppFontWeight.light, fontSize: 18, color: Colors.white);

    TextStyle _subTitleAppBarStyle = Theme.of(context)
        .textTheme
        .copyWith()
        .subtitle2!
        .copyWith(
            fontWeight: AppFontWeight.light,
            fontSize: 18,
            color: AppColors.secondaryTextColor);

    TextStyle _dateTime = Theme.of(context)
        .textTheme
        .copyWith()
        .bodyText2!
        .copyWith(
            fontWeight: AppFontWeight.bold,
            fontSize: 13,
            color: Colors.white.withOpacity(1));
    return Scaffold(
      appBar: CustomAppBar(
        widgetLeading: Padding(
          padding: EdgeInsets.only(left: _paddingHorizontalOfTitle),
          child: SizedBox(
              height: _heightOfLeadingLogoAppBar,
              width: _widthOfLeadingLogoAppBar,
              child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.weatherForecast,
                        arguments: _city);
                  },
                  child: Image.asset(AppAsset.logoCloud))),
        ),
        title: Center(
          child: BlocBuilder(
            bloc: _currentWeatherBloc,
            builder: (context, state) {
              if (state is CurrentWeatherLoadInProgress) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CurrentWeatherLoadSuccess) {
                _city = state.currentWeather.city!;
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.location,
                            arguments: _city.name)
                        .then((result) {
                      if (result != null) {
                        City city = result as City;
                        setState(() {
                          _city = city;
                        });
                        AppDependencies.injector.get<CurrentWeatherBloc>().add(
                              CurrentWeatherRequested(
                                  lat: city.latitude, lon: city.longitude),
                            );
                      }
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        state.currentWeather.city!.name,
                        style: _titleAppBarStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.currentWeather.weatherStatus.weather,
                              style: _subTitleAppBarStyle),
                          const SizedBox(width: 5),
                          Text(
                              '${state.currentWeather.temp.toInt().toString()}${tr('appConstants.degrees')}',
                              style: _subTitleAppBarStyle),
                        ],
                      )
                    ],
                  ),
                );
              }
              if (state is CurrentWeatherLoadFailure) {
                return Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                );
              }
              return Container(
                color: Colors.orange,
              );
            },
          ),
        ),
        actionWidget: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.weatherForecast,
                    arguments: _city);
              },
              icon: Image.asset(AppAsset.logoSetting)),
        ],
      ),
      body: BlocBuilder(
        bloc: _currentWeatherBloc,
        builder: (context, state) {
          if (state is CurrentWeatherLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CurrentWeatherLoadSuccess) {
            return Stack(
              children: [
                MapWidget(
                    lat: state.currentWeather.city!.latitude,
                    lon: state.currentWeather.city!.longitude),
                SizedBox(
                  height: _heightOfColumn,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: 25 -
                              CustomDateTimeFormat.unixTimeToHour(
                                  state.currentWeather.dateTime),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text(
                                  CustomDateTimeFormat.unixTimeToHourUTC(state
                                      .currentWeather
                                      .weatherHourlyAlerts[index]
                                      .datetime),
                                  style: _dateTime,
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Align(
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                width: screenWidth /
                                    (25 -
                                        CustomDateTimeFormat.unixTimeToHour(
                                            state.currentWeather.dateTime)),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: _heightOfChart,
                        child: DayTempChart(
                          weatherTempAlert:
                              state.currentWeather.weatherHourlyAlerts,
                          weather: state.currentWeather,
                          color: _colorOfChart,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
          if (state is CurrentWeatherLoadFailure) {
            return Container(
              color: Colors.white,
              alignment: Alignment.center,
            );
          }
          return Container(
            color: Colors.orange,
          );
        },
      ),
    );
  }
}
