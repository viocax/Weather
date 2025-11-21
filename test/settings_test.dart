import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/data/models/settings_model.dart';
import 'package:weather/services/settings_service.dart';

void main() {
  group('SettingsService 測試', () {
    setUp(() async {
      // 在每個測試前清空 SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('初始化應該載入預設設定', () async {
      final service = SettingsService();
      await service.initialize();

      final settings = service.currentSettings;
      expect(settings.useCelsius, true);
      expect(settings.use24HourFormat, true);
      expect(settings.theme, 'system');
      expect(settings.enableNotifications, true);
    });

    test('儲存設定應該成功', () async {
      final service = SettingsService();
      await service.initialize();

      final newSettings = AppSettings(
        useCelsius: false,
        use24HourFormat: false,
        theme: 'dark',
        enableNotifications: false,
      );

      final success = await service.saveSettings(newSettings);
      expect(success, true);
      expect(service.currentSettings, newSettings);
    });

    test('載入設定應該返回之前儲存的設定', () async {
      // 第一次儲存設定
      final service1 = SettingsService();
      await service1.initialize();

      final savedSettings = AppSettings(
        useCelsius: false,
        use24HourFormat: false,
        theme: 'light',
        enableNotifications: false,
      );

      await service1.saveSettings(savedSettings);

      // 創建新的服務實例來模擬重新載入
      final prefs = await SharedPreferences.getInstance();
      final useCelsius = prefs.getBool('useCelsius');
      final use24HourFormat = prefs.getBool('use24HourFormat');
      final theme = prefs.getString('theme');
      final enableNotifications = prefs.getBool('enableNotifications');

      expect(useCelsius, false);
      expect(use24HourFormat, false);
      expect(theme, 'light');
      expect(enableNotifications, false);
    });

    test('更新單個設定應該只改變指定的值', () async {
      final service = SettingsService();
      await service.initialize();

      await service.updateSetting(useCelsius: false);

      final settings = service.currentSettings;
      expect(settings.useCelsius, false);
      expect(settings.use24HourFormat, true); // 應該保持預設值
      expect(settings.theme, 'system'); // 應該保持預設值
    });

    test('重置為預設設定應該恢復所有預設值', () async {
      final service = SettingsService();
      await service.initialize();

      // 先修改設定
      await service.saveSettings(AppSettings(
        useCelsius: false,
        use24HourFormat: false,
        theme: 'dark',
        enableNotifications: false,
      ));

      // 重置
      await service.resetToDefaults();

      final settings = service.currentSettings;
      expect(settings.useCelsius, true);
      expect(settings.use24HourFormat, true);
      expect(settings.theme, 'system');
      expect(settings.enableNotifications, true);
    });

    test('清除所有設定應該移除所有儲存的值', () async {
      final service = SettingsService();
      await service.initialize();

      await service.saveSettings(AppSettings(
        useCelsius: false,
        use24HourFormat: false,
        theme: 'dark',
        enableNotifications: false,
      ));

      final hasSettingsBefore = await service.hasSettings();
      expect(hasSettingsBefore, true);

      await service.clearAllSettings();

      final hasSettingsAfter = await service.hasSettings();
      expect(hasSettingsAfter, false);
    });
  });

  group('AppSettings 測試', () {
    test('toJson 應該返回正確的 Map', () {
      final settings = AppSettings(
        useCelsius: false,
        use24HourFormat: false,
        theme: 'dark',
        enableNotifications: false,
      );

      final json = settings.toJson();
      expect(json['useCelsius'], false);
      expect(json['use24HourFormat'], false);
      expect(json['theme'], 'dark');
      expect(json['enableNotifications'], false);
    });

    test('fromJson 應該正確建立 AppSettings', () {
      final json = {
        'useCelsius': false,
        'use24HourFormat': false,
        'theme': 'light',
        'enableNotifications': false,
      };

      final settings = AppSettings.fromJson(json);
      expect(settings.useCelsius, false);
      expect(settings.use24HourFormat, false);
      expect(settings.theme, 'light');
      expect(settings.enableNotifications, false);
    });

    test('copyWith 應該只更新指定的屬性', () {
      final original = AppSettings();
      final updated = original.copyWith(useCelsius: false);

      expect(updated.useCelsius, false);
      expect(updated.use24HourFormat, true);
      expect(updated.theme, 'system');
      expect(updated.enableNotifications, true);
    });

    test('相等運算子應該正確比較兩個 AppSettings', () {
      final settings1 = AppSettings(
        useCelsius: false,
        use24HourFormat: false,
        theme: 'dark',
        enableNotifications: false,
      );

      final settings2 = AppSettings(
        useCelsius: false,
        use24HourFormat: false,
        theme: 'dark',
        enableNotifications: false,
      );

      final settings3 = AppSettings();

      expect(settings1 == settings2, true);
      expect(settings1 == settings3, false);
    });

    test('toString 應該返回有意義的字串', () {
      final settings = AppSettings();
      final str = settings.toString();

      expect(str, contains('AppSettings'));
      expect(str, contains('useCelsius'));
      expect(str, contains('use24HourFormat'));
      expect(str, contains('theme'));
      expect(str, contains('enableNotifications'));
    });
  });
}
