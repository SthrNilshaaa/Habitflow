import 'dart:io';
import 'package:csv/csv.dart';
import '../models/habit.dart';

class ExportService {
  static Future<void> exportToCsv(List<Habit> habits, String path) async {
    List<List<dynamic>> rows = [
      ['Name', 'Type', 'Frequency', 'Created At', 'History'],
    ];
    for (final habit in habits) {
      rows.add([
        habit.name,
        habit.type,
        habit.frequency,
        habit.createdAt.toIso8601String(),
        habit.history.map((d) => d.toIso8601String()).join(';'),
      ]);
    }
    String csvData = const ListToCsvConverter().convert(rows);
    final file = File(path);
    await file.writeAsString(csvData);
  }

  static Future<void> exportData() async {
    // Placeholder implementation
    // In a real app, this would export data to a file
    await Future.delayed(const Duration(seconds: 1));
  }
} 