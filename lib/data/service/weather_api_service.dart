import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:weather/data/models/weather_model.dart';

class WeatherApiService {
  static const String _baseUrl = 'https://api.weatherapi.com/v1';
  final String _apiKey;
  final http.Client _client;

  WeatherApiService({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  // 取得當前天氣
  Future<CurrentWeather?> getCurrentWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/current.json?key=$_apiKey&q=$lat,$lon&aqi=no',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseCurrentWeather(data);
      } else {
        debugPrint('API 錯誤: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('取得天氣資料失敗: $e');
      return null;
    }
  }

  // 取得天氣預報 (包含每小時和每日)
  Future<WeatherForecast?> getForecast(double lat, double lon, {int days = 7}) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast.json?key=$_apiKey&q=$lat,$lon&days=$days&aqi=no&alerts=no',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseForecast(data);
      } else {
        debugPrint('API 錯誤: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('取得預報資料失敗: $e');
      return null;
    }
  }

  // 解析當前天氣
  CurrentWeather _parseCurrentWeather(Map<String, dynamic> data) {
    final current = data['current'];
    final location = data['location'];
    final astro = data['forecast']?['forecastday']?[0]?['astro'];

    return CurrentWeather(
      temperature: (current['temp_c'] as num).toDouble(),
      feelsLike: (current['feelslike_c'] as num).toDouble(),
      condition: _parseCondition(current['condition']['code'] as int),
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_kph'] as num).toDouble(),
      pressure: (current['pressure_mb'] as num).toDouble(),
      sunrise: _parseTime(astro?['sunrise'] ?? '06:00 AM'),
      sunset: _parseTime(astro?['sunset'] ?? '18:00 PM'),
      location: location['name'] as String,
    );
  }

  // 解析預報資料
  WeatherForecast _parseForecast(Map<String, dynamic> data) {
    final forecastDays = data['forecast']['forecastday'] as List;
    final location = data['location'];
    final current = data['current'];
    final astro = forecastDays.isNotEmpty ? forecastDays[0]['astro'] : null;

    // 解析每小時預報
    final hourlyForecasts = <HourlyForecast>[];
    for (final day in forecastDays) {
      final hours = day['hour'] as List;
      for (final hour in hours) {
        hourlyForecasts.add(HourlyForecast(
          time: DateTime.parse(hour['time'] as String),
          temperature: (hour['temp_c'] as num).toDouble(),
          condition: _parseCondition(hour['condition']['code'] as int),
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
        condition: _parseCondition(dayData['condition']['code'] as int),
      );
    }).toList();

    // 當前天氣
    final currentWeather = CurrentWeather(
      temperature: (current['temp_c'] as num).toDouble(),
      feelsLike: (current['feelslike_c'] as num).toDouble(),
      condition: _parseCondition(current['condition']['code'] as int),
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_kph'] as num).toDouble(),
      pressure: (current['pressure_mb'] as num).toDouble(),
      sunrise: _parseTime(astro?['sunrise'] ?? '06:00 AM'),
      sunset: _parseTime(astro?['sunset'] ?? '18:00 PM'),
      location: location['name'] as String,
    );

    return WeatherForecast(
      current: currentWeather,
      hourly: hourlyForecasts,
      daily: dailyForecasts,
    );
  }

  // 解析時間字串 (如 "06:30 AM")
  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (parts.length > 1) {
      if (parts[1] == 'PM' && hour != 12) {
        hour += 12;
      } else if (parts[1] == 'AM' && hour == 12) {
        hour = 0;
      }
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // 將 WeatherAPI 的 condition code 轉換為 WeatherCondition
  WeatherCondition _parseCondition(int code) {
    // WeatherAPI condition codes: https://www.weatherapi.com/docs/weather_conditions.json
    if (code == 1000) {
      return WeatherCondition.sunny;
    } else if (code >= 1003 && code <= 1009) {
      return WeatherCondition.cloudy;
    } else if (code >= 1063 && code <= 1201) {
      return WeatherCondition.rainy;
    } else if (code >= 1204 && code <= 1237) {
      return WeatherCondition.snowy;
    } else if (code >= 1273) {
      return WeatherCondition.stormy;
    }
    return WeatherCondition.cloudy;
  }

  void dispose() {
    _client.close();
  }
}

// 天氣預報資料模型
class WeatherForecast {
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherForecast({
    required this.current,
    required this.hourly,
    required this.daily,
  });
}
