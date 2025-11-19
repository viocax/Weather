import 'package:weather/core/config.dart';
import 'package:weather/core/network/api_request.dart';
import 'package:weather/core/network/network_response.dart';
import 'package:weather/data/models/weather_model.dart';

class GetWeatherRequest with ApiRequestMixin<CurrentWeather> {
  final double lat;
  final double lon;

  GetWeatherRequest({
    required this.lat,
    required this.lon,
  });

  @override
  String get baseUrl => AppConfig.weatherRestfulHost;

  @override
  String get path => '/current.json';

  @override
  String get method => 'GET';

  @override
  Map<String, dynamic>? get parameters => {
    'key': AppConfig.weatherApiKey,
    'q': '$lat,$lon',
    'aqi': 'no',
  };

  @override
  CurrentWeather convert(Map<String, dynamic> dictionary) {
    return CurrentWeather(
      temperature: (dictionary['current']['temp_c'] as num).toDouble(),
      feelsLike: (dictionary['current']['feelslike_c'] as num).toDouble(),
      condition: WeatherCondition.parseCondition(dictionary['current']['condition']['code'] as int),
      humidity: dictionary['current']['humidity'] as int,
      windSpeed: (dictionary['current']['wind_kph'] as num).toDouble(),
      pressure: (dictionary['current']['pressure_mb'] as num).toDouble(),
      sunrise: DateTime.now(),
      sunset: DateTime.now(),
      location: dictionary['location']['name'] as String,
    );
  }
}
