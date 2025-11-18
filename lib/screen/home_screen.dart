import 'package:flutter/material.dart';
import 'package:weather/data/models/weather_model.dart';
import 'package:weather/data/service/location_service.dart';
import 'package:weather/widgets/gradient_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  LocationData? _locationData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final location = await _locationService.getCurrentLocation();

    setState(() {
      _isLoading = false;
      if (location != null) {
        _locationData = location;
      } else {
        _errorMessage = '無法取得位置資訊';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 模擬天氣資料
    final currentWeather = CurrentWeather(
      temperature: 25,
      feelsLike: 27,
      condition: WeatherCondition.sunny,
      humidity: 65,
      windSpeed: 12,
      pressure: 1013,
      sunrise: DateTime(2024, 1, 1, 6, 30),
      sunset: DateTime(2024, 1, 1, 17, 45),
      location: _locationData != null
          ? '${_locationData!.latitude.toStringAsFixed(2)}, ${_locationData!.longitude.toStringAsFixed(2)}'
          : '取得位置中...',
    );

    final hourlyForecast = List.generate(24, (index) {
      return HourlyForecast(
        time: DateTime.now().add(Duration(hours: index)),
        temperature: 20 + (index % 10).toDouble(),
        condition: WeatherCondition.values[index % 5],
      );
    });

    final dailyForecast = List.generate(7, (index) {
      return DailyForecast(
        date: DateTime.now().add(Duration(days: index)),
        highTemperature: 28 + (index % 5).toDouble(),
        lowTemperature: 18 + (index % 3).toDouble(),
        condition: WeatherCondition.values[index % 5],
      );
    });

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: _isLoading
              ? const Text('取得位置中...')
              : Text(currentWeather.location),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadLocation,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLocation,
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        CurrentWeatherWidget(weather: currentWeather),
                        const SizedBox(height: 16),
                        HourlyForecastWidget(forecasts: hourlyForecast),
                        const SizedBox(height: 16),
                        DailyForecastWidget(forecasts: dailyForecast),
                      ],
                    ),
                  ),
      ),
    );
  }
}

// 當前位置天氣 Widget
class CurrentWeatherWidget extends StatelessWidget {
  final CurrentWeather weather;

  const CurrentWeatherWidget({super.key, required this.weather});

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
                      '${weather.temperature.toInt()}°C',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '體感 ${weather.feelsLike.toInt()}°C',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
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
                  '${weather.sunrise.hour.toString().padLeft(2, '0')}:${weather.sunrise.minute.toString().padLeft(2, '0')}',
                ),
                _buildInfoItem(
                  '日落',
                  '${weather.sunset.hour.toString().padLeft(2, '0')}:${weather.sunset.minute.toString().padLeft(2, '0')}',
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// 24小時預報 Widget
class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> forecasts;

  const HourlyForecastWidget({super.key, required this.forecasts});

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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${forecast.time.hour}時',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          forecast.condition.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${forecast.temperature.toInt()}°',
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

  const DailyForecastWidget({super.key, required this.forecasts});

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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                      '${forecast.lowTemperature.toInt()}°',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${forecast.highTemperature.toInt()}°',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
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
