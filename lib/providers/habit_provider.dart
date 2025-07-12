import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) => HabitNotifier());

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HiveService _hiveService = HiveService();
  
  HabitNotifier() : super([]) {
    loadHabits();
  }

  void loadHabits() {
    state = _hiveService.getHabits();
    _updateStreaks();
  }

  void _updateStreaks() {
    for (final habit in state) {
      habit.updateStreaks();
    }
  }

  Future<void> addHabit(Habit habit) async {
    await _hiveService.addHabit(habit);
    loadHabits();
    
    // Schedule notification if reminder is enabled
    if (habit.isReminderOn && habit.reminderTime != null) {
      await NotificationService.scheduleHabitReminder(habit);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    await _hiveService.updateHabit(habit);
    loadHabits();
    
    // Update notification if reminder is enabled
    if (habit.isReminderOn && habit.reminderTime != null) {
      await NotificationService.scheduleHabitReminder(habit);
    } else {
      await NotificationService.cancelHabitReminder(habit.id);
    }
  }

  Future<void> deleteHabit(String id) async {
    await NotificationService.cancelHabitReminder(id);
    await _hiveService.deleteHabit(id);
    loadHabits();
  }

  Future<void> markCompleted(String id, DateTime date) async {
    final habitIndex = state.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;
    
    final habit = state[habitIndex];
    if (!habit.isCompletedToday) {
    habit.history.add(date);
      habit.updateStreaks();
      await _hiveService.updateHabit(habit);
      loadHabits();
      
      // Show completion notification
      await NotificationService.showCompletionNotification(habit);
    }
  }

  Future<void> markUncompleted(String id, DateTime date) async {
    final habitIndex = state.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;
    
    final habit = state[habitIndex];
    final targetDate = DateTime(date.year, date.month, date.day);
    
    habit.history.removeWhere((d) => 
      d.year == targetDate.year && 
      d.month == targetDate.month && 
      d.day == targetDate.day
    );
    
    habit.updateStreaks();
    await _hiveService.updateHabit(habit);
    loadHabits();
  }

  Future<void> toggleHabitActive(String id) async {
    final habitIndex = state.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;
    
    final habit = state[habitIndex];
    habit.isActive = !habit.isActive;
    await _hiveService.updateHabit(habit);
    loadHabits();
  }

  // Get habits by type
  List<Habit> getHabitsByType(String type) {
    return state.where((habit) => habit.type == type).toList();
  }

  // Get active habits
  List<Habit> getActiveHabits() {
    return state.where((habit) => habit.isActive).toList();
  }

  // Get completed habits today
  List<Habit> getCompletedToday() {
    return state.where((habit) => habit.isCompletedToday).toList();
  }

  // Get habits due today
  List<Habit> getDueToday() {
    return state.where((habit) => 
      habit.isActive && 
      !habit.isCompletedToday
    ).toList();
  }

  // Get habits with longest streaks
  List<Habit> getTopStreaks({int limit = 5}) {
    final sortedHabits = List<Habit>.from(state);
    sortedHabits.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    return sortedHabits.take(limit).toList();
  }

  // Get habits with most completions
  List<Habit> getMostCompleted({int limit = 5}) {
    final sortedHabits = List<Habit>.from(state);
    sortedHabits.sort((a, b) => b.history.length.compareTo(a.history.length));
    return sortedHabits.take(limit).toList();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final activeHabits = getActiveHabits();
    final completedToday = getCompletedToday();
    final totalCompletions = state.fold<int>(0, (sum, habit) => sum + habit.history.length);
    final totalStreaks = state.fold<int>(0, (sum, habit) => sum + habit.currentStreak);
    final longestStreak = state.fold<int>(0, (max, habit) => 
      habit.longestStreak > max ? habit.longestStreak : max
    );
    final averageStreak = state.isEmpty ? 0.0 : 
      state.fold<int>(0, (sum, habit) => sum + habit.currentStreak) / state.length;

    return {
      'totalHabits': state.length,
      'activeHabits': activeHabits.length,
      'completedToday': completedToday.length,
      'totalCompletions': totalCompletions,
      'totalStreaks': totalStreaks,
      'longestStreak': longestStreak,
      'averageStreak': averageStreak,
      'completionRate': activeHabits.isEmpty ? 0.0 : 
        (completedToday.length / activeHabits.length),
      'topStreaks': getTopStreaks(limit: 3),
      'mostCompleted': getMostCompleted(limit: 3),
    };
  }

  // Check for missed habits and show notifications
  Future<void> checkMissedHabits() async {
    for (final habit in state) {
      if (habit.isActive && habit.isReminderOn && habit.reminderTime != null) {
        await NotificationService.checkAndNotifyMissedHabit(habit);
      }
    }
  }

  // Get weekly activity data
  Map<String, int> getWeeklyActivity() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final Map<String, int> weeklyData = {};
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      int completions = 0;
      
      for (final habit in state) {
        if (habit.history.any((d) => 
          d.year == date.year && 
          d.month == date.month && 
          d.day == date.day
        )) {
          completions++;
        }
      }
      
      weeklyData[dayName] = completions;
    }
    
    return weeklyData;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Mon';
    }
  }
} 