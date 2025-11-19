import 'package:weather/core/config.dart';
import 'package:weather/core/network/api_request.dart';
import 'package:weather/data/models/weather_model.dart';

class GetForecastRequest with ApiRequestMixin<ForecastData> {
  final double lat;
  final double lon;
  final int days;

  GetForecastRequest({
    required this.lat,
    required this.lon,
    this.days = 7,
  });

  @override
  String get baseUrl => AppConfig.weatherRestfulHost;

  @override
  String get path => '/forecast.json';

  @override
  String get method => 'GET';

  @override
  Map<String, dynamic>? get parameters => {
    'key': AppConfig.weatherApiKey,
    'q': '$lat,$lon',
    'days': days,
    'aqi': 'no',
    'alerts': 'no',
  };

  @override
  ForecastData convert(Map<String, dynamic> json) {
    final forecastDays = json['forecast']['forecastday'] as List;

    // 解析每小時預報
    final hourlyForecasts = <HourlyForecast>[];
    for (final day in forecastDays) {
      final hours = day['hour'] as List;
      for (final hour in hours) {
        hourlyForecasts.add(HourlyForecast(
          time: DateTime.parse(hour['time'] as String),
          temperature: (hour['temp_c'] as num).toDouble(),
          condition: WeatherCondition.parseCondition(hour['condition']['code'] as int),
        ));
      }
    }

    // 解析每日預報
    final dailyForecasts = forecastDays.map<DailyForecast>((day) {
      final dayData = day['day'];
      return DailyForecast(
        date: DateTime.parse(day['date'] as String),
        highTemperature: (dayData['maxtemp_c'] as num).toDouble(),
        lowTemperature: (dayData['mintemp_c'] as num).toDouble(),
        condition: WeatherCondition.parseCondition(dayData['condition']['code'] as int),
      );
    }).toList();

    return ForecastData(
      hourly: hourlyForecasts,
      daily: dailyForecasts,
    );
  }
}
