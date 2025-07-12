import 'package:hive/hive.dart';
part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int iconIndex;
  
  @HiveField(3)
  int colorIndex;
  
  @HiveField(4)
  String frequency; // 'daily', 'weekly', 'custom'
  
  @HiveField(5)
  String? reminderTime; // e.g. '10:00 AM'
  
  @HiveField(6)
  bool isReminderOn;
  
  @HiveField(7)
  String type; // e.g. 'Fitness', 'Mindfulness', etc.
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  List<DateTime> history; // Dates when completed
  
  @HiveField(10)
  String? description;
  
  @HiveField(11)
  int targetDays; // Target days for completion
  
  @HiveField(12)
  bool isActive; // Whether habit is active or paused
  
  @HiveField(13)
  bool isFavorite; // Whether habit is marked as favorite

  Habit({
    required this.id,
    required this.name,
    required this.iconIndex,
    required this.colorIndex,
    required this.frequency,
    this.reminderTime,
    this.isReminderOn = false,
    required this.type,
    required this.createdAt,
    List<DateTime>? history,
    this.description,
    this.targetDays = 30,
    this.isActive = true,
    this.isFavorite = false,
  }) : history = history ?? [];

  // Calculate completion rate
  double get completionRate {
    if (targetDays == 0) return 0.0;
    return (history.length / targetDays).clamp(0.0, 1.0);
  }

  // Get current streak
  int get currentStreak {
    if (history.isEmpty) return 0;
    
    final today = DateTime.now();
    final sortedDates = history.map((d) => DateTime(d.year, d.month, d.day)).toList()..sort();
    
    int streak = 0;
    DateTime? currentDate = DateTime(today.year, today.month, today.day);
    
    while (sortedDates.contains(currentDate)) {
      streak++;
      currentDate = currentDate!.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  // Get longest streak
  int get longestStreak {
    if (history.isEmpty) return 0;
    
    final sortedDates = history.map((d) => DateTime(d.year, d.month, d.day)).toList()..sort();
    int maxStreak = 0;
    int currentStreak = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final daysDiff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (daysDiff == 1) {
        currentStreak++;
      } else {
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        currentStreak = 1;
      }
    }
    
    return maxStreak > currentStreak ? maxStreak : currentStreak;
  }

  // Check if completed today
  bool get isCompletedToday {
    final today = DateTime.now();
    return history.any((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    );
  }

  // Get days since last completion
  int get daysSinceLastCompletion {
    if (history.isEmpty) return 0;
    
    final lastCompletion = history.last;
    final today = DateTime.now();
    return today.difference(lastCompletion).inDays;
  }

  // Get weekly completion count
  int getWeeklyCompletionCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return history.where((date) {
      return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             date.isBefore(weekStart.add(const Duration(days: 7)));
    }).length;
  }

  // Get monthly completion count
  int getMonthlyCompletionCount() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return history.where((date) {
      return date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
             date.isBefore(monthEnd.add(const Duration(days: 1)));
    }).length;
  }
} 