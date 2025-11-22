import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/screen/setttings/bloc/settings_event.dart';
import 'package:weather/screen/setttings/bloc/settings_state.dart';
import 'package:weather/data/models/settings_model.dart';
import 'package:weather/services/settings_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;

  SettingsBloc({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService(),
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTemperatureUnit>(_onToggleTemperatureUnit);
    on<ToggleTimeFormat>(_onToggleTimeFormat);
    on<ChangeTheme>(_onChangeTheme);
    on<ToggleNotifications>(_onToggleNotifications);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    // 記錄開始時間
    final startTime = DateTime.now();

    try {
      final settings = await _settingsService.loadSettings();

      // 計算已經過的時間
      final elapsed = DateTime.now().difference(startTime);
      final remainingTime = const Duration(milliseconds: 500) - elapsed;

      // 如果還沒到 0.5 秒，等待剩餘時間
      if (remainingTime.inMilliseconds > 0) {
        await Future.delayed(remainingTime);
      }

      emit(SettingsLoaded(settings));
    } catch (e) {
      // 確保錯誤狀態也至少顯示 0.5 秒
      final elapsed = DateTime.now().difference(startTime);
      final remainingTime = const Duration(milliseconds: 500) - elapsed;

      if (remainingTime.inMilliseconds > 0) {
        await Future.delayed(remainingTime);
      }

      emit(SettingsError('載入設定失敗: ${e.toString()}'));
      // 載入失敗時返回預設設定
      emit(SettingsLoaded(AppSettings()));
    }
  }

  Future<void> _onToggleTemperatureUnit(
    ToggleTemperatureUnit event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(useCelsius: event.useCelsius);

      emit(SettingsSaving(newSettings));

      try {
        final success = await _settingsService.saveSettings(newSettings);
        if (success) {
          emit(SettingsLoaded(newSettings));
        } else {
          emit(const SettingsError('儲存溫度單位設定失敗'));
          emit(SettingsLoaded(currentSettings));
        }
      } catch (e) {
        emit(SettingsError('儲存溫度單位設定失敗: ${e.toString()}'));
        emit(SettingsLoaded(currentSettings));
      }
    }
  }

  Future<void> _onToggleTimeFormat(
    ToggleTimeFormat event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(use24HourFormat: event.use24HourFormat);

      emit(SettingsSaving(newSettings));

      try {
        final success = await _settingsService.saveSettings(newSettings);
        if (success) {
          emit(SettingsLoaded(newSettings));
        } else {
          emit(const SettingsError('儲存時間格式設定失敗'));
          emit(SettingsLoaded(currentSettings));
        }
      } catch (e) {
        emit(SettingsError('儲存時間格式設定失敗: ${e.toString()}'));
        emit(SettingsLoaded(currentSettings));
      }
    }
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(theme: event.theme);

      emit(SettingsSaving(newSettings));

      try {
        final success = await _settingsService.saveSettings(newSettings);
        if (success) {
          emit(SettingsLoaded(newSettings));
        } else {
          emit(const SettingsError('儲存主題設定失敗'));
          emit(SettingsLoaded(currentSettings));
        }
      } catch (e) {
        emit(SettingsError('儲存主題設定失敗: ${e.toString()}'));
        emit(SettingsLoaded(currentSettings));
      }
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentSettings = (state as SettingsLoaded).settings;
      final newSettings = currentSettings.copyWith(enableNotifications: event.enableNotifications);

      emit(SettingsSaving(newSettings));

      try {
        final success = await _settingsService.saveSettings(newSettings);
        if (success) {
          emit(SettingsLoaded(newSettings));
        } else {
          emit(const SettingsError('儲存通知設定失敗'));
          emit(SettingsLoaded(currentSettings));
        }
      } catch (e) {
        emit(SettingsError('儲存通知設定失敗: ${e.toString()}'));
        emit(SettingsLoaded(currentSettings));
      }
    }
  }
}
