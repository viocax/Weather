import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/services/settings_service.dart';

void main() {
  group('時間戳記錄測試', () {
    setUp(() async {
      // 在每個測試前清空 SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    test('儲存和讀取離開時間戳', () async {
      final service = SettingsService();
      await service.initialize();

      // 儲存時間戳
      final saveResult = await service.saveLastExitTimestamp();
      expect(saveResult, true);

      // 讀取時間戳
      final timestamp = await service.getLastExitTimestamp();
      expect(timestamp, isNotNull);
      expect(timestamp, isA<DateTime>());

      // 確認時間戳是最近的（不超過 1 秒前）
      final now = DateTime.now();
      final difference = now.difference(timestamp!).inSeconds;
      expect(difference, lessThan(2));
    });

    test('儲存和讀取進入時間戳', () async {
      final service = SettingsService();
      await service.initialize();

      // 儲存時間戳
      final saveResult = await service.saveLastEnterTimestamp();
      expect(saveResult, true);

      // 讀取時間戳
      final timestamp = await service.getLastEnterTimestamp();
      expect(timestamp, isNotNull);
      expect(timestamp, isA<DateTime>());

      // 確認時間戳是最近的
      final now = DateTime.now();
      final difference = now.difference(timestamp!).inSeconds;
      expect(difference, lessThan(2));
    });

    test('計算停留時間', () async {
      final service = SettingsService();
      await service.initialize();

      // 儲存進入時間
      await service.saveLastEnterTimestamp();

      // 等待 1 秒
      await Future.delayed(const Duration(seconds: 1));

      // 儲存離開時間
      await service.saveLastExitTimestamp();

      // 計算停留時間
      final duration = await service.getHomeScreenDuration();
      expect(duration, isNotNull);
      expect(duration, greaterThanOrEqualTo(1));
      expect(duration, lessThan(3)); // 應該在 1-3 秒之間
    });

    test('當沒有時間戳時應該返回 null', () async {
      final service = SettingsService();
      await service.initialize();

      final exitTime = await service.getLastExitTimestamp();
      final enterTime = await service.getLastEnterTimestamp();
      final duration = await service.getHomeScreenDuration();

      expect(exitTime, isNull);
      expect(enterTime, isNull);
      expect(duration, isNull);
    });

    test('清除時間戳應該成功', () async {
      final service = SettingsService();
      await service.initialize();

      // 先儲存一些時間戳
      await service.saveLastEnterTimestamp();
      await service.saveLastExitTimestamp();

      // 確認時間戳存在
      var exitTime = await service.getLastExitTimestamp();
      var enterTime = await service.getLastEnterTimestamp();
      expect(exitTime, isNotNull);
      expect(enterTime, isNotNull);

      // 清除時間戳
      final clearResult = await service.clearTimestamps();
      expect(clearResult, true);

      // 確認時間戳已被清除
      exitTime = await service.getLastExitTimestamp();
      enterTime = await service.getLastEnterTimestamp();
      expect(exitTime, isNull);
      expect(enterTime, isNull);
    });

    test('多次儲存應該覆蓋舊的時間戳', () async {
      final service = SettingsService();
      await service.initialize();

      // 第一次儲存
      await service.saveLastExitTimestamp();
      final firstTimestamp = await service.getLastExitTimestamp();

      // 等待一下
      await Future.delayed(const Duration(milliseconds: 100));

      // 第二次儲存
      await service.saveLastExitTimestamp();
      final secondTimestamp = await service.getLastExitTimestamp();

      expect(firstTimestamp, isNotNull);
      expect(secondTimestamp, isNotNull);
      expect(secondTimestamp!.isAfter(firstTimestamp!), true);
    });

    test('當離開時間早於進入時間，停留時間應該返回 null', () async {
      final service = SettingsService();
      await service.initialize();

      // 先儲存離開時間
      await service.saveLastExitTimestamp();

      // 等待一下
      await Future.delayed(const Duration(milliseconds: 100));

      // 再儲存進入時間（這是不正常的情況）
      await service.saveLastEnterTimestamp();

      // 停留時間應該返回 null
      final duration = await service.getHomeScreenDuration();
      expect(duration, isNull);
    });

    test('時間戳應該持久化儲存', () async {
      // 第一個服務實例
      final service1 = SettingsService();
      await service1.initialize();
      await service1.saveLastExitTimestamp();

      final timestamp1 = await service1.getLastExitTimestamp();

      // 模擬重新啟動 - 使用同樣的 SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedTimestamp = prefs.getInt('last_exit_timestamp');

      expect(storedTimestamp, isNotNull);
      expect(
        DateTime.fromMillisecondsSinceEpoch(storedTimestamp!),
        timestamp1,
      );
    });
  });
}
