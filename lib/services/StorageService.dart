import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:path/path.dart' as p;
import 'package:hussam_clinc/db/dbhelper.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static String get _configFilePath {
    if (kIsWeb) return '';
    return p.join(Platform.environment['APPDATA'] ?? '.', 'hussam', 'root_path.txt');
  }

  static String get _dbConfigFilePath {
    if (kIsWeb) return '';
    return p.join(Platform.environment['APPDATA'] ?? '.', 'hussam', 'db_name.txt');
  }

  /// Loads the saved root path from disk
  Future<void> loadConfig() async {
    if (kIsWeb) return;
    try {
      // Load root path
      final file = File(_configFilePath);
      if (await file.exists()) {
        final path = (await file.readAsString()).trim();
        if (path.isNotEmpty && Directory(path).existsSync()) {
          appRootPath = path;
        }
      }

      // Load DB name
      final dbFile = File(_dbConfigFilePath);
      if (await dbFile.exists()) {
        final name = (await dbFile.readAsString()).trim();
        if (name.isNotEmpty) {
          selectedDbName = name;
        }
      }
    } catch (e) {
      print('Error loading config: $e');
    }
  }

  /// Saves the root path to disk
  Future<void> saveConfig(String path) async {
    if (kIsWeb) {
      appRootPath = path;
      return;
    }
    try {
      final file = File(_configFilePath);
      final parent = Directory(p.dirname(_configFilePath));
      if (!parent.existsSync()) parent.createSync(recursive: true);
      await file.writeAsString(path);
      appRootPath = path;
    } catch (e) {
      print('Error saving config: $e');
    }
  }

  /// Saves the DB name to disk
  Future<void> saveDbConfig(String name) async {
    if (kIsWeb) {
      selectedDbName = name;
      return;
    }
    try {
      final file = File(_dbConfigFilePath);
      final parent = Directory(p.dirname(_dbConfigFilePath));
      if (!parent.existsSync()) parent.createSync(recursive: true);
      await file.writeAsString(name);
      selectedDbName = name;
    } catch (e) {
      print('Error saving DB config: $e');
    }
  }

  /// Moves current data to a new location
  Future<bool> moveDataTo(String newRoot) async {
    try {
      final oldRoot = appRootPath;
      if (oldRoot == newRoot) return true;

      final newDir = Directory(newRoot);
      if (!newDir.existsSync()) newDir.createSync(recursive: true);

      // Close DB before moving
      await DbHelper().closeDB();

      // List of subfolders and files to move
      final itemsToMove = ['pic', 'db', 'files', 'reports', 'db.db'];

      for (var item in itemsToMove) {
        final oldItem = p.join(oldRoot, item);
        final newItem = p.join(newRoot, item);

        if (FileSystemEntity.typeSync(oldItem) !=
            FileSystemEntityType.notFound) {
          if (FileSystemEntity.isDirectorySync(oldItem)) {
            await _copyDirectory(Directory(oldItem), Directory(newItem));
          } else {
            await File(oldItem).copy(newItem);
          }
        }
      }

      // Save new config
      await saveConfig(newRoot);

      // Re-open DB will happen automatically on next call
      return true;
    } catch (e) {
      print('Error moving data: $e');
      return false;
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory(
            p.join(destination.absolute.path, p.basename(entity.path)));
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }
}
