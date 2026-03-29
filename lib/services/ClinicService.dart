import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:hussam_clinc/model/ClinicModel.dart';
import 'package:hussam_clinc/services/StorageService.dart';
import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/global_var/globals.dart';

/// خدمة إدارة العيادات المتعددة
/// توفر وظائف للتنقل السريع بين العيادات وإدارتها
class ClinicService {
  static final ClinicService _instance = ClinicService._internal();
  factory ClinicService() => _instance;
  ClinicService._internal();

  /// قائمة العيادات المتاحة
  List<ClinicModel> _clinics = [];

  /// العيادة الحالية
  ClinicModel? _currentClinic;

  /// الحصول على قائمة العيادات
  List<ClinicModel> get clinics => List.unmodifiable(_clinics);

  /// الحصول على العيادة الحالية
  ClinicModel? get currentClinic => _currentClinic;

  /// اسم العيادة الحالية
  String get currentClinicName => _currentClinic?.name ?? 'غير محدد';

  /// عدد العيادات المتاحة
  int get clinicsCount => _clinics.length;

  /// التحقق من وجود عيادات أكثر من واحدة
  bool get hasMultipleClinics => _clinics.length > 1;

  /// تحميل جميع العيادات المتاحة
  Future<void> loadClinics() async {
    try {
      _clinics.clear();

      // الحصول على مجلد قواعد البيانات
      final dir = Directory(extDbFolder);
      if (!await dir.exists()) {
        return;
      }

      // البحث عن جميع ملفات .db
      final files = await dir.list().toList();
      final dbFiles =
          files.whereType<File>().where((f) => f.path.endsWith('.db')).toList();

      // تحميل معلومات العيادات
      for (var file in dbFiles) {
        final fileName = p.basename(file.path);
        final stat = await file.stat();

        _clinics.add(
          ClinicModel(
            name: fileName.replaceAll('.db', ''),
            dbFileName: fileName,
            createdAt: stat.changed,
          ),
        );
      }

      // ترتيب العيادات حسب اسمها
      _clinics.sort((a, b) => a.name.compareTo(b.name));

      // تعيين العيادة الحالية
      _updateCurrentClinic();

      debugPrint('✅ تم تحميل ${_clinics.length} عيادة');
    } catch (e) {
      debugPrint('❌ خطأ في تحميل العيادات: $e');
    }
  }

  /// تحديث العيادة الحالية من التخزين
  void _updateCurrentClinic() {
    final currentDbName = selectedDbName.toLowerCase();

    _currentClinic = _clinics.firstWhere(
      (clinic) => clinic.dbFileName.toLowerCase() == currentDbName,
      orElse: () => _clinics.isNotEmpty ? _clinics.first : _ClinicModel.empty(),
    );

    debugPrint('🏥 العيادة الحالية المكتشفة: ${_currentClinic?.name}');
  }

  /// التبديل إلى عيادة معينة
  Future<bool> switchToClinic(ClinicModel clinic) async {
    if (clinic.dbFileName == selectedDbName) {
      return true; // بالفعل في هذه العيادة
    }

    try {
      // إغلاق قاعدة البيانات الحالية
      await DbHelper().closeDB();

      // حفظ قاعدة البيانات الجديدة
      await StorageService().saveDbConfig(clinic.dbFileName);

      // تحديث الوقت الأخير للوصول
      await _updateLastAccessedTime(clinic);

      // تحديث العيادة الحالية
      _updateCurrentClinic();

      debugPrint('✅ تم التبديل إلى العيادة: ${clinic.name}');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في التبديل للعيادة: $e');
      return false;
    }
  }

  /// التبديل إلى عيادة باستخدام الاسم
  Future<bool> switchToClinicByName(String clinicName) async {
    final clinic = _clinics.firstWhere(
      (c) => c.name == clinicName || c.displayName == clinicName,
      orElse: () => _ClinicModel.empty(),
    );

    if (clinic.name.isEmpty) {
      debugPrint('❌ لم يتم العثور على عيادة باسم: $clinicName');
      return false;
    }

    return switchToClinic(clinic);
  }

