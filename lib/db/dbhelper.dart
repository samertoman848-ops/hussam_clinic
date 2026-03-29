// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../global_var/globals.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper.internal();
  factory DbHelper() => _instance;
  DbHelper.internal();
  Database? _db;

  Future<void> copyAssetsDb(String path) async {
    ByteData data = await rootBundle.load('assets/db/db.db');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes);
    print('Successfully Copied DB to $path');
  }

  Future<void> backupDb(String fromPath, String toPath) async {
    ByteData data = await rootBundle.load(fromPath);
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(toPath).writeAsBytes(bytes);
    print('Successfully Backup DB');
  }

  Future<String> configuredDbPath() async {
    final path = join(extDbFolder, selectedDbName);
    final dir = Directory(dirname(path));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return path;
  }

  Completer<Database?>? _dbOpenCompleter;

  Future<Database?> openDb() async {
    if (kIsWeb) return null;
    if (_db != null && _db!.isOpen) return _db;
    if (_dbOpenCompleter != null) return _dbOpenCompleter!.future;

    _dbOpenCompleter = Completer<Database?>();

    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      String path = await configuredDbPath();
      if (await databaseExists(path) == false) {
        await copyAssetsDb(path);
      }

      _db = await openDatabase(
        path,
        onConfigure: (db) async {
          await db.execute('PRAGMA journal_mode=WAL');
          await db.execute('PRAGMA busy_timeout = 5000');
        },
      );

      // --- MIGRATIONS ---
      try {
        final res = await _db!.rawQuery("PRAGMA table_info('patients')");
        if (!res.any((row) => row['name'] == 'patient_mobile2')) {
          await _db!.execute("ALTER TABLE patients ADD COLUMN patient_mobile2 TEXT DEFAULT '';");
        }
        if (!res.any((row) => row['name'] == 'patient_fileNo')) {
          await _db!.execute("ALTER TABLE patients ADD COLUMN patient_fileNo TEXT;");
        }
        await _db!.execute("UPDATE patients SET patient_fileNo = patient_id WHERE patient_fileNo IS NULL OR patient_fileNo = '';");
      } catch (e) {
        print('Patients migration error: $e');
      }

      try {
        await _db!.execute('''
          CREATE TABLE IF NOT EXISTS treatment_plans (
            tp_id INTEGER PRIMARY KEY AUTOINCREMENT,
            tp_patient_id INTEGER NOT NULL,
            tp_tooth_number TEXT NOT NULL,
            tp_treatment_name TEXT NOT NULL,
            tp_treatment_date TEXT NOT NULL,
            tp_doctor_name TEXT,
            tp_is_completed INTEGER DEFAULT 0,
            tp_notes TEXT DEFAULT '',
            FOREIGN KEY(tp_patient_id) REFERENCES patients(patient_id)
          )
        ''');
      } catch (e) {
        print('TP creation error: $e');
      }

      try {
        await _db!.execute('''
          CREATE TABLE IF NOT EXISTS patient_invoices (
            inv_id INTEGER PRIMARY KEY AUTOINCREMENT,
            inv_treatment_plan_id INTEGER NOT NULL,
            inv_patient_id INTEGER NOT NULL,
            inv_tooth_number TEXT NOT NULL,
            inv_treatment_name TEXT NOT NULL,
            inv_treatment_cost REAL NOT NULL,
            inv_doctor_name TEXT NOT NULL,
            inv_invoice_date TEXT NOT NULL,
            inv_is_paid INTEGER NOT NULL DEFAULT 0,
            inv_payment_method TEXT,
            inv_notes TEXT,
            FOREIGN KEY(inv_treatment_plan_id) REFERENCES treatment_plans(tp_id),
            FOREIGN KEY(inv_patient_id) REFERENCES patients(patient_id)
          )
        ''');
      } catch (e) {
        print('Patient Invoices table error: $e');
      }

      try {
        await _db!.execute('''
          CREATE TABLE IF NOT EXISTS users (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL, -- 'admin' or 'user'
            permissions TEXT DEFAULT '[]', -- JSON list of allowed sections
            is_active INTEGER DEFAULT 1
          )
        ''');

        // Check if admin exists
        final adminCheck = await _db!.rawQuery("SELECT count(*) as count FROM users WHERE username = 'admin'");
        if ((Sqflite.firstIntValue(adminCheck) ?? 0) == 0) {
          await _db!.insert('users', {
            'username': 'admin',
            'password': 'admin', // In a real app, hash this!
            'role': 'admin',
            'permissions': '["all"]',
            'is_active': 1
          });
          print('Default admin account created.');
        }
      } catch (e) {
        print('Users table error: $e');
      }

      _dbOpenCompleter!.complete(_db);
      return _db;
    } catch (e) {
      print('DB Open error: $e');
      _dbOpenCompleter?.completeError(e);
      rethrow;
    } finally {
      _dbOpenCompleter = null;
    }
  }

  Future<Database?> getDatabase() async {
    if (kIsWeb) return null;
    if (_db != null && _db!.isOpen) return _db;
    await openDb();
    return _db;
  }

  Future<void> closeDB() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
