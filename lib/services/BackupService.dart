import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/global_var/globals.dart';

import 'dart:io';
import 'package:path/path.dart' as p;

enum BackupFrequency { none, daily, weekly, monthly }

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  static String get _backupConfigPath {
    if (kIsWeb) return '';
    return p.join(Platform.environment['APPDATA'] ?? '.', 'hussam', 'backup_config.txt');
  }

  static String get _lastBackupTimePath {
    if (kIsWeb) return '';
    return p.join(Platform.environment['APPDATA'] ?? '.', 'hussam', 'last_backup.txt');
  }

  BackupFrequency _frequency = BackupFrequency.none;
  DateTime? _lastBackup;

  BackupFrequency get frequency => _frequency;
  DateTime? get lastBackup => _lastBackup;

  Future<void> loadConfig() async {
    if (kIsWeb) return;
    try {
      final file = File(_backupConfigPath);
      if (await file.exists()) {
        final freqStr = (await file.readAsString()).trim();
        _frequency = BackupFrequency.values.firstWhere(
          (e) => e.toString().split('.').last == freqStr,
          orElse: () => BackupFrequency.none,
        );
      }

      final lastBackupFile = File(_lastBackupTimePath);
      if (await lastBackupFile.exists()) {
        final timeStr = (await lastBackupFile.readAsString()).trim();
        if (timeStr.isNotEmpty) {
          _lastBackup = DateTime.tryParse(timeStr);
        }
      }
    } catch (e) {
      print('Error loading backup config: $e');
    }
  }

  Future<void> setFrequency(BackupFrequency freq) async {
    _frequency = freq;
    if (kIsWeb) return;
    try {
      final file = File(_backupConfigPath);
      final parent = Directory(p.dirname(_backupConfigPath));
      if (!parent.existsSync()) parent.createSync(recursive: true);
      await file.writeAsString(freq.toString().split('.').last);
    } catch (e) {
      print('Error saving backup config: $e');
    }
  }

  Future<void> _updateLastBackupTime() async {
    _lastBackup = DateTime.now();
    if (kIsWeb) return;
    try {
      final file = File(_lastBackupTimePath);
      final parent = Directory(p.dirname(_lastBackupTimePath));
      if (!parent.existsSync()) parent.createSync(recursive: true);
      await file.writeAsString(_lastBackup!.toIso8601String());
    } catch (e) {
      print('Error saving last backup time: $e');
    }
  }

  Future<bool> createBackup({bool isManual = false}) async {
    try {
      if (kIsWeb) return false;
      
      final dbDir = Directory(extDbFolder);
      if (!await dbDir.exists()) return false;

      final dbFiles = await dbDir.list().where((f) => f is File && f.path.endsWith('.db')).toList();
      if (dbFiles.isEmpty) return false;

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
      
      final backupDir = Directory(p.join(appRootPath, 'backups', 'backup_${dateStr}_$timeStr'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      int successCount = 0;
      for (var file in dbFiles) {
        final dbFile = file as File;
        final dbName = p.basename(dbFile.path);
        final backupPath = p.join(backupDir.path, dbName);
        
        try {
          await dbFile.copy(backupPath);
          successCount++;
        } catch (e) {
          print('Error backing up $dbName: $e');
        }
      }
      
      if (successCount > 0) {
        await _updateLastBackupTime();
        return true;
      }
      return false;
    } catch (e) {
      print('Backup error: $e');
      return false;
    }
  }

  Future<void> checkAutoBackup() async {
    if (_frequency == BackupFrequency.none || kIsWeb) return;

    final now = DateTime.now();
    bool shouldBackup = false;

    if (_lastBackup == null) {
      shouldBackup = true;
    } else {
      final diff = now.difference(_lastBackup!);
      switch (_frequency) {
        case BackupFrequency.daily:
          if (diff.inDays >= 1) shouldBackup = true;
          break;
        case BackupFrequency.weekly:
          if (diff.inDays >= 7) shouldBackup = true;
          break;
        case BackupFrequency.monthly:
          if (diff.inDays >= 30) shouldBackup = true;
          break;
        case BackupFrequency.none:
          break;
      }
    }

    if (shouldBackup) {
      await createBackup();
    }
  }
}
