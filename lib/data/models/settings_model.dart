import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool useCelsius;
  final bool use24HourFormat;
  final String theme; // 'light', 'dark', 'system'
  final bool enableNotifications;

  AppSettings({
    this.useCelsius = true,
    this.use24HourFormat = true,
    this.theme = 'system',
    this.enableNotifications = true,
  });

  AppSettings copyWith({
    bool? useCelsius,
    bool? use24HourFormat,
    String? theme,
    bool? enableNotifications,
  }) {
    return AppSettings(
      useCelsius: useCelsius ?? this.useCelsius,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      theme: theme ?? this.theme,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }

  // 轉換為 JSON Map
  Map<String, dynamic> toJson() {
    return {
      'useCelsius': useCelsius,
      'use24HourFormat': use24HourFormat,
      'theme': theme,
      'enableNotifications': enableNotifications,
    };
  }

  // 從 JSON Map 建立
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      useCelsius: json['useCelsius'] as bool? ?? true,
      use24HourFormat: json['use24HourFormat'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'system',
      enableNotifications: json['enableNotifications'] as bool? ?? true,
    );
  }

  // 儲存設定到 SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCelsius', useCelsius);
    await prefs.setBool('use24HourFormat', use24HourFormat);
    await prefs.setString('theme', theme);
    await prefs.setBool('enableNotifications', enableNotifications);
  }

  // 從 SharedPreferences 載入設定
  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      useCelsius: prefs.getBool('useCelsius') ?? true,
      use24HourFormat: prefs.getBool('use24HourFormat') ?? true,
      theme: prefs.getString('theme') ?? 'system',
      enableNotifications: prefs.getBool('enableNotifications') ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.useCelsius == useCelsius &&
        other.use24HourFormat == use24HourFormat &&
        other.theme == theme &&
        other.enableNotifications == enableNotifications;
  }

  @override
  int get hashCode {
    return Object.hash(
      useCelsius,
      use24HourFormat,
      theme,
      enableNotifications,
    );
  }

  @override
  String toString() {
    return 'AppSettings(useCelsius: $useCelsius, use24HourFormat: $use24HourFormat, theme: $theme, enableNotifications: $enableNotifications)';
  }
}
