import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/screen/setttings/bloc/settings_bloc.dart';
import 'package:weather/screen/setttings/bloc/settings_event.dart';
import 'package:weather/screen/setttings/bloc/settings_state.dart';
import 'package:weather/widgets/gradient_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(const LoadSettings()),
      child: const _SettingsScreenView(),
    );
  }
}

class _SettingsScreenView extends StatelessWidget {
  const _SettingsScreenView();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('設定'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsLoaded || state is SettingsSaving) {
              final settings = state is SettingsLoaded
                  ? state.settings
                  : (state as SettingsSaving).settings;

              return ListView(
                children: [
                  _buildSectionHeader('溫度與時間'),
                  _buildSwitchTile(
                    context: context,
                    title: '溫度單位',
                    subtitle: settings.useCelsius ? '攝氏 (°C)' : '華氏 (°F)',
                    value: settings.useCelsius,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleTemperatureUnit(value));
                    },
                  ),
                  _buildSwitchTile(
                    context: context,
                    title: '時間格式',
                    subtitle: settings.use24HourFormat ? '24 小時制' : '12 小時制',
                    value: settings.use24HourFormat,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleTimeFormat(value));
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSectionHeader('外觀'),
                  _buildThemeTile(context, settings.theme),
                  const Divider(color: Colors.white24),
                  _buildSectionHeader('通知'),
                  _buildSwitchTile(
                    context: context,
                    title: '啟用通知',
                    subtitle: settings.enableNotifications ? '已開啟' : '已關閉',
                    value: settings.enableNotifications,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(ToggleNotifications(value));
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSectionHeader('關於'),
                  _buildInfoTile(
                    title: 'App 版本',
                    subtitle: '1.0.0',
                    icon: Icons.info_outline,
                  ),
                  _buildInfoTile(
                    title: '開發者',
                    subtitle: 'Weather App Team',
                    icon: Icons.code,
                  ),
                ],
              );
            }

            return const Center(
              child: Text(
                '無法載入設定',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: Colors.blue,
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, String currentTheme) {
    return ListTile(
      title: const Text(
        '主題模式',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        _getThemeDisplayName(currentTheme),
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () => _showThemeDialog(context, currentTheme),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return '淺色';
      case 'dark':
        return '深色';
      case 'system':
      default:
        return '跟隨系統';
    }
  }

  void _showThemeDialog(BuildContext context, String currentTheme) {
    final settingsBloc = context.read<SettingsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('選擇主題'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(dialogContext, settingsBloc, 'system', '跟隨系統', currentTheme),
            _buildThemeOption(dialogContext, settingsBloc, 'light', '淺色', currentTheme),
            _buildThemeOption(dialogContext, settingsBloc, 'dark', '深色', currentTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsBloc bloc,
    String value,
    String label,
    String currentTheme,
  ) {
    final isSelected = currentTheme == value;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(label),
      onTap: () {
        bloc.add(ChangeTheme(value));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
