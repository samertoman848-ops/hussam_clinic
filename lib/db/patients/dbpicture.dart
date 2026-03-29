import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/model/PictureModel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../../main.dart';

class DbPicture {

  // CREATE TABLE "patient_pic" (
  // "patient_pic_id"	INTEGER NOT NULL UNIQUE,
  // "patient_pic_location"	TEXT,
  // "patient_pic_patientId"	TEXT,
  // PRIMARY KEY("patient_pic_id" AUTOINCREMENT)

  DbHelper dbHelper = DbHelper();

  Future<List<PictureModel>> allPictures() async {
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from patient_pic ORDER by patient_pic_id';
    final List<Map<String, Object?>> queryResult = await  db!.rawQuery(sql);
    return queryResult.map((e) => PictureModel.fromMap(e)).toList();
  }

  Future<void> lastPicture() async {
    Database? db = await dbHelper.openDb();
    String sql =
        'SELECT MAX(patient_pic_id)+1 as maxno FROM  patient_pic';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    maxNoPic =queryResult.isEmpty?"0": queryResult.elementAt(0).values.elementAt(0).toString();
    print('wqwqwqwqwqwqwq $maxNoPic');
    maxNoPic= (int.parse(maxNoPic)+1).toString();
  }


  Future<void> deletePicture(String patientPicLocation) async {
    Database? db = await dbHelper.openDb();
    String sql = 'DELETE FROM patient_pic WHERE patient_pic_location=?';
    db!.rawQuery(sql, [patientPicLocation]);
  }

  Future<List<PictureModel>> searchPictureByPatientId(
      String patientId) async {
    Database? db = await dbHelper.openDb();
    String sql = "SELECT * from  patient_pic WHERE patient_pic_patientId="
        '${patientId.trim()}';
    final List<Map<String, Object?>> queryResult = await  db!.rawQuery(sql);
    return queryResult.map((e) => PictureModel.fromMap(e)).toList();
  }
  // CREATE TABLE "patient_pic" (
  // "patient_pic_id"	INTEGER NOT NULL UNIQUE,
  // "patient_pic_location"	TEXT,
  // "patient_pic_patientId"	TEXT,
  // PRIMARY KEY("patient_pic_id" AUTOINCREMENT)

  Future<void> addPicture(String patientPicLocation, String patientPicPatientid) async {
    Database? db = await dbHelper.openDb();
    return db!.execute(
        'INSERT INTO patient_pic (patient_pic_location,patient_pic_patientId) VALUES (?, ?)',
        [patientPicLocation, patientPicPatientid]);
  }

}
