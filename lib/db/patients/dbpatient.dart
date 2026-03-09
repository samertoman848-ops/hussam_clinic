import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/main.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../../model/patients/PatientModel.dart';

class DbPatient {
  DbHelper dbHelper = DbHelper();

  Future<List<PatientModel>> allPatients() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance.collection('patients').get();
      return snap.docs.map((doc) => FirebaseSyncService.instance.fromFirestoreMap(doc.id, doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from patients ORDER by patient_Name';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => PatientModel.fromMap(e)).toList();
  }

  Future<List<Map<String, Object?>>> searchPatientById(int id) async {
    if (kIsWeb) {
      final doc = await FirebaseFirestore.instance.collection('patients').doc(id.toString()).get();
      return doc.exists ? [doc.data()!] : [];
    }
    Database? db = await dbHelper.openDb();
    String sql =
        'SELECT * from  patients WHERE patient_id=$id ORDER by patient_name ASC';
    return db!.rawQuery(sql);
  }

  Future<void> deletePatient(int id) async {
    if (kIsWeb) {
      await FirebaseFirestore.instance.collection('patients').doc(id.toString()).delete();
      return;
    }
    Database? db = await dbHelper.openDb();
    String sql = 'DELETE FROM patients  WHERE patient_id=$id';
    db!.rawQuery(sql);
  }

  Future<void> updatePatient(int id, PatientModel patint) async {
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncPatient(patint);
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.update("patients", patint.toMap(),
        where: 'patient_id = ?', whereArgs: [id]);
    await FirebaseSyncService.instance.pushPatient(patint);
  }

  Future<void> updateFileNoPatient(
      String name,
      String mobile,
      String mobile2,
      String sex,
      String status,
      String birthDay,
      String fileNo,
      String Address,
      String resone,
      String worries) async {
    
    // On Web, update Firestore immediately
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('patients')
          .where('patient_fileNo', isEqualTo: fileNo)
          .get();
      if (snap.docs.isNotEmpty) {
        final docId = snap.docs.first.id;
        final patient = PatientModel.full(
          id: int.tryParse(docId) ?? 0,
          name: name,
          mobile: mobile,
          mobile2: mobile2,
          sex: sex,
          status: status,
          birthDay: birthDay,
          fileNo: fileNo,
          address: Address,
          resone: resone,
          worries: worries,
        );
        await FirebaseSyncService.instance.syncPatient(patient);
      }
      return;
    }

    // On Desktop, update local then sync
    Database? db = await dbHelper.openDb();
    String sql =
        'UPDATE patients SET patient_Name=?,patient_mobile=?,patient_mobile2=?,patient_sex=?,patient_status=?,patient_birthDay=? ,patient_Address=?,patient_resone=?,patient_worries=? WHERE patient_fileNo=?';
    await db!.rawUpdate(sql, [name,mobile,mobile2,sex,status,birthDay,Address,resone,worries,fileNo]);

    // Background push
    getPatientByFileNo(fileNo).then((updated) {
      if (updated != null) FirebaseSyncService.instance.pushPatient(updated);
    });
  }

  Future<void> updatePatientFileNoById(int id, String fileNo) async {
    Database? db = await dbHelper.openDb();
    await db!.rawUpdate(
        'UPDATE patients SET patient_fileNo = ? WHERE patient_id = ?',
        [fileNo, id]);
  }

  Future<List<Map<String, Object?>>> searchingPatient(String name) async {
    if (kIsWeb) {
      final query = await FirebaseFirestore.instance
          .collection('patients')
          .where('patient_Name', isGreaterThanOrEqualTo: name)
          .where('patient_Name', isLessThanOrEqualTo: '$name\uf8ff')
          .get();
      return query.docs.map((doc) => doc.data()).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = "";
    if (name.isNotEmpty) {
      sql =
          'SELECT * from  patients WHERE patient_name like "$name%"  or patient_name like "%$name"  or patient_name like "%$name%" ORDER by patient_name ASC';
    } else {
      sql = 'SELECT * from  patients ORDER by patient_name ASC';
    }
    final res = await db!.rawQuery(sql);
    return res;
  }

  Future<void> MaxFileNo() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('patients')
          .orderBy('patient_fileNo', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        MaxFiledNo = "1";
      } else {
        var last = snap.docs.first.data()['patient_fileNo'];
        MaxFiledNo = (int.parse(last.toString()) + 1).toString();
      }
      return;
    }
    Database? db = await dbHelper.openDb();
    final List<Map<String, Object?>> queryResult =
        await db!.rawQuery('SELECT max(patient_fileNo) as d from patients');
    var maxVal = queryResult.first['d'];
    if (maxVal == null) {
      MaxFiledNo = "1";
    } else {
      MaxFiledNo = (int.parse(maxVal.toString()) + 1).toString();
    }
  }

  Future<PatientModel?> getPatientById(int id) async {
    if (kIsWeb) {
      final doc = await FirebaseFirestore.instance.collection('patients').doc(id.toString()).get();
      if (!doc.exists) return null;
      return FirebaseSyncService.instance.fromFirestoreMap(doc.id, doc.data()!);
    }
    Database? db = await dbHelper.openDb();
    final rows = await db!.query(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PatientModel.fromMap(rows.first);
  }

  Future<PatientModel?> getPatientByFileNo(String fileNo) async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance.collection('patients').where('patient_fileNo', isEqualTo: fileNo).get();
      if (snap.docs.isEmpty) return null;
      return FirebaseSyncService.instance.fromFirestoreMap(snap.docs.first.id, snap.docs.first.data());
    }
    Database? db = await dbHelper.openDb();
    final rows = await db!.query(
      'patients',
      where: 'patient_fileNo = ?',
      whereArgs: [fileNo],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PatientModel.fromMap(rows.first);
  }

  Future<void> upsertPatientFromCloud(PatientModel patient) async {
    if (kIsWeb) return;
    Database? db = await dbHelper.openDb();

    final updatedById = await db!.update(
      'patients',
      patient.toMap(),
      where: 'patient_id = ?',
      whereArgs: [patient.id],
    );

    if (updatedById > 0) return;

    final updatedByFileNo = await db.update(
      'patients',
      patient.toMap(),
      where: 'patient_fileNo = ?',
      whereArgs: [patient.fileNo],
    );

    if (updatedByFileNo > 0) return;

    await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addPatient(
      String name,
      String mobile,
      String mobile2,
      String sex,
      String status,
      String birthDay,
      String fileNo,
      String Address,
      String resone,
      String worries) async {
    
    if (kIsWeb) {
      // For web, use a timestamp as ID or wait for Firestore
      int newId = DateTime.now().millisecondsSinceEpoch;
      final patient = PatientModel.full(
        id: newId,
        name: name,
        mobile: mobile,
        mobile2: mobile2,
        sex: sex,
        status: status,
        birthDay: birthDay,
        fileNo: fileNo,
        address: Address,
        resone: resone,
        worries: worries,
      );
      await FirebaseSyncService.instance.syncPatient(patient);
      return;
    }

    Database? db = await dbHelper.openDb();
    await db!.execute(
        'INSERT INTO patients (patient_Name, patient_mobile, patient_mobile2, patient_sex, patient_status, patient_birthDay, patient_fileNo, patient_Address, patient_resone, patient_worries ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);',
        [name, mobile, mobile2, sex, status, birthDay, fileNo, Address, resone, worries]);

    // Sync back
    getPatientByFileNo(fileNo).then((p) {
      if (p != null) FirebaseSyncService.instance.pushPatient(p);
    });
  }
}
