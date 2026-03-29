import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/model/accounting/journals/journalsModel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DbJournals {
  DbHelper dbHelper = DbHelper();

  // CREATE TABLE "journals" (
  // "journal_id"	INTEGER NOT NULL UNIQUE,
  // "journal_date"	TEXT DEFAULT 'تاريخ القيد',
  // "journal_time"	TEXT DEFAULT 'وقت القيد',
  // "journal_amount"	TEXT DEFAULT 'مبلغ القيد',
  // "journal_currency"	TEXT DEFAULT 'العملة',
  // "journal_rate"	TEXT DEFAULT 'التحويل',
  // "journal_description"	TEXT DEFAULT 'الوصف',
  // PRIMARY KEY("journal_id" AUTOINCREMENT)
  // );

  Future<List<JournalsModel>> allJournals() async {
    Database? db = await dbHelper.openDb();
    String sql = "";
    sql = 'SELECT * from journals ';
    final List<Map<String, Object?>> queryResult = await  db!.rawQuery(sql);
    return queryResult.map((e) => JournalsModel.fromMap(e)).toList();
  }


  Future <JournalsModel> findJournals(String id) async {
    Database? db = await dbHelper.openDb();
    const sql = 'SELECT * from journals WHERE journal_id=?';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql, [id]);
    return JournalsModel.fromMap(queryResult.first) ;
  }

  Future<void> updatejournals(
      String journalDate, String journalTime,
      String journalAmount,String journalCurrency,
      String journalRate,  String journalDescription,String journalId
      ) async {
    Database? db = await dbHelper.openDb();
    await db!.update(
      'journals',
      {
        'journal_date': journalDate,
        'journal_time': journalTime,
        'journal_amount': journalAmount,
        'journal_currency': journalCurrency,
        'journal_rate': journalRate,
        'journal_description': journalDescription,
      },
      where: 'journal_id = ?',
      whereArgs: [journalId],
    );
  }

  Future<void> addjournals(
      String date,
      String time,
      String amount,
      String currency,
      String rate,
      String description,
      ) async {
    Database? db = await dbHelper.openDb();
    await db!.insert(
      'journals',
      {
        'journal_date': date,
        'journal_time': time,
        'journal_amount': amount,
        'journal_currency': currency,
        'journal_rate': rate,
        'journal_description': description,
      },
    );
  }
  Future<void> deleteJournal(String id) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;

    await db.transaction((txn) async {
      // 1. Delete Journals Details
      await txn.delete('journals_detail',
          where: 'JD_journal_id = ?', whereArgs: [id]);

      // 2. Delete linked Vouchers
      await txn.delete('vouchers',
          where: 'voucher_journal = ?', whereArgs: [id]);

      // 3. Delete linked Invoices (Accounting + Clinical)
      // Check for direct match or prefixed matches
      await txn.delete('invoices',
          where: 'invoice_jornal = ? OR invoice_jornal = ? OR invoice_jornal = ? OR invoice_jornal = ?',
          whereArgs: [id, 'S$id', 'E$id', 'CL$id']);

      // 4. Delete the Journal itself
      await txn.delete('journals',
          where: 'journal_id = ?', whereArgs: [id]);
    });
  }

  Future<void> addJournalWithDetails(JournalsModel model) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.insert('journals', model.toMap());
      for (var detail in model.details) {
        await txn.insert('journals_detail', detail.toMap());
      }
    });
  }

  Future<void> updateJournalWithDetails(JournalsModel model) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.update(
        'journals',
        model.toMap(),
        where: 'journal_id = ?',
        whereArgs: [model.id],
      );

      await txn.delete('journals_detail',
          where: 'JD_journal_id = ?', whereArgs: [model.id]);

      for (var detail in model.details) {
        await txn.insert('journals_detail', detail.toMap());
      }
    });
  }
}
