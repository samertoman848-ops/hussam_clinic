import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import '../db/dbhelper.dart';

class DbImportService {
  final DbHelper _dbHelper = DbHelper();

  // جداول المصدر بترتيب الأولوية (الأقل تبعية أولاً)
  static const List<_TableImportConfig> _tables = [
    _TableImportConfig(
      table: 'patients',
      pkColumn: 'patient_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'المرضى',
    ),
    _TableImportConfig(
      table: 'journals',
      pkColumn: 'journal_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'القيود المحاسبية',
    ),
    _TableImportConfig(
      table: 'journals_detail',
      pkColumn: 'JD_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'تفاصيل القيود',
    ),
    _TableImportConfig(
      table: 'vouchers',
      pkColumn: 'voucher_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'السندات والإيصالات',
    ),
    _TableImportConfig(
      table: 'invoices',
      pkColumn: 'invoice_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'الفواتير',
    ),
    _TableImportConfig(
      table: 'invoices_detail',
      pkColumn: 'ID_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'تفاصيل الفواتير',
    ),
    _TableImportConfig(
      table: 'accounting_tree',
      pkColumn: 'AT_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'شجرة الحسابات',
    ),
    _TableImportConfig(
      table: 'accounting_index',
      pkColumn: 'AI_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'دليل الأصناف',
    ),
    _TableImportConfig(
      table: 'dates',
      pkColumn: 'date_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'المواعيد',
    ),
    _TableImportConfig(
      table: 'treatment_plans',
      pkColumn: 'tp_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'خطط العلاج',
    ),
    _TableImportConfig(
      table: 'patient_invoices',
      pkColumn: 'inv_id',
      conflictAlgorithm: ConflictAlgorithm.ignore,
      label: 'السجلات السريرية للمرضى',
    ),
  ];

  /// استيراد البيانات من ملف قاعدة بيانات خارجية
  Future<DbImportResult> importFrom(String sourcePath) async {
    final results = <String, _TableResult>{};
    int totalImported = 0;
    int totalSkipped = 0;
    int totalFailed = 0;

    try {
      // فتح قاعدة البيانات المصدر
      Database sourceDb;
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      if (!File(sourcePath).existsSync()) {
        return DbImportResult(
          success: false,
          message: 'ملف قاعدة البيانات المختار غير موجود: $sourcePath',
          tableResults: {},
          totalImported: 0,
          totalSkipped: 0,
          totalFailed: 0,
        );
      }

      sourceDb = await openDatabase(sourcePath, readOnly: true);
      final targetDb = await _dbHelper.openDb();

      if (targetDb == null) {
        await sourceDb.close();
        return DbImportResult(
          success: false,
          message: 'تعذّر فتح قاعدة البيانات الحالية',
          tableResults: {},
          totalImported: 0,
          totalSkipped: 0,
          totalFailed: 0,
        );
      }

      // التحقق من الجداول الموجودة في المصدر
      final sourceTables = await _getTableNames(sourceDb);

      for (final config in _tables) {
        if (!sourceTables.contains(config.table)) {
          results[config.table] = _TableResult(
            label: config.label,
            imported: 0,
            skipped: 0,
            failed: 0,
            note: 'الجدول غير موجود في المصدر',
          );
          continue;
        }

        try {
          final rows = await sourceDb.query(config.table);
          int imported = 0, skipped = 0, failed = 0;

          for (final row in rows) {
            try {
              final result = await targetDb.insert(
                config.table,
                Map<String, dynamic>.from(row),
                conflictAlgorithm: config.conflictAlgorithm,
              );
              if (result > 0) {
                imported++;
              } else {
                skipped++;
              }
            } catch (e) {
              failed++;
            }
          }

          totalImported += imported;
          totalSkipped += skipped;
          totalFailed += failed;

          results[config.table] = _TableResult(
            label: config.label,
            imported: imported,
            skipped: skipped,
            failed: failed,
          );
        } catch (e) {
          results[config.table] = _TableResult(
            label: config.label,
            imported: 0,
            skipped: 0,
            failed: 0,
            note: 'خطأ: $e',
          );
        }
      }

      await sourceDb.close();

      return DbImportResult(
        success: true,
        message: 'تم الاستيراد بنجاح',
        tableResults: results,
        totalImported: totalImported,
        totalSkipped: totalSkipped,
        totalFailed: totalFailed,
      );
    } catch (e) {
      return DbImportResult(
        success: false,
        message: 'خطأ غير متوقع: $e',
        tableResults: results,
        totalImported: totalImported,
        totalSkipped: totalSkipped,
        totalFailed: totalFailed,
      );
    }
  }

  Future<List<String>> _getTableNames(Database db) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
    return result.map((r) => r['name'].toString()).toList();
  }
}

class _TableImportConfig {
  final String table;
  final String pkColumn;
  final ConflictAlgorithm conflictAlgorithm;
  final String label;

  const _TableImportConfig({
    required this.table,
    required this.pkColumn,
    required this.conflictAlgorithm,
    required this.label,
  });
}

class _TableResult {
  final String label;
  final int imported;
  final int skipped;
  final int failed;
  final String? note;

  _TableResult({
    required this.label,
    required this.imported,
    required this.skipped,
    required this.failed,
    this.note,
  });
}

class DbImportResult {
  final bool success;
  final String message;
  final Map<String, _TableResult> tableResults;
  final int totalImported;
  final int totalSkipped;
  final int totalFailed;

  DbImportResult({
    required this.success,
    required this.message,
    required this.tableResults,
    required this.totalImported,
    required this.totalSkipped,
    required this.totalFailed,
  });
}
