import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import '../services/export_service.dart';
import 'dart:ui';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final themeOptions = [
      {'label': 'Light', 'mode': ThemeMode.light, 'icon': Icons.light_mode},
      {'label': 'Dark', 'mode': ThemeMode.dark, 'icon': Icons.dark_mode},
      {'label': 'System', 'mode': ThemeMode.system, 'icon': Icons.brightness_auto},
    ];

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
                      const Color(0x66121212),
                      const Color(0x661E1E1E),
                      const Color(0x66242424),
                    ]
                  : const [
                      Color(0x66A1C4FD),
                      Color(0x66FBC2EB),
                      Color(0x66FDC2FB),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Settings',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDark 
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'App Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Theme Settings
                _buildSettingsSection(
                  'Appearance',
                  Icons.palette,
                  [
                    _buildThemeSelector(themeOptions, settings, notifier, isDark),
                  ],
                  isDark,
                ),
                const SizedBox(height: 20),

                // Notification Settings
                _buildSettingsSection(
                  'Notifications',
                  Icons.notifications,
                  [
                    _buildSwitchTile(
                      'Daily Reminders',
                      'Get reminded to complete your habits',
                      Icons.schedule,
                      settings.dailyReminder,
                      (value) => notifier.setDailyReminder(value),
                      isDark,
                    ),
                    _buildSwitchTile(
                      'Habit Reminders',
                      'Get notifications for individual habits',
                      Icons.alarm,
                      settings.habitReminders,
                      (value) => notifier.setHabitReminders(value),
                      isDark,
                    ),
                    _buildTimeTile(
                      'Reminder Time',
                      'Set when to receive daily reminders',
                      Icons.access_time,
                      settings.reminderTime,
                      (time) => notifier.setReminderTime(time),
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: 20),

                // Language Settings
                _buildSettingsSection(
                  'Language',
                  Icons.language,
                  [
                    _buildDropdownTile(
                      'App Language',
                      'Choose your preferred language',
                      Icons.translate,
                      settings.language,
                      ['English', 'Español', 'Français', 'Deutsch'],
                      ['en', 'es', 'fr', 'de'],
                      (value) => notifier.setLanguage(value),
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: 20),

                // Data Management
                _buildSettingsSection(
                  'Data Management',
                  Icons.storage,
                  [
                    _buildActionTile(
                      'Export Data',
                      'Backup your habits to a file',
                      Icons.file_download,
                      () => _exportData(context, ref),
                      isDark,
                    ),
                    _buildActionTile(
                      'Import Data',
                      'Restore habits from a backup file',
                      Icons.file_upload,
                      () => _importData(context, ref),
                      isDark,
                    ),
                    _buildActionTile(
                      'Clear All Data',
                      'Delete all habits and settings',
                      Icons.delete_forever,
                      () => _showClearDataDialog(context, ref),
                      isDark,
                      isDestructive: true,
                    ),
                  ],
                  isDark,
                ),
                const SizedBox(height: 20),

                // App Information
                _buildSettingsSection(
                  'About',
                  Icons.info,
                  [
                    _buildInfoTile(
                      'App Version',
                      '1.0.0',
                      Icons.app_settings_alt,
                      isDark,
                    ),
                    _buildInfoTile(
                      'Build Number',
                      '2024.1.0',
                      Icons.build,
                      isDark,
                    ),
                    _buildActionTile(
                      'Privacy Policy',
                      'Read our privacy policy',
                      Icons.privacy_tip,
                      () => _showPrivacyPolicy(context),
                      isDark,
                    ),
                    _buildActionTile(
                      'Terms of Service',
                      'Read our terms of service',
                      Icons.description,
                      () => _showTermsOfService(context),
                      isDark,
                    ),
                  ],
                  isDark,
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 70),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(List themeOptions, settings, notifier, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: themeOptions.map((opt) {
              final selected = settings.themeMode == opt['mode'];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: selected 
                      ? Colors.blueAccent.withOpacity(0.7) 
                      : (isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    opt['icon'] as IconData, 
                    color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  onPressed: () => notifier.setThemeMode(opt['mode'] as ThemeMode),
                  tooltip: opt['label'] as String,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
            inactiveThumbColor: isDark ? Colors.grey[600] : Colors.grey[300],
            inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String title, String subtitle, IconData icon, TimeOfDay time, Function(TimeOfDay) onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Builder(
        builder: (context) => InkWell(
          onTap: () async {
            final newTime = await showTimePicker(
              context: context,
            initialTime: time,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: isDark 
                      ? const ColorScheme.dark(primary: Colors.blueAccent)
                      : const ColorScheme.light(primary: Colors.blueAccent),
                ),
                child: child!,
              );
            },
          );
          if (newTime != null) {
            onChanged(newTime);
          }
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, IconData icon, String value, List<String> labels, List<String> values, Function(String) onChanged, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            items: labels.asMap().entries.map((entry) {
              return DropdownMenuItem(
                value: values[entry.key],
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (v) => onChanged(v ?? 'en'),
            underline: const SizedBox(),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: isDark 
                ? Colors.grey[900]!.withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap, bool isDark, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(
                icon, 
                color: isDestructive ? Colors.red : Colors.blueAccent, 
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive 
                            ? Colors.red 
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) async {
    try {
      await ExportService.exportData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _importData(BuildContext context, WidgetRef ref) async {
    try {
      await BackupService.importData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete all habits and settings? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all data
              ref.read(settingsProvider.notifier).clearAllData();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This app stores all data locally on your device and does not collect or transmit any personal information.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to use it responsibly and not to misuse any features. The app is provided "as is" without any warranties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 