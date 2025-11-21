import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/data/models/home_tabbar_type.dart';
import 'package:weather/services/settings_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return _rootWidget(
        'Weather', 
        HomeTabbar(), 
        Theme.of(context).platform,
      );
  }
  Widget _rootWidget(String title, Widget home, TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
        return CupertinoApp(
          title: title,
          home: home,
        );
      default:
        return MaterialApp(
          title: title,
          home: home,
        );
    }
  }
}

class HomeTabbar extends StatefulWidget {
  const HomeTabbar({super.key});

  @override
  State<HomeTabbar> createState() => _HomeTabbarState();
}

class _HomeTabbarState extends State<HomeTabbar> {
  final SettingsService _settingsService = SettingsService();
  HomeTabbarType _currentTab = HomeTabbarType.home;

  @override
  void initState() {
    super.initState();
    // 初始化時記錄進入 HomeScreen
    if (_currentTab == HomeTabbarType.home) {
      _settingsService.saveLastEnterTimestamp();
    }
  }

  void _onTabChanged(int index) {
    final previousTab = _currentTab;
    final newTab = HomeTabbarType.values[index];

    // 如果從 HomeScreen 離開，記錄離開時間
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

    // 如果進入 HomeScreen，記錄進入時間
    if (newTab == HomeTabbarType.home && previousTab != HomeTabbarType.home) {
      _settingsService.saveLastEnterTimestamp();
      debugPrint('進入 HomeScreen tab - ${DateTime.now()}');
    }

    setState(() {
      _currentTab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentTab.page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index,
        onTap: _onTabChanged,
        items: HomeTabbarType.values.map((type) {
          return BottomNavigationBarItem(
            icon: Icon(type.icon),
            label: type.title,
          );
        }).toList(),
      ),
    );
  }
}