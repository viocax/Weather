import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleTemperatureUnit extends SettingsEvent {
  final bool useCelsius;

  const ToggleTemperatureUnit(this.useCelsius);

  @override
  List<Object?> get props => [useCelsius];
}

class ToggleTimeFormat extends SettingsEvent {
  final bool use24HourFormat;

  const ToggleTimeFormat(this.use24HourFormat);

  @override
  List<Object?> get props => [use24HourFormat];
}

class ChangeTheme extends SettingsEvent {
  final String theme;

  const ChangeTheme(this.theme);

  @override
  List<Object?> get props => [theme];
}

class ToggleNotifications extends SettingsEvent {
  final bool enableNotifications;

  const ToggleNotifications(this.enableNotifications);

  @override
  List<Object?> get props => [enableNotifications];
}
