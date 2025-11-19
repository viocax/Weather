import 'package:flutter/material.dart';
import 'package:weather/data/models/weather_model.dart';
import 'package:weather/data/request/get_hourly_forecast_request.dart';
import 'package:weather/data/request/get_weather_request.dart';
import 'package:weather/data/service/location_service.dart';
import 'package:weather/widgets/gradient_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  CurrentWeather? curretnWeather;
  List<HourlyForecast> hourlyForecast = [];
  List<DailyForecast> dailyForecast = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // 先取得位置
    final location = await _locationService.getCurrentLocation();

    if (!mounted) return;
    if (location == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '無法取得位置資訊';
      });
      return;
    }

    // 再取得天氣資料
    try {
      final getCurrentWeather = GetWeatherRequest(
        lat: location.latitude,
        lon: location.longitude,
      );
      final getForecast = GetForecastRequest(
        lat: location.latitude,
        lon: location.longitude,
      );
      final weatherResponse = await getCurrentWeather.request();
      final forecastResponse = await getForecast.request();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (weatherResponse.statusCode == 200) {
          curretnWeather = weatherResponse.model;
          hourlyForecast = forecastResponse.model.hourly;
          dailyForecast = forecastResponse.model.daily;
          debugPrint('Weather API Response: $curretnWeather');
          _errorMessage = null;
        } else {
          _errorMessage = 'API 錯誤: ${weatherResponse.statusCode}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '取得天氣資料失敗: $e';
      });
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: _isLoading
              ? const Text('取得位置中...')
              : Text(curretnWeather?.location ?? ''),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
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
                          onPressed: _loadData,
                          child: const Text('重試'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (curretnWeather != null)
                          CurrentWeatherWidget(weather: curretnWeather!),
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
