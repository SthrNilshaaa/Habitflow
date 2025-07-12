import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app.dart';
import 'models/habit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data for notifications
  tz.initializeTimeZones();
  
  await Hive.initFlutter();
  
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
      // Ignore delete errors
    }
    
    // Create a new box
    await Hive.openBox('habits');
  }
  
  runApp(const ProviderScope(child: App()));
}
