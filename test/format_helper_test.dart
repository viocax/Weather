import 'package:flutter_test/flutter_test.dart';
import 'package:weather/data/models/settings_model.dart';
import 'package:weather/utils/format_helper.dart';

void main() {
  group('FormatHelper 溫度轉換測試', () {
    test('攝氏轉華氏應該正確', () {
      expect(FormatHelper.celsiusToFahrenheit(0), 32);
      expect(FormatHelper.celsiusToFahrenheit(100), 212);
      expect(FormatHelper.celsiusToFahrenheit(25), 77);
      expect(FormatHelper.celsiusToFahrenheit(-40), -40);
    });

    test('華氏轉攝氏應該正確', () {
      expect(FormatHelper.fahrenheitToCelsius(32), 0);
      expect(FormatHelper.fahrenheitToCelsius(212), 100);
      expect(FormatHelper.fahrenheitToCelsius(77), 25);
      expect(FormatHelper.fahrenheitToCelsius(-40), -40);
    });

    test('攝氏和華氏轉換應該可逆', () {
      const celsius = 25.0;
      final fahrenheit = FormatHelper.celsiusToFahrenheit(celsius);
      final backToCelsius = FormatHelper.fahrenheitToCelsius(fahrenheit);
      expect(backToCelsius, closeTo(celsius, 0.0001));
    });
  });

  group('FormatHelper 溫度格式化測試', () {
    test('使用攝氏時應該返回攝氏溫度', () {
      final settings = AppSettings(useCelsius: true);
      expect(FormatHelper.formatTemperature(25, settings), '25°C');
      expect(FormatHelper.formatTemperature(0, settings), '0°C');
      expect(FormatHelper.formatTemperature(-5, settings), '-5°C');
    });

    test('使用華氏時應該返回華氏溫度', () {
      final settings = AppSettings(useCelsius: false);
      expect(FormatHelper.formatTemperature(25, settings), '77°F');
      expect(FormatHelper.formatTemperature(0, settings), '32°F');
      expect(FormatHelper.formatTemperature(-40, settings), '-40°F');
    });

    test('短格式應該只有度數符號', () {
      final celsiusSettings = AppSettings(useCelsius: true);
      final fahrenheitSettings = AppSettings(useCelsius: false);

      expect(FormatHelper.formatTemperatureShort(25, celsiusSettings), '25°');
      expect(FormatHelper.formatTemperatureShort(25, fahrenheitSettings), '77°');
    });

    test('獲取溫度單位應該正確', () {
      final celsiusSettings = AppSettings(useCelsius: true);
      final fahrenheitSettings = AppSettings(useCelsius: false);

      expect(FormatHelper.getTemperatureUnit(celsiusSettings), '°C');
      expect(FormatHelper.getTemperatureUnit(fahrenheitSettings), '°F');
    });
  });

  group('FormatHelper 時間格式化測試', () {
    test('24小時制應該顯示正確', () {
      final settings = AppSettings(use24HourFormat: true);
      final time1 = DateTime(2024, 1, 1, 9, 30);
      final time2 = DateTime(2024, 1, 1, 14, 45);
      final time3 = DateTime(2024, 1, 1, 0, 0);

      expect(FormatHelper.formatTime(time1, settings), '09:30');
      expect(FormatHelper.formatTime(time2, settings), '14:45');
      expect(FormatHelper.formatTime(time3, settings), '00:00');
    });

    test('12小時制應該顯示正確', () {
      final settings = AppSettings(use24HourFormat: false);
      final time1 = DateTime(2024, 1, 1, 9, 30);
      final time2 = DateTime(2024, 1, 1, 14, 45);
      final time3 = DateTime(2024, 1, 1, 0, 0);
      final time4 = DateTime(2024, 1, 1, 12, 0);

      expect(FormatHelper.formatTime(time1, settings), '09:30 AM');
      expect(FormatHelper.formatTime(time2, settings), '02:45 PM');
      expect(FormatHelper.formatTime(time3, settings), '12:00 AM');
      expect(FormatHelper.formatTime(time4, settings), '12:00 PM');
    });

    test('小時格式化（24小時制）應該正確', () {
      final settings = AppSettings(use24HourFormat: true);
      final time1 = DateTime(2024, 1, 1, 9, 0);
      final time2 = DateTime(2024, 1, 1, 14, 0);
      final time3 = DateTime(2024, 1, 1, 0, 0);

      expect(FormatHelper.formatHour(time1, settings), '9時');
      expect(FormatHelper.formatHour(time2, settings), '14時');
      expect(FormatHelper.formatHour(time3, settings), '0時');
    });

    test('小時格式化（12小時制）應該正確', () {
      final settings = AppSettings(use24HourFormat: false);
      final time1 = DateTime(2024, 1, 1, 9, 0);
      final time2 = DateTime(2024, 1, 1, 14, 0);
      final time3 = DateTime(2024, 1, 1, 0, 0);
      final time4 = DateTime(2024, 1, 1, 12, 0);

      expect(FormatHelper.formatHour(time1, settings), '9 AM');
      expect(FormatHelper.formatHour(time2, settings), '2 PM');
      expect(FormatHelper.formatHour(time3, settings), '12 AM');
      expect(FormatHelper.formatHour(time4, settings), '12 PM');
    });
  });

  group('FormatHelper 邊界情況測試', () {
    test('極端溫度值應該正確處理', () {
      final celsiusSettings = AppSettings(useCelsius: true);
      final fahrenheitSettings = AppSettings(useCelsius: false);

      // 絕對零度
      expect(FormatHelper.formatTemperature(-273.15, celsiusSettings), '-273°C');

      // 極高溫度
      expect(FormatHelper.formatTemperature(1000, celsiusSettings), '1000°C');
      expect(FormatHelper.formatTemperature(1000, fahrenheitSettings), '1832°F');
    });

    test('小數溫度應該正確四捨五入', () {
      final settings = AppSettings(useCelsius: true);

      expect(FormatHelper.formatTemperature(25.4, settings), '25°C');
      expect(FormatHelper.formatTemperature(25.5, settings), '25°C');
      expect(FormatHelper.formatTemperature(25.9, settings), '25°C');
    });

    test('午夜和正午時間應該正確處理', () {
      final settings = AppSettings(use24HourFormat: false);

      final midnight = DateTime(2024, 1, 1, 0, 0);
      final noon = DateTime(2024, 1, 1, 12, 0);
      final oneAM = DateTime(2024, 1, 1, 1, 0);
      final onePM = DateTime(2024, 1, 1, 13, 0);

      expect(FormatHelper.formatTime(midnight, settings), '12:00 AM');
      expect(FormatHelper.formatTime(noon, settings), '12:00 PM');
      expect(FormatHelper.formatTime(oneAM, settings), '01:00 AM');
      expect(FormatHelper.formatTime(onePM, settings), '01:00 PM');
    });
  });
}
