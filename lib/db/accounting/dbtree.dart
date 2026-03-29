import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/model/accounting/AccoutingTreeModel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DbTree {
  DbHelper dbHelper = DbHelper();

  Future<List<AccoutingTreeModel>> allAccountingTree() async {
    Database? db = await dbHelper.openDb();
    String sql = "";
    sql = 'SELECT * from accounting_tree';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => AccoutingTreeModel.fromMap(e)).toList();
  }

  Future<List<AccoutingTreeModel>> allAccountingTreeGrouping() async {
    Database? db = await dbHelper.openDb();
    String sql = "";
    sql = 'SELECT * from accounting_tree GROUP BY accounting_tree.AT_father_no';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => AccoutingTreeModel.fromMap(e)).toList();
  }

  //GROUP BY date_doctorId,date_place,date(dates.date_dateStart),period
  Future<List<AccoutingTreeModel>> allEmployeeAccounting() async {
    Database? db = await dbHelper.openDb();
    String sql = "";
    sql = 'SELECT * from all_Employee_Acounting';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => AccoutingTreeModel.fromMap(e)).toList();
  }

  Future<List<AccoutingTreeModel>> allPaitentsAccounting() async {
    Database? db = await dbHelper.openDb();
    String sql = "";
    // جرب الحصول على بيانات المرضى من جدول patients أيضاً
    sql = 'SELECT * from all_Paitents_Acounting';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => AccoutingTreeModel.fromMap(e)).toList();
  }

  // دالة جديدة تجلب أسماء المرضى من جدول patients مباشرة
  Future<List<AccoutingTreeModel>> allPaitentsFromPatients() async {
    Database? db = await dbHelper.openDb();
    String sql =
        'SELECT patient_id as AT_id, patient_Name as AT_name, patient_fileNo as AT_branch_no, "5200" as AT_father_no, patient_fileNo as AT_branch_originalId FROM patients ORDER BY patient_Name';
    try {
      final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
      return queryResult.map((e) => AccoutingTreeModel.fromMap(e)).toList();
    } catch (e) {
      print('Error loading patients from patients table: $e');
      return [];
    }
  }

  Future<List<AccoutingTreeModel>> allSuppliersAccounting() async {
    Database? db = await dbHelper.openDb();
    String sql = "";
    sql = 'SELECT * from all_Suppliers_Acounting';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => AccoutingTreeModel.fromMap(e)).toList();
  }
}
