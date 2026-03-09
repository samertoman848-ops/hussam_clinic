// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../global_var/globals.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper.internal();
  factory DbHelper() => _instance;
  DbHelper.internal();
  Database? _db;

  Future<void> copyAssetsDb(String path) async {
    ////////////////////// Load database from asset and copy
    ByteData data = await rootBundle.load('assets/db/db.db');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // Save copied asset to documents
    await File(path).writeAsBytes(bytes);
    print('Successfully Copied DB to $path');
  }

  Future<void> backupDb(String fromPath, String toPath) async {
    ////////////////////// Load database from asset and copy
    ByteData data = await rootBundle.load(fromPath);
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // Save copied asset to documents
    await File(toPath).writeAsBytes(bytes);
    print('Successfully Backup DB');
    ////////////////////// end copy data base
  }

  Future<void> saveOverridePath(String? path) async {
    // legacy method, redirect to StorageService if needed or remove
  }

  Future<String> configuredDbPath() async {
    final path = join(extDbFolder, 'db.db');
    final dir = Directory(dirname(path));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return path;
  }

  Future<Database?> openDb() async {
    if (kIsWeb) {
      debugPrint('SQLite is disabled on Web. Using Firebase as primary store.');
      return null;
    }
    String path = await configuredDbPath();

    // if target db file doesn't exist, copy asset there (keeps behavior)
    if (await databaseExists(path) == false) {
      final parent = Directory(dirname(path));
      if (!parent.existsSync()) parent.createSync(recursive: true);
      await copyAssetsDb(path);
    }
    _db = await openDatabase(path);

    // Ensure new column for mobile2 exists (migration)
    try {
      final res = await _db!.rawQuery("PRAGMA table_info('patients')");
      bool hasMobile2 = false;
      for (var row in res) {
        if (row['name'] == 'patient_mobile2') {
          hasMobile2 = true;
          break;
        }
      }
      if (!hasMobile2) {
        await _db!.execute(
            "ALTER TABLE patients ADD COLUMN patient_mobile2 TEXT DEFAULT '';");
        print('Added patient_mobile2 column to patients table');
      }
    } catch (e) {
      print('Error checking/adding patient_mobile2 column: $e');
    }

    // Ensure every patient has a unique fileNo (migrate missing/null/empty values)
    try {
      final maxRes =
          await _db!.rawQuery('SELECT max(patient_fileNo) as d from patients');
      int currentMax = 0;
      if (maxRes.isNotEmpty && maxRes.first['d'] != null) {
        currentMax = int.tryParse(maxRes.first['d'].toString()) ?? 0;
      }

      final missing = await _db!.rawQuery(
          "SELECT patient_id FROM patients WHERE patient_fileNo IS NULL OR trim(patient_fileNo) = ''");
      for (var row in missing) {
        currentMax += 1;
        try {
          await _db!.rawUpdate(
              'UPDATE patients SET patient_fileNo = ? WHERE patient_id = ?',
              [currentMax.toString(), row['patient_id']]);
        } catch (e) {
          print('Failed to update patient_fileNo for ${row["patient_id"]}: $e');
        }
      }
      if (missing.isNotEmpty) {
        print('Migrated ${missing.length} patients to assign file numbers');
      }
    } catch (e) {
      print('Error migrating missing patient_fileNo values: $e');
    }

    // Ensure treatment_plans table exists (create if missing)
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
      print('Treatment plans table ensured');
    } catch (e) {
      print('Error creating/checking treatment_plans table: $e');
    }

    // Ensure invoices table exists (create if missing)
    try {
      await _db!.execute('''
        CREATE TABLE IF NOT EXISTS invoices (
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
      print('Invoices table ensured');
    } catch (e) {
      print('Error creating/checking invoices table: $e');
    }

    return _db;
  }

  Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    _db = await openDb();
    return _db!;
  }

  Future<void> closeDB() async {
    final db = _db;
    await db!.close();
  }

  // Future<int> createCourse(PersonModel person) async {
  //   Database? db = await openDb();
  //   //db.rawInsert('insert into courses')
  //   return db!.insert('persons', person.toMap());
  // }
}
