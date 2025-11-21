import 'package:flutter/material.dart';
import 'package:weather/data/models/settings_model.dart';
import 'package:weather/services/settings_service.dart';
import 'package:weather/widgets/gradient_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  AppSettings _settings = AppSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.loadSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      // 如果載入失敗，使用預設設定
      setState(() {
        _settings = AppSettings();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('載入設定失敗，使用預設設定')),
        );
      }
    }
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() {
      _settings = newSettings;
    });

    final success = await _settingsService.saveSettings(newSettings);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('儲存設定失敗')),
      );
    }
  }

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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _buildSectionHeader('溫度與時間'),
                  _buildSwitchTile(
                    title: '溫度單位',
                    subtitle: _settings.useCelsius ? '攝氏 (°C)' : '華氏 (°F)',
                    value: _settings.useCelsius,
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(useCelsius: value));
                    },
                  ),
                  _buildSwitchTile(
                    title: '時間格式',
                    subtitle: _settings.use24HourFormat ? '24 小時制' : '12 小時制',
                    value: _settings.use24HourFormat,
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(use24HourFormat: value));
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildSectionHeader('外觀'),
                  _buildThemeTile(),
                  const Divider(color: Colors.white24),
                  _buildSectionHeader('通知'),
                  _buildSwitchTile(
                    title: '啟用通知',
                    subtitle: _settings.enableNotifications ? '已開啟' : '已關閉',
                    value: _settings.enableNotifications,
                    onChanged: (value) {
                      _updateSettings(_settings.copyWith(enableNotifications: value));
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

  Widget _buildThemeTile() {
    return ListTile(
      title: const Text(
        '主題模式',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        _getThemeDisplayName(_settings.theme),
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () => _showThemeDialog(),
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

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('選擇主題'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('system', '跟隨系統'),
            _buildThemeOption('light', '淺色'),
            _buildThemeOption('dark', '深色'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String value, String label) {
    final isSelected = _settings.theme == value;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      title: Text(label),
      onTap: () {
        _updateSettings(_settings.copyWith(theme: value));
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