  /// الحصول على العيادة التالية
  ClinicModel? getNextClinic() {
    if (!hasMultipleClinics) return null;

    final currentIndex = _clinics.indexWhere(
      (c) => c.dbFileName == selectedDbName,
    );

    if (currentIndex == -1 || currentIndex == _clinics.length - 1) {
      return _clinics.first;
    }

    return _clinics[currentIndex + 1];
  }

  /// الحصول على العيادة السابقة
  ClinicModel? getPreviousClinic() {
    if (!hasMultipleClinics) return null;

    final currentIndex = _clinics.indexWhere(
      (c) => c.dbFileName == selectedDbName,
    );

    if (currentIndex <= 0) {
      return _clinics.last;
    }

    return _clinics[currentIndex - 1];
  }

  /// التبديل إلى العيادة التالية (سريع)
  Future<bool> switchToNextClinic() async {
    final nextClinic = getNextClinic();
    if (nextClinic == null) return false;

    return switchToClinic(nextClinic);
  }

  /// التبديل إلى العيادة السابقة (سريع)
  Future<bool> switchToPreviousClinic() async {
    final previousClinic = getPreviousClinic();
    if (previousClinic == null) return false;

    return switchToClinic(previousClinic);
  }

  /// إنشاء عيادة جديدة
  Future<bool> createClinic(String clinicName) async {
    try {
      // التحقق من أن الاسم غير فارغ
      String dbFileName = clinicName.trim();
      if (!dbFileName.endsWith('.db')) {
        dbFileName += '.db';
      }

      // التحقق من عدم وجود عيادة بنفس الاسم
      if (_clinics.any((c) => c.dbFileName == dbFileName)) {
        debugPrint('❌ يوجد عيادة بنفس الاسم مسبقاً!');
        return false;
      }

      // إنشاء قاعدة البيانات الجديدة
      final dbPath = p.join(extDbFolder, dbFileName);
      await DbHelper().copyAssetsDb(dbPath);

      // إضافة العيادة للقائمة
      final newClinic = ClinicModel(
        name: clinicName,
        dbFileName: dbFileName,
        description: 'عيادة جديدة',
      );

      _clinics.add(newClinic);
      _clinics.sort((a, b) => a.name.compareTo(b.name));

      debugPrint('✅ تم إنشاء العيادة الجديدة: $clinicName');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء العيادة: $e');
      return false;
    }
  }

  /// حذف عيادة
  Future<bool> deleteClinic(ClinicModel clinic) async {
    try {
      // التحقق من عدم محاولة حذف العيادة الحالية
      if (clinic.dbFileName == selectedDbName) {
        debugPrint(
            '❌ لا يمكن حذف العيادة الحالية! يرجى التبديل إلى عيادة أخرى أولاً.');
        return false;
      }

      // حذف الملف
      final dbPath = p.join(extDbFolder, clinic.dbFileName);
      final file = File(dbPath);
      if (await file.exists()) {
        await file.delete();
      }

      // حذف العيادة من القائمة
      _clinics.removeWhere((c) => c.dbFileName == clinic.dbFileName);

      debugPrint('✅ تم حذف العيادة: ${clinic.name}');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في حذف العيادة: $e');
      return false;
    }
  }

