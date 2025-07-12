import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> scheduleHabitReminder(Habit habit) async {
    if (!habit.isReminderOn || habit.reminderTime == null) return;

    await initialize();

    // Parse reminder time (format: "10:00 AM")
    final timeParts = habit.reminderTime!.split(' ');
    final time = timeParts[0].split(':');
    final isPM = timeParts[1].toUpperCase() == 'PM';
    
    int hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    // Cancel existing notifications for this habit
    await cancelHabitReminder(habit.id);

    // Schedule main reminder notification
    await _notifications.zonedSchedule(
      habit.id.hashCode, // Main reminder ID
      'Habit Reminder',
      'Time to complete: ${habit.name}',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Daily habit completion reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
      ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Schedule 3-minute before reminder
    final threeMinBefore = _nextInstanceOfTime(hour, minute).subtract(const Duration(minutes: 3));
    if (threeMinBefore.isAfter(tz.TZDateTime.now(tz.local))) {
      await _notifications.zonedSchedule(
        habit.id.hashCode + 100, // 3-min before ID
        'Habit Reminder (3 min)',
        '${habit.name} in 3 minutes!',
        threeMinBefore,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders_early',
            'Early Habit Reminders',
            channelDescription: '3-minute early habit reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    // Schedule 2-minute after missed notification
    final twoMinAfter = _nextInstanceOfTime(hour, minute).add(const Duration(minutes: 2));
    await _notifications.zonedSchedule(
      habit.id.hashCode + 200, // 2-min after ID
      'Habit Missed',
      'You missed: ${habit.name}. Don\'t give up!',
      twoMinAfter,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_missed',
          'Missed Habits',
          channelDescription: 'Notifications for missed habits',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelHabitReminder(String habitId) async {
    // Cancel all notifications for this habit
    await _notifications.cancel(habitId.hashCode); // Main reminder
    await _notifications.cancel(habitId.hashCode + 100); // 3-min before
    await _notifications.cancel(habitId.hashCode + 200); // 2-min after
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  static Future<void> showCompletionNotification(Habit habit) async {
    await initialize();

    await _notifications.show(
      habit.id.hashCode + 1000, // Different ID for completion notifications
      'Habit Completed! 🎉',
      'Great job completing: ${habit.name}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_completions',
          'Habit Completions',
          channelDescription: 'Notifications for completed habits',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showMissedHabitNotification(Habit habit) async {
    await initialize();

    await _notifications.show(
      habit.id.hashCode + 2000, // Different ID for missed notifications
      'Habit Missed 😔',
      'You missed: ${habit.name}. Don\'t give up!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_missed',
          'Missed Habits',
          channelDescription: 'Notifications for missed habits',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // Method to check if a habit was missed and show notification
  static Future<void> checkAndNotifyMissedHabit(Habit habit) async {
    if (!habit.isReminderOn || habit.reminderTime == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if habit was completed today
    final completedToday = habit.history.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);

    if (!completedToday) {
      // Parse reminder time to get the target time today
      final timeParts = habit.reminderTime!.split(' ');
      final time = timeParts[0].split(':');
      final isPM = timeParts[1].toUpperCase() == 'PM';
      
      int hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      final targetTime = DateTime(today.year, today.month, today.day, hour, minute);
      
      // If it's past the target time and not completed, show missed notification
      if (now.isAfter(targetTime.add(const Duration(minutes: 2)))) {
        await showMissedHabitNotification(habit);
      }
    }
  }
}
