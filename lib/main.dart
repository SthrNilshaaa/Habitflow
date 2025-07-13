import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'models/habit.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Initialize timezone data for notifications
  tz.initializeTimeZones();
  
  // Register Hive adapters
  Hive.registerAdapter(HabitAdapter());
  
  try {
    // Try to open the box normally
    await Hive.openBox('habits');
  } catch (e) {
    // If there's an error, delete the old box and create a new one
    try {
      await Hive.deleteBoxFromDisk('habits');
    } catch (deleteError) {
      // Silently handle delete error
    }
    
    // Create a new box
  await Hive.openBox('habits');
    await FlutterDisplayMode.setHighRefreshRate();
  }

  
  runApp(const ProviderScope(child: App()));
}
