import 'package:hive/hive.dart';
import '../models/habit.dart';

class HiveService {
  static final _habitBox = Hive.box('habits');

  List<Habit> getHabits() {
    return _habitBox.values.cast<Habit>().toList();
  }

  Future<void> addHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
  }

  Future<void> backupToFile(String path) async {
    await _habitBox.compact();
    await _habitBox.flush();
    // Copy box file to backup path (platform-specific)
  }

  Future<void> restoreFromFile(String path) async {
    // Replace box file with backup (platform-specific)
  }
} 