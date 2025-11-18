import 'package:flutter/material.dart';
import 'package:weather/screen/home_screen.dart';

enum HomeTabbarType {
  home,
  search,
  settings;

  String get title {
    switch (this) {
      case HomeTabbarType.home:
        return '首頁';
      case HomeTabbarType.search:
        return '搜尋';
      case HomeTabbarType.settings:
        return '設定';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeTabbarType.home:
        return Icons.home;
      case HomeTabbarType.search:
        return Icons.search;
      case HomeTabbarType.settings:
        return Icons.settings;
    }
  }

  Widget get page {
    switch (this) {
      case HomeTabbarType.home:
        return const HomeScreen();
      case HomeTabbarType.search:
        return const Center(child: Text('搜尋'));
      case HomeTabbarType.settings:
        return const Center(child: Text('設定'));
    }
  }
}
