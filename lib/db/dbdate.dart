import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/model/DatesModel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DbDate {
  DbHelper dbHelper = DbHelper();

  Future<List<DateModel>> alldate() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('dates')
          .orderBy('date_id', descending: false)
          .get();
      return snap.docs.map((doc) => DateModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from dates ORDER by date_id ASC';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => DateModel.fromMap(e)).toList();
  }

  Future<List<DateModel>> getDatesByPatient(String patientId) async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('dates')
          .where('date_costumerId', isEqualTo: patientId)
          .get();
      return snap.docs.map((doc) => DateModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    final List<Map<String, Object?>> results = await db!.query('dates',
        where: 'date_costumerId = ?',
        whereArgs: [patientId],
        orderBy: 'date_id ASC');
    return results.map((e) => DateModel.fromMap(e)).toList();
  }

  Future<DateModel> lastDate() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('dates')
          .orderBy('date_id', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return DateModel.fromMap(snap.docs.first.data());
      }
      throw Exception('No dates found');
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from dates ORDER by date_id DESC LIMIT 1';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return DateModel.fromMap(queryResult.first);
  }

  Future<DateModel> searchDatesById(String id) async {
    if (kIsWeb) {
      final doc =
          await FirebaseFirestore.instance.collection('dates').doc(id).get();
      if (doc.exists) {
        return DateModel.fromMap(doc.data()!);
      }
      throw Exception('Date not found');
    }
    int id0 = int.parse(id);
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from dates WHERE date_id=$id0 LIMIT 1';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return DateModel.fromMap(queryResult[0]);
  }

  Future<List<DateModel>> GroupDates() async {
    if (kIsWeb) {
      return await alldate();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from group_date';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return queryResult.map((e) => DateModel.fromMap(e)).toList();
  }

  Future<void> deletedate(int id) async {
    if (kIsWeb) {
      await FirebaseFirestore.instance
          .collection('dates')
          .doc(id.toString())
          .delete();
      return;
    }
    Database? db = await dbHelper.openDb();
    String sql = 'DELETE FROM dates  WHERE date_id=$id';
    db!.rawQuery(sql);
  }

  Future<void> updateDate(int id, DateModel DateModle) async {
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncDate(DateModle);
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.update("dates", DateModle.toMap(),
        where: 'date_id = ?', whereArgs: [id]);
    await FirebaseSyncService.instance.pushDate(DateModle);
  }

  Future<void> adddate(
    String dateKind,
    String datePlace,
    String dateDatestart,
    String dateDateend,
    String dateNote,
    String dateDoctorid,
    String dateDoctorname,
    String dateCostumerid,
    String dateCostumername,
  ) async {
    final row = {
      'date_kind': dateKind,
      'date_place': datePlace,
      'date_dateStart': dateDatestart,
      'date_dateEnd': dateDateend,
      'date_note': dateNote,
      'date_doctorId': dateDoctorid,
      'date_doctorName': dateDoctorname,
      'date_costumerId': dateCostumerid,
      'date_costumerName': dateCostumername,
    };

    if (kIsWeb) {
      final id = DateTime.now().millisecondsSinceEpoch;
      final model = DateModel.full(
        id: id,
        kind: dateKind,
        place: datePlace,
        dateStart: dateDatestart,
        dateEnd: dateDateend,
        note: dateNote,
        doctorId: dateDoctorid,
        doctorName: dateDoctorname,
        costumerId: dateCostumerid,
        costumerName: dateCostumername,
      );
      await FirebaseSyncService.instance.syncDate(model);
      return;
    }

    Database? db = await dbHelper.openDb();
    final newId = await db!.insert('dates', row);

    final model = DateModel.full(
      id: newId,
      kind: dateKind,
      place: datePlace,
      dateStart: dateDatestart,
      dateEnd: dateDateend,
      note: dateNote,
      doctorId: dateDoctorid,
      doctorName: dateDoctorname,
      costumerId: dateCostumerid,
      costumerName: dateCostumername,
    );
    await FirebaseSyncService.instance.pushDate(model);
  }
}
