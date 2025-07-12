import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) => HabitNotifier());

class HabitNotifier extends StateNotifier<List<Habit>> {
  final HiveService _hiveService = HiveService();
  
  HabitNotifier() : super([]) {
    loadHabits();
    _initializeNotifications();
  }

  void loadHabits() {
    state = _hiveService.getHabits();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
    await NotificationService.initializeMissedHabitChecking();
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

  Future<void> markCompleted(String habitId, DateTime date) async {
    final habitIndex = state.indexWhere((h) => h.id == habitId);
    if (habitIndex != -1) {
      final habit = state[habitIndex];
      final updatedHabit = Habit(
        id: habit.id,
        name: habit.name,
        iconIndex: habit.iconIndex,
        colorIndex: habit.colorIndex,
        frequency: habit.frequency,
        reminderTime: habit.reminderTime,
        isReminderOn: habit.isReminderOn,
        type: habit.type,
        createdAt: habit.createdAt,
        history: [...habit.history, date],
        description: habit.description,
        targetDays: habit.targetDays,
        isActive: habit.isActive,
        isFavorite: habit.isFavorite,
      );
      
      await _hiveService.updateHabit(updatedHabit);
      loadHabits();
      
      // Show completion notification
      await NotificationService.showCompletionNotification(updatedHabit);
    }
  }

  Future<void> markUncompleted(String habitId, DateTime date) async {
    final habitIndex = state.indexWhere((h) => h.id == habitId);
    if (habitIndex != -1) {
      final habit = state[habitIndex];
      final updatedHistory = habit.history.where((d) => 
        d.year != date.year || d.month != date.month || d.day != date.day
      ).toList();
      
      final updatedHabit = Habit(
        id: habit.id,
        name: habit.name,
        iconIndex: habit.iconIndex,
        colorIndex: habit.colorIndex,
        frequency: habit.frequency,
        reminderTime: habit.reminderTime,
        isReminderOn: habit.isReminderOn,
        type: habit.type,
        createdAt: habit.createdAt,
        history: updatedHistory,
        description: habit.description,
        targetDays: habit.targetDays,
        isActive: habit.isActive,
        isFavorite: habit.isFavorite,
      );
      
      await _hiveService.updateHabit(updatedHabit);
      loadHabits();
    }
  }

  Future<void> toggleHabitActive(String habitId) async {
    final habitIndex = state.indexWhere((h) => h.id == habitId);
    if (habitIndex != -1) {
      final habit = state[habitIndex];
      final updatedHabit = Habit(
        id: habit.id,
        name: habit.name,
        iconIndex: habit.iconIndex,
        colorIndex: habit.colorIndex,
        frequency: habit.frequency,
        reminderTime: habit.reminderTime,
        isReminderOn: habit.isReminderOn,
        type: habit.type,
        createdAt: habit.createdAt,
        history: habit.history,
        description: habit.description,
        targetDays: habit.targetDays,
        isActive: !habit.isActive,
        isFavorite: habit.isFavorite,
      );
      
      await _hiveService.updateHabit(updatedHabit);
      loadHabits();
    }
  }

  Future<void> toggleHabitFavorite(String habitId) async {
    final habitIndex = state.indexWhere((h) => h.id == habitId);
    if (habitIndex != -1) {
      final habit = state[habitIndex];
      final updatedHabit = Habit(
        id: habit.id,
        name: habit.name,
        iconIndex: habit.iconIndex,
        colorIndex: habit.colorIndex,
        frequency: habit.frequency,
        reminderTime: habit.reminderTime,
        isReminderOn: habit.isReminderOn,
        type: habit.type,
        createdAt: habit.createdAt,
        history: habit.history,
        description: habit.description,
        targetDays: habit.targetDays,
        isActive: habit.isActive,
        isFavorite: !habit.isFavorite,
      );
      
      await _hiveService.updateHabit(updatedHabit);
      loadHabits();
    }
  }

  // Check for missed habits periodically
  Future<void> checkForMissedHabits() async {
    await NotificationService.checkForMissedHabits(state);
  }

  Map<String, dynamic> getStatistics() {
    if (state.isEmpty) {
      return {
        'totalHabits': 0,
        'completedToday': 0,
        'totalCompletions': 0,
        'averageStreak': 0.0,
        'completionRate': 0.0,
      };
    }

    final completedToday = state.where((h) => h.isCompletedToday).length;
    final totalCompletions = state.fold<int>(0, (sum, h) => sum + h.history.length);
    final averageStreak = state.map((h) => h.currentStreak).reduce((a, b) => a + b) / state.length;
    final completionRate = state.isNotEmpty ? completedToday / state.length : 0.0;

    return {
      'totalHabits': state.length,
      'completedToday': completedToday,
      'totalCompletions': totalCompletions,
      'averageStreak': averageStreak,
      'completionRate': completionRate,
    };
  }
} 