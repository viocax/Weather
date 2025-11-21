import 'package:weather/data/models/settings_model.dart';

/// 格式化輔助工具類
class FormatHelper {
  /// 將攝氏溫度轉換為華氏溫度
  /// 公式: F = C × 9/5 + 32
  static double celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  /// 將華氏溫度轉換為攝氏溫度
  /// 公式: C = (F - 32) × 5/9
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// 根據設定格式化溫度
  /// 返回帶單位的溫度字串，例如: "25°C" 或 "77°F"
  static String formatTemperature(double temperature, AppSettings settings) {
    if (settings.useCelsius) {
      return '${temperature.toInt()}°C';
    } else {
      final fahrenheit = celsiusToFahrenheit(temperature);
      return '${fahrenheit.toInt()}°F';
    }
  }

  /// 根據設定格式化溫度（不帶單位）
  /// 僅返回數字和度數符號，例如: "25°" 或 "77°"
  static String formatTemperatureShort(double temperature, AppSettings settings) {
    if (settings.useCelsius) {
      return '${temperature.toInt()}°';
    } else {
      final fahrenheit = celsiusToFahrenheit(temperature);
      return '${fahrenheit.toInt()}°';
    }
  }

  /// 獲取溫度單位符號
  static String getTemperatureUnit(AppSettings settings) {
    return settings.useCelsius ? '°C' : '°F';
  }

  /// 格式化時間
  /// 根據設定返回 12 小時制或 24 小時制
  static String formatTime(DateTime time, AppSettings settings) {
    if (settings.use24HourFormat) {
      // 24 小時制
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      // 12 小時制
      final hour = time.hour == 0
          ? 12
          : time.hour > 12
              ? time.hour - 12
              : time.hour;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// 格式化小時（用於小時預報）
  /// 返回格式如: "14時" 或 "2 PM"
  static String formatHour(DateTime time, AppSettings settings) {
    if (settings.use24HourFormat) {
      return '${time.hour}時';
    } else {
      final hour = time.hour == 0
          ? 12
          : time.hour > 12
              ? time.hour - 12
              : time.hour;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour $period';
    }
  }
}
