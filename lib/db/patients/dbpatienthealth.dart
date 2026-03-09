import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../../model/patients/PatientHealthModel.dart';

class DbPatientHealth {
  DbHelper dbHelper = DbHelper();

  Future<List<PatienHealthtModel>> allPHs() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance.collection('patient_health').get();
      return snap.docs.map((doc) => PatienHealthtModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from patient_health ORDER by PH_patientId ASC';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => PatienHealthtModel.fromMap(e)).toList();
  }

  Future<List<Map<String, Object?>>> searchPatientById(int id) async {
    Database? db = await dbHelper.openDb();
    String sql =
        'SELECT * from  patients WHERE patient_id=$id ORDER by patient_name ASC';
    return db!.rawQuery(sql);
  }

  Future<void> deletePatient(int id) async {
    Database? db = await dbHelper.openDb();
    String sql = 'DELETE FROM patient_health  WHERE patient_id=$id';
    db!.rawQuery(sql);
  }

  Future<void> updatePatientHealth(int id, PatienHealthtModel PH) async {
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncPatientHealth(PH);
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.update("patient_health", PH.toMap(),
        where: 'PH_patientId = ?', whereArgs: [id]); // Fixed column name

    FirebaseSyncService.instance.pushPatientHealth(PH);
  }

  // CREATE TABLE "patient_health" (
  // "PH_id"	INTEGER,
  // "PH_patientId"	INTEGER UNIQUE,  // "PH"	TEXT,  //
  // "PH_sensitive"	TEXT,  // "PH_sensitive_Ex"	TEXT,
  // "PH_surgical"	TEXT,  // "PH_surgical_Ex"	TEXT,
  // "PH_haemophilia"	TEXT,  // "PH_haemophilia_Ex"	TEXT,
  // "PH_drugs"	TEXT,  // "PH_drugs_Ex"	TEXT,
  // "PH_oralDiseases"	TEXT,  // "PH_smoking"	TEXT,
  // "PH_pregnant"	TEXT,  // "PH_pregnant_Ex"	INTEGER,
  // "PH_lactating"	TEXT,  // "PH_lactating_Ex"	INTEGER,
  // "PH_contraception"	TEXT,  // "PH_contraception_Ex"	TEXT,
  // PRIMARY KEY("PH_id","PH_patientId")
  // );
  Future<void> addPatientHealth(
    String phPatientid,
    String PH,
    String phSensitive,
    String phSensitiveEx,
    String phSurgical,
    String phSurgicalEx,
    String phHaemophilia,
    String phHaemophiliaEx,
    String phDrugs,
    String phDrugsEx,
    String phOraldiseases,
    String phSmoking,
    String phPregnant,
    String phPregnantEx,
    String phLactating,
    String phLactatingEx,
    String phContraception,
    String phContraceptionEx,
  ) async {
    final healthModel = PatienHealthtModel.full(
      id: 0, // PH_id is autoincrement in SQLite, Firestore uses patientId as doc ID
      patientId: phPatientid,
      health: PH,
      sensitive: phSensitive,
      sensitiveEx: phSensitiveEx,
      surgical: phSurgical,
      surgicalEx: phSurgicalEx,
      haemophilia: phHaemophilia,
      haemophiliaEx: phHaemophiliaEx,
      drugs: phDrugs,
      drugsEx: phDrugsEx,
      oralDiseases: phOraldiseases,
      smoking: phSmoking,
      pregnant: phPregnant,
      pregnantEx: phPregnantEx,
      lactating: phLactating,
      lactatingEx: phLactatingEx,
      contraception: phContraception,
      contraceptionEx: phContraceptionEx,
    );

    if (kIsWeb) {
      await FirebaseSyncService.instance.syncPatientHealth(healthModel);
      return;
    }

    Database? db = await dbHelper.openDb();
    await db!.execute(
        'INSERT INTO patient_health (PH_patientId, PH, PH_sensitive, PH_sensitive_Ex, PH_surgical, PH_surgical_Ex, PH_haemophilia, PH_haemophilia_Ex, PH_drugs, PH_drugs_Ex, PH_oralDiseases, PH_smoking, PH_pregnant ,PH_pregnant_Ex, PH_lactating, PH_lactating_Ex, PH_contraception, PH_contraception_Ex ) VALUES ("$phPatientid", "$PH","$phSensitive", "$phSensitiveEx","$phSurgical", "$phSurgicalEx","$phHaemophilia", "$phHaemophiliaEx", "$phDrugs", "$phDrugsEx", "$phOraldiseases", "$phSmoking","$phPregnant","$phPregnantEx","$phLactating", "$phLactatingEx", "$phContraception", "$phContraceptionEx");');
    
    FirebaseSyncService.instance.pushPatientHealth(healthModel);
  }
}
