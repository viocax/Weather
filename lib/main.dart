import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/data/models/home_tabbar_type.dart';

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
  HomeTabbarType _currentTab = HomeTabbarType.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentTab.page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab.index,
        onTap: (index) {
          setState(() {
            _currentTab = HomeTabbarType.values[index];
          });
        },
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