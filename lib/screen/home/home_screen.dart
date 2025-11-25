import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:weather/data/models/settings_model.dart';
import 'package:weather/data/models/weather_model.dart';
import 'package:weather/screen/home/bloc/home_screen_bloc.dart';
import 'package:weather/screen/home/bloc/home_screen_event.dart';
import 'package:weather/screen/home/bloc/home_screen_state.dart';
import 'package:weather/utils/format_helper.dart';
import 'package:weather/widgets/gradient_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenBloc()..add(GetHomeScreenDataEvent()),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('天氣預報'),
        ),
        body: BlocBuilder<HomeScreenBloc, HomeScreenState>(
          builder: (context, state) {
            if (state is HomeScreenLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeScreenErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<HomeScreenBloc>().add(
                        HomeScreenErrorRetryEvent(),
                      ),
                      child: const Text('重試'),
                    ),
                  ],
                ),
              );
            } else if (state is HomeScreenLoadedState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (state.currentWeather != null)
                      CurrentWeatherWidget(
                        weather: state.currentWeather!,
                        settings: state.settings,
                      ),
                    const SizedBox(height: 16),
                    HourlyForecastWidget(
                      forecasts: state.hourlyForecast,
                      settings: state.settings,
                    ),
                    const SizedBox(height: 16),
                    DailyForecastWidget(
                      forecasts: state.dailyForecast,
                      settings: state.settings,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// 當前位置天氣 Widget
class CurrentWeatherWidget extends StatelessWidget {
  final CurrentWeather weather;
  final AppSettings settings;

  const CurrentWeatherWidget({
    super.key,
    required this.weather,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 溫度和天氣狀況
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weather.condition.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.formatTemperature(
                        weather.temperature,
                        settings,
                      ),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '體感 ${FormatHelper.formatTemperature(weather.feelsLike, settings)}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              weather.condition.description,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // 濕度、風速、氣壓
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('濕度', '${weather.humidity}%'),
                _buildInfoItem('風速', '${weather.windSpeed} km/h'),
                _buildInfoItem('氣壓', '${weather.pressure} hPa'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // 日出日落
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  '日出',
                  FormatHelper.formatTime(weather.sunrise, settings),
                ),
                _buildInfoItem(
                  '日落',
                  FormatHelper.formatTime(weather.sunset, settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// 24小時預報 Widget
class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final AppSettings settings;

  const HourlyForecastWidget({
    super.key,
    required this.forecasts,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '24小時預報',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecasts.length,
                itemBuilder: (context, index) {
                  final forecast = forecasts[index];
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          FormatHelper.formatHour(forecast.time, settings),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          forecast.condition.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatHelper.formatTemperatureShort(
                            forecast.temperature,
                            settings,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 7日預報 Widget
class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final AppSettings settings;

  const DailyForecastWidget({
    super.key,
    required this.forecasts,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7日預報',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...forecasts.map((forecast) {
              final weekday = _getWeekday(forecast.date.weekday);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        weekday,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      forecast.condition.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Spacer(),
                    Text(
                      FormatHelper.formatTemperatureShort(
                        forecast.lowTemperature,
                        settings,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      FormatHelper.formatTemperatureShort(
                        forecast.highTemperature,
                        settings,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return '週一';
      case 2:
        return '週二';
      case 3:
        return '週三';
      case 4:
        return '週四';
      case 5:
        return '週五';
      case 6:
        return '週六';
      case 7:
        return '週日';
      default:
        return '';
    }
  }
}
