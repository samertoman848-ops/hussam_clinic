import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../model/Employment/EmployeeModel.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbEmployee {
  DbHelper dbHelper = DbHelper();
  Future<List<Map<String, Object?>>> allEmployees() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('employees')
          .orderBy('employee_name', descending: false)
          .get();
      return snap.docs.map((doc) => doc.data()).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from employees ORDER by employee_name ASC';
    return db!.rawQuery(sql);
  }

  Future<List<EmployeeModel>> allEmployeesModel() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('employees')
          .orderBy('employee_name', descending: false)
          .get();
      return snap.docs.map((doc) => EmployeeModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from employees ORDER by employee_name ASC';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => EmployeeModel.fromMap(e)).toList();
  }

  Future<List<EmployeeModel>> allEmployeesM() async {
    return allEmployeesModel();
  }

  Future<List<Map<String, Object?>>> searchEmployeeById(int id) async {
    if (kIsWeb) {
      final doc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(id.toString())
          .get();
      return doc.exists ? [doc.data()!] : [];
    }
    Database? db = await dbHelper.openDb();
    String sql =
        'SELECT * from  employees WHERE employee_id=$id ORDER by employee_name ASC';
    return db!.rawQuery(sql);
  }

  Future<void> deleteEmployee(int id) async {
    if (kIsWeb) {
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(id.toString())
          .delete();
      return;
    }
    Database? db = await dbHelper.openDb();
    // return db!.delete('persons', where: 'id = ?', whereArgs: [id]);
    String sql = 'DELETE FROM employees  WHERE employee_id=$id';
    db!.rawQuery(sql);
  }

  Future<List<Map<String, Object?>>> searchingEmployee(String name) async {
    if (kIsWeb) {
      final query = await FirebaseFirestore.instance
          .collection('employees')
          .where('employee_name', isGreaterThanOrEqualTo: name)
          .where('employee_name', isLessThanOrEqualTo: '$name\uf8ff')
          .get();
      return query.docs.map((doc) => doc.data()).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = "";
    if (name.isNotEmpty) {
      sql =
          'SELECT * from  employees	 WHERE employee_name like "$name%"  or employee_name like "%$name"  or employee_name like "%$name%" ORDER by employee_name ASC';
    } else {
      sql = 'SELECT * from  employees ORDER by employee_name ASC';
    }
    return db!.rawQuery(sql);
  }
// CREATE TABLE "employees" (
// "employee_id"	INTEGER NOT NULL UNIQUE,
// "employee_name"	TEXT,
// "employee_mobile"	TEXT,
// "employee_jop"	TEXT,

  Future<void> addEmployee(String name, String mobile, String jop) async {
    final row = {
      'employee_name': name,
      'employee_mobile': mobile,
      'employee_jop': jop,
    };

    if (kIsWeb) {
      final id = DateTime.now().millisecondsSinceEpoch;
      final model = EmployeeModel.full(
        id: id,
        name: name,
        mobile: mobile,
        jop: jop,
      );
      await FirebaseSyncService.instance.syncEmployee(model);
      return;
    }

    Database? db = await dbHelper.openDb();
    final newId = await db!.insert('employees', row);
    final model = EmployeeModel.full(
      id: newId,
      name: name,
      mobile: mobile,
      jop: jop,
    );
    await FirebaseSyncService.instance.pushEmployee(model);
  }

  Future<void> updateEmployee(
      int id, String name, String mobile, String jop) async {
    final model = EmployeeModel.full(
      id: id,
      name: name,
      mobile: mobile,
      jop: jop,
    );
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncEmployee(model);
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.update('employees', model.toMap(),
        where: 'employee_id = ?', whereArgs: [id]);
    await FirebaseSyncService.instance.pushEmployee(model);
  }
}
