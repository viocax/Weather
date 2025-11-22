import 'package:equatable/equatable.dart';
import 'package:weather/data/models/settings_model.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsSaving extends SettingsState {
  final AppSettings settings;

  const SettingsSaving(this.settings);

  @override
  List<Object?> get props => [settings];
}