  /// إعادة تسمية عيادة
  Future<bool> renameClinic(ClinicModel clinic, String newName) async {
    try {
      if (newName.trim().isEmpty) return false;

      // الاسم الجديد للملف
      String newFileName = newName.trim();
      if (!newFileName.endsWith('.db')) {
        newFileName += '.db';
      }

      // التحقق من عدم وجود عيادة بنفس الاسم الجديد (باستثناء العيادة الحالية نفسها)
      if (_clinics.any(
          (c) => c.dbFileName == newFileName && c.dbFileName != clinic.dbFileName)) {
        debugPrint('❌ يوجد عيادة أخرى بنفس الاسم الجديد!');
        return false;
      }

      final oldPath = p.join(extDbFolder, clinic.dbFileName);
      final newPath = p.join(extDbFolder, newFileName);

      // إغلاق قاعدة البيانات قبل إعادة التسمية لمنع قفل الملف في ويندوز
      if (clinic.dbFileName == selectedDbName) {
        await DbHelper().closeDB();
      }

      final file = File(oldPath);
      if (await file.exists()) {
        await file.rename(newPath);

        // تحديث الإعدادات في التخزين
        if (clinic.dbFileName == selectedDbName) {
          await StorageService().saveDbConfig(newFileName);
        }

        // تحديث القائمة المحلية
        final index =
            _clinics.indexWhere((c) => c.dbFileName == clinic.dbFileName);
        if (index != -1) {
          _clinics[index] = clinic.copyWith(
            name: newName,
            dbFileName: newFileName,
          );
        }

        _clinics.sort((a, b) => a.name.compareTo(b.name));
        _updateCurrentClinic();

        debugPrint('✅ تم إعادة تسمية العيادة إلى: $newName');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ خطأ في إعادة تسمية العيادة: $e');
      return false;
    }
  }

  /// تحديث وقت آخر وصول للعيادة
  Future<void> _updateLastAccessedTime(ClinicModel clinic) async {
    final index = _clinics.indexWhere((c) => c.dbFileName == clinic.dbFileName);
    if (index != -1) {
      _clinics[index] = clinic.copyWith(lastAccessedAt: DateTime.now());
    }
  }

  /// الحصول على قائمة العيادات مرتبة حسب آخر وصول
  List<ClinicModel> getClinicsOrderedByLastAccess() {
    final sorted = List<ClinicModel>.from(_clinics);
    sorted.sort((a, b) {
      final aLast = a.lastAccessedAt ?? DateTime(2000);
      final bLast = b.lastAccessedAt ?? DateTime(2000);
      return bLast.compareTo(aLast);
    });
    return sorted;
  }

  /// الحصول على معلومات العيادات كنص
  String getClinicsSummary() {
    return 'العيادات المتاحة (${_clinics.length}): ${_clinics.map((c) => c.name).join(", ")}';
  }

  /// حذف كافة البيانات المحفوطة في عيادة معينة
  Future<bool> resetClinic(ClinicModel clinic) async {
    final originalDbName = selectedDbName;
    try {
      debugPrint('⏳ جاري تصفير بيانات العيادة برمجياً: ${clinic.name}');

      // 1. إغلاق قاعدة البيانات الحالية لضمان نظافة الاتصال
      await DbHelper().closeDB();

      // 2. فتح العيادة المستهدفة مؤقتاً
      selectedDbName = clinic.dbFileName;
      final db = await DbHelper().openDb();

      if (db != null && db.isOpen) {
        // 3. حذف البيانات من كافة الجداول الأساسية
        final tables = [
          'dates', 'employees', 'patient_health', 'patient_health_doctor', 
          'patient_pic', 'invoices_detail', 'accounting_tree', 'journals_detail', 
          'journals', 'indexes', 'vouchers', 'patients', 'invoices', 
          'rooms', 'treatment_plans', 'patient_invoices'
        ];

        await db.transaction((txn) async {
          for (var table in tables) {
            try {
              await txn.execute('DELETE FROM $table');
              // تصفير عداد الزيادة التلقائية
              await txn.execute('DELETE FROM sqlite_sequence WHERE name = ?', [table]);
            } catch (e) {
              debugPrint('Warning: Could not clear table $table: $e');
            }
          }
        });

        // تحسين حجم قاعدة البيانات
        await db.execute('VACUUM');
        
        debugPrint('✅ تم تصفير كافة الجداول في عيادة: ${clinic.name}');
        
        // 4. إغلاق والرجوع للعيادة الأصلية
        await DbHelper().closeDB();
        selectedDbName = originalDbName;
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ فشل تصفير العيادة (SQL): $e');
      selectedDbName = originalDbName;
      return false;
    }
  }
}

/// نموذج فارغ للعيادة (للاستخدام الداخلي)
class _ClinicModel extends ClinicModel {
  _ClinicModel.empty()
      : super(
          name: '',
          dbFileName: '',
          description: null,
        );
}
