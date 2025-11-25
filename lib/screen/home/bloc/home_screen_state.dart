import 'package:equatable/equatable.dart';
import 'package:weather/data/models/settings_model.dart';
import 'package:weather/data/models/weather_model.dart';

abstract class HomeScreenState extends Equatable {
  const HomeScreenState();

  @override
  List<Object?> get props => [];
}

// 載入中狀態（無屬性）
class HomeScreenLoadingState extends HomeScreenState {
  const HomeScreenLoadingState();
}

// 錯誤狀態
class HomeScreenErrorState extends HomeScreenState {
  final String message;
  const HomeScreenErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// 載入完成狀態（有屬性）
class HomeScreenLoadedState extends HomeScreenState {
  final CurrentWeather? currentWeather;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final AppSettings settings;

  const HomeScreenLoadedState({
    this.currentWeather,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.settings,
  });

  @override
  List<Object?> get props => [
    currentWeather,
    hourlyForecast,
    dailyForecast,
    settings,
  ];

  HomeScreenLoadedState copyWith({
    CurrentWeather? currentWeather,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
    AppSettings? settings,
  }) {
    return HomeScreenLoadedState(
      currentWeather: currentWeather ?? this.currentWeather,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      settings: settings ?? this.settings,
    );
  }
}
