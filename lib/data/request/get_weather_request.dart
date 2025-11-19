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
  String get baseUrl => 'https://api.weatherapi.com/v1';

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
  Future<NetworkResponse<CurrentWeather>> fetch() async {
    // TODO: convert error
    return await this.request();
  }
}
