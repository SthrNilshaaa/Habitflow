import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  static Future<String> getBackupPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/habitflow_backup.hive';
  }

  static Future<void> backupToFile() async {
    final box = await Hive.openBox('habits');
    final backupPath = await getBackupPath();
    final file = File(box.path!);
    await file.copy(backupPath);
  }

  static Future<void> restoreFromFile() async {
    final box = await Hive.openBox('habits');
    final backupPath = await getBackupPath();
    final file = File(backupPath);
    if (await file.exists()) {
      await file.copy(box.path!);
      await box.close();
      await Hive.openBox('habits');
    }
  }

  static Future<void> importData() async {
    // Placeholder implementation
    // In a real app, this would import data from a file
    await Future.delayed(const Duration(seconds: 1));
  }
} 