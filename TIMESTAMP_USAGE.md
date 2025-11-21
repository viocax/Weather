# HomeScreen 時間戳記錄功能使用指南

## 功能概述

此功能會自動記錄使用者進入和離開 HomeScreen tab 的時間戳，並可以計算使用者在 HomeScreen 停留的時間。

## 如何運作

### 1. Tab 切換偵測 (`main.dart`)

在 `_HomeTabbarState` 中，我們追蹤 tab 的切換：

```dart
void _onTabChanged(int index) {
  final previousTab = _currentTab;
  final newTab = HomeTabbarType.values[index];

  // 離開 HomeScreen
  if (previousTab == HomeTabbarType.home && newTab != HomeTabbarType.home) {
    _settingsService.saveLastExitTimestamp();
    debugPrint('離開 HomeScreen tab - ${DateTime.now()}');

    // 可以獲取停留時間
    _settingsService.getHomeScreenDuration().then((duration) {
      if (duration != null) {
        debugPrint('在 HomeScreen 停留了 $duration 秒');
      }
    });
  }

  // 進入 HomeScreen
  if (newTab == HomeTabbarType.home && previousTab != HomeTabbarType.home) {
    _settingsService.saveLastEnterTimestamp();
    debugPrint('進入 HomeScreen tab - ${DateTime.now()}');
  }

  setState(() {
    _currentTab = newTab;
  });
}
```

### 2. 可用的 API

#### `saveLastEnterTimestamp()`
儲存進入 HomeScreen 的時間戳。

```dart
final service = SettingsService();
await service.saveLastEnterTimestamp();
```

#### `saveLastExitTimestamp()`
儲存離開 HomeScreen 的時間戳。

```dart
await service.saveLastExitTimestamp();
```

#### `getLastEnterTimestamp()`
獲取最後一次進入 HomeScreen 的時間。

```dart
final enterTime = await service.getLastEnterTimestamp();
if (enterTime != null) {
  print('最後進入時間: $enterTime');
}
```

#### `getLastExitTimestamp()`
獲取最後一次離開 HomeScreen 的時間。

```dart
final exitTime = await service.getLastExitTimestamp();
if (exitTime != null) {
  print('最後離開時間: $exitTime');
}
```

#### `getHomeScreenDuration()`
計算在 HomeScreen 停留的時間（秒）。

```dart
final duration = await service.getHomeScreenDuration();
if (duration != null) {
  print('停留了 $duration 秒');
  print('停留了 ${duration / 60} 分鐘');
}
```

#### `clearTimestamps()`
清除所有時間戳記錄。

```dart
await service.clearTimestamps();
```

## 使用範例

### 範例 1: 在設定頁面顯示統計資訊

```dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  DateTime? _lastExitTime;
  int? _lastDuration;

  @override
  void initState() {
    super.initState();
    _loadTimestamps();
  }

  Future<void> _loadTimestamps() async {
    final exitTime = await _settingsService.getLastExitTimestamp();
    final duration = await _settingsService.getHomeScreenDuration();

    setState(() {
      _lastExitTime = exitTime;
      _lastDuration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('統計資訊')),
      body: ListView(
        children: [
          ListTile(
            title: Text('最後離開時間'),
            subtitle: Text(_lastExitTime?.toString() ?? '無記錄'),
          ),
          ListTile(
            title: Text('停留時間'),
            subtitle: Text(_lastDuration != null
              ? '$_lastDuration 秒 (${_lastDuration! / 60} 分鐘)'
              : '無記錄'),
          ),
        ],
      ),
    );
  }
}
```

### 範例 2: 追蹤使用者行為

```dart
// 記錄使用者何時離開 HomeScreen
void trackUserBehavior() async {
  final service = SettingsService();

  // 獲取最後的時間資訊
  final exitTime = await service.getLastExitTimestamp();
  final enterTime = await service.getLastEnterTimestamp();
  final duration = await service.getHomeScreenDuration();

  if (exitTime != null && duration != null) {
    // 可以將這些資料發送到分析服務
    analytics.logEvent(
      name: 'home_screen_exit',
      parameters: {
        'exit_time': exitTime.toIso8601String(),
        'duration_seconds': duration,
      },
    );
  }
}
```

### 範例 3: 根據停留時間顯示不同訊息

```dart
void showMessageBasedOnDuration() async {
  final service = SettingsService();
  final duration = await service.getHomeScreenDuration();

  if (duration == null) {
    print('歡迎首次使用！');
  } else if (duration < 10) {
    print('您剛才快速瀏覽了天氣資訊');
  } else if (duration < 60) {
    print('您查看了 $duration 秒的天氣資訊');
  } else {
    print('您仔細研究了天氣情況！');
  }
}
```

## 測試

執行以下命令來測試時間戳功能：

```bash
flutter test test/timestamp_test.dart
```

測試涵蓋：
- ✅ 儲存和讀取時間戳
- ✅ 計算停留時間
- ✅ 清除時間戳
- ✅ 多次儲存覆蓋
- ✅ 異常情況處理
- ✅ 持久化儲存

## 除錯

在開發模式下，您會在控制台看到以下輸出：

```
離開 HomeScreen tab - 2024-01-15 10:30:45.123
在 HomeScreen 停留了 127 秒
進入 HomeScreen tab - 2024-01-15 10:35:12.456
```

## 注意事項

1. **時間戳持久化**: 所有時間戳都儲存在 SharedPreferences 中，即使關閉 app 也會保留。

2. **單例模式**: SettingsService 使用單例模式，確保整個 app 共用同一個實例。

3. **精確度**: 時間戳使用毫秒級精度 (`millisecondsSinceEpoch`)。

4. **停留時間計算**: 只有當進入時間早於離開時間時，才會返回有效的停留時間。

5. **Tab 切換**: 只記錄在 BottomNavigationBar 中切換 tab 的行為，不包括 app 進入背景等情況。

## 未來擴展建議

1. **多次訪問記錄**: 可以將單一時間戳擴展為歷史記錄列表。

2. **統計分析**: 記錄每日/每週的總停留時間。

3. **使用模式**: 分析使用者最常訪問的時段。

4. **通知提醒**: 根據使用習慣推送天氣提醒。

## 相關文件

- `lib/services/settings_service.dart` - SettingsService 實作
- `lib/main.dart` - Tab 切換追蹤
- `test/timestamp_test.dart` - 單元測試
