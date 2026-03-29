import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/model/accounting/journals/IndexModel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DbIndex {
  DbHelper dbHelper = DbHelper();
  Future<List<IndexModel>> allAccountingIndexes() async {
    Database? db = await dbHelper.openDb();
    if (db == null) return [];
    String sql = "";
    sql = 'SELECT * from indexes';
    final List<Map<String, Object?>> queryResult = await db.rawQuery(sql);
    return queryResult.map((e) => IndexModel.fromMap(e)).toList();
  }

  Future<void> addIndex(IndexModel index) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;
    await db.insert('indexes', index.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateIndex(IndexModel index) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;
    await db.update('indexes', index.toMap(), where: 'index_no = ?', whereArgs: [index.no]);
  }

  Future<void> deleteIndex(int id) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;
    await db.delete('indexes', where: 'index_no = ?', whereArgs: [id]);
  }

  Future<int> getMaxIndexNo() async {
    Database? db = await dbHelper.openDb();
    if (db == null) return 1;
    final result = await db.rawQuery('SELECT MAX(index_no) as max_no FROM indexes');
    if (result.first['max_no'] != null) {
      return (result.first['max_no'] as int) + 1;
    }
    return 1;
  }

  Future<List<Map<String, dynamic>>> getItemsReport() async {
    Database? db = await dbHelper.openDb();
    if (db == null) return [];
    String sql = '''
      SELECT 
        i.index_no,
        i.index_name,
        i.index_description AS warehouse,
        CAST(IFNULL(i.index_ini_balance, '0') AS REAL) as initial_balance,
        (SELECT SUM(CAST(id.ID_unit_qty AS REAL)) FROM invoices_detail id JOIN invoices inv ON id.ID_invoices_id = inv.invoice_id WHERE id.ID_item_no = CAST(i.index_no AS TEXT) AND inv.invoice_class = 'المشتريات') as total_in,
        (SELECT SUM(CAST(id.ID_unit_qty AS REAL)) FROM invoices_detail id JOIN invoices inv ON id.ID_invoices_id = inv.invoice_id WHERE id.ID_item_no = CAST(i.index_no AS TEXT) AND inv.invoice_class = 'المبيعات') as total_out
      FROM indexes i
    ''';
    final result = await db.rawQuery(sql);
    return result;
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
    Database? db = await dbHelper.openDb();
    if (db == null) return;
    await db.execute(
        'INSERT INTO dates (date_kind, date_place, date_dateStart , date_dateEnd, date_note,date_doctorId ,date_doctorName, date_costumerId, date_costumerName) VALUES ("$dateKind","$datePlace","$dateDatestart","$dateDateend","$dateNote","$dateDoctorid","$dateDoctorname","$dateCostumerid","$dateCostumername");');
  }
}
