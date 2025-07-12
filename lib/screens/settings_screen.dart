import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Custom animated glass background
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      colorScheme.surface.withValues(alpha: 0.4),
                      colorScheme.surface.withValues(alpha: 0.4),
                      colorScheme.primary.withValues(alpha: 0.1),
                    ]
                  : [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.secondary.withValues(alpha: 0.1),
                      colorScheme.surface.withValues(alpha: 0.8),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: isDark 
                  ? colorScheme.surface.withValues(alpha: 0.3)
                  : colorScheme.surface.withValues(alpha: 0.08),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            titleSpacing: 16,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Settings
                _buildSettingsSection(
                  'Appearance',
                  Icons.palette,
                  [
                    _buildThemeSelector(settings, isDark, colorScheme),
                  ],
                  isDark,
                  colorScheme,
                ),
                const SizedBox(height: 24),

                // Notification Settings
                _buildSettingsSection(
                  'Notifications',
                  Icons.notifications,
                  [
                    _buildNotificationSettings(settings, isDark, colorScheme),
                  ],
                  isDark,
                  colorScheme,
                ),
                const SizedBox(height: 24),

                // Language Settings
                _buildSettingsSection(
                  'Language',
                  Icons.language,
                  [
                    _buildLanguageSelector(settings, isDark, colorScheme),
                  ],
                  isDark,
                  colorScheme,
                ),
                const SizedBox(height: 24),

                // Data Management
                _buildSettingsSection(
                  'Data',
                  Icons.storage,
                  [
                    _buildDataManagement(isDark, colorScheme),
                  ],
                  isDark,
                  colorScheme,
                ),
                const SizedBox(height: 24),

                // About
                _buildSettingsSection(
                  'About',
                  Icons.info,
                  [
                    _buildAboutSection(isDark, colorScheme),
                  ],
                  isDark,
                  colorScheme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children, bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surface.withValues(alpha: isDark ? 0.1 : 0.15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(SettingsState settings, bool isDark, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildSettingTile(
          'Light Theme',
          Icons.wb_sunny,
          settings.themeMode == ThemeMode.light,
          () => ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.light),
          isDark,
          colorScheme,
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          'Dark Theme',
          Icons.nightlight_round,
          settings.themeMode == ThemeMode.dark,
          () => ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark),
          isDark,
          colorScheme,
        ),
        const SizedBox(height: 8),
        _buildSettingTile(
          'System Theme',
          Icons.settings_system_daydream,
          settings.themeMode == ThemeMode.system,
          () => ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.system),
          isDark,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(SettingsState settings, bool isDark, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildSwitchTile(
          'Daily Reminders',
          Icons.schedule,
          settings.dailyReminder,
          (value) => ref.read(settingsProvider.notifier).setDailyReminder(value),
          isDark,
          colorScheme,
        ),
        const SizedBox(height: 8),
        _buildSwitchTile(
          'Habit Reminders',
          Icons.notifications_active,
          settings.habitReminders,
          (value) => ref.read(settingsProvider.notifier).setHabitReminders(value),
          isDark,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(SettingsState settings, bool isDark, ColorScheme colorScheme) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
    ];

    return Column(
      children: languages.map((lang) {
        return _buildSettingTile(
          lang['name']!,
          Icons.language,
          settings.language == lang['code'],
          () => ref.read(settingsProvider.notifier).setLanguage(lang['code']!),
          isDark,
          colorScheme,
        );
      }).toList(),
    );
  }

  Widget _buildDataManagement(bool isDark, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildActionTile(
          'Export Data',
          Icons.download,
          () {
            // TODO: Implement export functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Export functionality coming soon!',
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                backgroundColor: colorScheme.primary,
              ),
            );
          },
          isDark,
          colorScheme,
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          'Clear All Data',
          Icons.delete_forever,
          () => _showClearDataDialog(colorScheme),
          isDark,
          colorScheme,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAboutSection(bool isDark, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildInfoTile(
          'Version',
          '1.0.0',
          Icons.info_outline,
          isDark,
          colorScheme,
        ),
        const SizedBox(height: 8),
        _buildInfoTile(
          'Developer',
          'HabitFlow Team',
          Icons.person,
          isDark,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, IconData icon, bool isSelected, VoidCallback onTap, bool isDark, ColorScheme colorScheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, Function(bool) onChanged, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap, bool isDark, ColorScheme colorScheme, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surface.withValues(alpha: 0.1),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? colorScheme.error : colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDestructive ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Clear All Data',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to clear all data? This action cannot be undone.',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).clearAllData();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All data cleared!',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  backgroundColor: colorScheme.primary,
                ),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
} 