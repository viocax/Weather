// 天氣狀況
enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  snowy,
  stormy;

  String get description {
    switch (this) {
      case WeatherCondition.sunny:
        return '晴';
      case WeatherCondition.cloudy:
        return '陰';
      case WeatherCondition.rainy:
        return '雨';
      case WeatherCondition.snowy:
        return '雪';
      case WeatherCondition.stormy:
        return '暴風雨';
    }
  }

  String get icon {
    switch (this) {
      case WeatherCondition.sunny:
        return '☀️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.snowy:
        return '❄️';
      case WeatherCondition.stormy:
        return '⛈️';
    }
  }
}

// 當前天氣資料
class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final WeatherCondition condition;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final DateTime sunrise;
  final DateTime sunset;
  final String location;

  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.sunrise,
    required this.sunset,
    required this.location,
  });
}

// 每小時預報
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final WeatherCondition condition;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
  });
}

// 每日預報
class DailyForecast {
  final DateTime date;
  final double highTemperature;
  final double lowTemperature;
  final WeatherCondition condition;

  DailyForecast({
    required this.date,
    required this.highTemperature,
    required this.lowTemperature,
    required this.condition,
  });
}
