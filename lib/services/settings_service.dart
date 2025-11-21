import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/data/models/settings_model.dart';

/// 設定服務 - 使用單例模式管理應用程式設定
/// 提供設定的載入、儲存、清除等功能
class SettingsService {
  // 單例模式
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // SharedPreferences 實例
  SharedPreferences? _prefs;

  // 當前設定
  AppSettings? _currentSettings;

  /// 初始化服務並載入設定
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  /// 載入設定
  Future<AppSettings> loadSettings() async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      final bool? useCelsius = _prefs!.getBool('useCelsius');
      final bool? use24HourFormat = _prefs!.getBool('use24HourFormat');
      final String? theme = _prefs!.getString('theme');
      final bool? enableNotifications = _prefs!.getBool('enableNotifications');

      _currentSettings = AppSettings(
        useCelsius: useCelsius ?? true,
        use24HourFormat: use24HourFormat ?? true,
        theme: theme ?? 'system',
        enableNotifications: enableNotifications ?? true,
      );

      return _currentSettings!;
    } catch (e) {
      // 如果載入失敗，返回預設設定
      _currentSettings = AppSettings();
      return _currentSettings!;
    }
  }

  /// 儲存設定
  Future<bool> saveSettings(AppSettings settings) async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      await _prefs!.setBool('useCelsius', settings.useCelsius);
      await _prefs!.setBool('use24HourFormat', settings.use24HourFormat);
      await _prefs!.setString('theme', settings.theme);
      await _prefs!.setBool('enableNotifications', settings.enableNotifications);

      _currentSettings = settings;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 更新單個設定值
  Future<bool> updateSetting<T>({
    bool? useCelsius,
    bool? use24HourFormat,
    String? theme,
    bool? enableNotifications,
  }) async {
    final current = _currentSettings ?? AppSettings();
    final updated = current.copyWith(
      useCelsius: useCelsius,
      use24HourFormat: use24HourFormat,
      theme: theme,
      enableNotifications: enableNotifications,
    );
    return await saveSettings(updated);
  }

  /// 獲取當前設定
  AppSettings get currentSettings => _currentSettings ?? AppSettings();

  /// 重置為預設設定
  Future<bool> resetToDefaults() async {
    return await saveSettings(AppSettings());
  }

  /// 清除所有設定
  Future<bool> clearAllSettings() async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      await _prefs!.remove('useCelsius');
      await _prefs!.remove('use24HourFormat');
      await _prefs!.remove('theme');
      await _prefs!.remove('enableNotifications');

      _currentSettings = AppSettings();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 獲取特定設定值
  Future<T?> getSetting<T>(String key) async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      return _prefs!.get(key) as T?;
    } catch (e) {
      return null;
    }
  }

  /// 檢查設定是否存在
  Future<bool> hasSettings() async {
    if (_prefs == null) {
      await initialize();
    }

    return _prefs!.containsKey('useCelsius') ||
        _prefs!.containsKey('use24HourFormat') ||
        _prefs!.containsKey('theme') ||
        _prefs!.containsKey('enableNotifications');
  }

  // ==================== 時間戳記錄功能 ====================

  /// 儲存最後離開 HomeScreen 的時間戳
  Future<bool> saveLastExitTimestamp() async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _prefs!.setInt('last_exit_timestamp', timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 獲取最後離開 HomeScreen 的時間戳
  Future<DateTime?> getLastExitTimestamp() async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      final timestamp = _prefs!.getInt('last_exit_timestamp');
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// 儲存進入 HomeScreen 的時間戳
  Future<bool> saveLastEnterTimestamp() async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _prefs!.setInt('last_enter_timestamp', timestamp);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 獲取進入 HomeScreen 的時間戳
  Future<DateTime?> getLastEnterTimestamp() async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      final timestamp = _prefs!.getInt('last_enter_timestamp');
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// 計算在 HomeScreen 停留的時間（秒）
  Future<int?> getHomeScreenDuration() async {
    final enterTime = await getLastEnterTimestamp();
    final exitTime = await getLastExitTimestamp();

    if (enterTime == null || exitTime == null) return null;
    if (exitTime.isBefore(enterTime)) return null;

    return exitTime.difference(enterTime).inSeconds;
  }

  /// 清除所有時間戳記錄
  Future<bool> clearTimestamps() async {
    if (_prefs == null) {
      await initialize();
    }

    try {
      await _prefs!.remove('last_exit_timestamp');
      await _prefs!.remove('last_enter_timestamp');
      return true;
    } catch (e) {
      return false;
    }
  }
}
