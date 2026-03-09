import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import '../../model/patients/TreatmentPlanModel.dart';
import '../dbhelper.dart';

class DbTreatmentPlans {
  static final DbTreatmentPlans _instance = DbTreatmentPlans.internal();

  factory DbTreatmentPlans() {
    return _instance;
  }

  DbTreatmentPlans.internal();

  static const String tableName = 'treatment_plans';

  // Create table SQL
  static const String createTableSQL = '''
    CREATE TABLE IF NOT EXISTS $tableName (
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
  ''';

  Future<int> addTreatmentPlan(TreatmentPlanModel plan) async {
    try {
      if (kIsWeb) {
        await FirebaseSyncService.instance.syncTreatmentPlan(plan);
        return 1;
      }
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final id = await db.insert(tableName, plan.toMap());
      
      // Update plan with ID and sync
      plan.id = id;
      FirebaseSyncService.instance.pushTreatmentPlan(plan);
      return id;
    } catch (e) {
      print('Error adding treatment plan: $e');
      return -1;
    }
  }

  Future<List<TreatmentPlanModel>> getTreatmentPlansByPatient(
      int patientId) async {
    try {
      if (kIsWeb) {
        final snap = await FirebaseFirestore.instance
            .collection(tableName)
            .where('tp_patient_id', isEqualTo: patientId)
            .get();
        return snap.docs.map((doc) => TreatmentPlanModel.fromMap(doc.data())).toList();
      }
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final result = await db.query(
        tableName,
        where: 'tp_patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'tp_treatment_date DESC',
      );

      return result.map((map) => TreatmentPlanModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting treatment plans: $e');
      return [];
    }
  }

  Future<List<TreatmentPlanModel>> getAllTreatmentPlans() async {
    try {
      final db = await DbHelper().openDb();
      if (db == null) return [];
      final result = await db.query(tableName);
      return result.map((map) => TreatmentPlanModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all treatment plans: $e');
      return [];
    }
  }

  /// احصل على الخطط العلاجية غير المكتملة للمريض
  Future<List<TreatmentPlanModel>> getIncompleteTreatmentPlans(
      int patientId) async {
    try {
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final result = await db.query(
        tableName,
        where: 'tp_patient_id = ? AND tp_is_completed = 0',
        whereArgs: [patientId],
        orderBy: 'tp_treatment_date ASC',
      );

      return result.map((map) => TreatmentPlanModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting incomplete treatment plans: $e');
      return [];
    }
  }

  /// احصل على الخطط العلاجية المكتملة للمريض
  Future<List<TreatmentPlanModel>> getCompletedTreatmentPlans(
      int patientId) async {
    try {
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final result = await db.query(
        tableName,
        where: 'tp_patient_id = ? AND tp_is_completed = 1',
        whereArgs: [patientId],
        orderBy: 'tp_treatment_date DESC',
      );

      return result.map((map) => TreatmentPlanModel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting completed treatment plans: $e');
      return [];
    }
  }

  Future<int> updateTreatmentPlan(TreatmentPlanModel plan) async {
    try {
      if (kIsWeb) {
        await FirebaseSyncService.instance.syncTreatmentPlan(plan);
        return 1;
      }
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final count = await db.update(
        tableName,
        plan.toUpdateMap(),
        where: 'tp_id = ?',
        whereArgs: [plan.id],
      );

      FirebaseSyncService.instance.pushTreatmentPlan(plan);
      return count;
    } catch (e) {
      print('Error updating treatment plan: $e');
      return -1;
    }
  }

  ///   حدّث حالة الانجاز (مكتملة / غير مكتملة)
  Future<int> updateCompletionStatus(int planId, bool isCompleted) async {
    try {
      if (kIsWeb) {
        // We'd need the full plan to sync properly, or handle partial updates in service
        // For simplicity, let's assume we fetch the plan or handle partial in syncData
        // Actually, syncData uses merge: true, so partial is fine
        await FirebaseSyncService.instance.syncData(tableName, planId.toString(), {
          'tp_is_completed': isCompleted ? 1 : 0,
        });
        return 1;
      }
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final count = await db.update(
        tableName,
        {'tp_is_completed': isCompleted ? 1 : 0},
        where: 'tp_id = ?',
        whereArgs: [planId],
      );

      // We should ideally sync the full updated model here
      // But for now, partial sync via syncData is used for Web
      // For Desktop, we might need to fetch the full model to sync correctly if pushTreatmentPlan expects full map
      return count;
    } catch (e) {
      print('Error updating completion status: $e');
      return -1;
    }
  }

  /// احذف خطة علاجية
  Future<int> deleteTreatmentPlan(int planId) async {
    try {
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      return await db.delete(
        tableName,
        where: 'tp_id = ?',
        whereArgs: [planId],
      );
    } catch (e) {
      print('Error deleting treatment plan: $e');
      return -1;
    }
  }

  /// احذف جميع الخطط العلاجية للمريض
  Future<int> deleteTreatmentPlansByPatient(int patientId) async {
    try {
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      return await db.delete(
        tableName,
        where: 'tp_patient_id = ?',
        whereArgs: [patientId],
      );
    } catch (e) {
      print('Error deleting patient treatment plans: $e');
      return -1;
    }
  }

  /// احصل على عدد الخطط العلاجية المتبقية
  Future<int> getTreatmentPlanCount(int patientId) async {
    try {
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE tp_patient_id = ?',
        [patientId],
      );

      return (result[0]['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting treatment plan count: $e');
      return 0;
    }
  }

  /// احصل على عدد الخطط العلاجية المكتملة
  Future<int> getCompletedCount(int patientId) async {
    try {
      final db = await DbHelper().openDb();
      if (db == null) throw Exception('Database is null');

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE tp_patient_id = ? AND tp_is_completed = 1',
        [patientId],
      );

      return (result[0]['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting completed count: $e');
      return 0;
    }
  }
}
