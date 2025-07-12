import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool dailyReminder;
  final bool habitReminders;
  final TimeOfDay reminderTime;
  final String language;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.dailyReminder = false,
    this.habitReminders = true,
    this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.language = 'en',
  });

  SettingsState copyWith({
    ThemeMode? themeMode, 
    bool? dailyReminder, 
    bool? habitReminders,
    TimeOfDay? reminderTime,
    String? language
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      habitReminders: habitReminders ?? this.habitReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      language: language ?? this.language,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier());

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);
  void setDailyReminder(bool value) => state = state.copyWith(dailyReminder: value);
  void setHabitReminders(bool value) => state = state.copyWith(habitReminders: value);
  void setReminderTime(TimeOfDay time) => state = state.copyWith(reminderTime: time);
  void setLanguage(String lang) => state = state.copyWith(language: lang);
  
  void clearAllData() {
    // Reset to default values
    state = SettingsState();
  }
} 