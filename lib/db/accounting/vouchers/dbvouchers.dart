import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
class DbVouchers {
  DbHelper dbHelper = DbHelper();

/*  CREATE TABLE "vouchers" (
  "voucher_id"	INTEGER NOT NULL UNIQUE,
  "voucher_no"	INTEGER,
  "voucher_date"	TEXT DEFAULT 'التاريخ',
  "voucher_time"	TEXT DEFAULT 'الساعة',
  "voucher_account"	TEXT DEFAULT 'الحساب/رقم الشخص',
  "voucher_dealer"	TEXT DEFAULT 'اسم الشخص',
  "voucher_payment"	TEXT DEFAULT 'المبلغ المدفوع',
  "voucher_currency"	TEXT DEFAULT 'العملة',
  "voucher_journal"	TEXT DEFAULT 'رقم القيد',
  "voucher_discription"	TEXT DEFAULT 'الوصف',
  "voucher_class"	TEXT DEFAULT 'صرف_قبض',
  PRIMARY KEY("voucher_id" AUTOINCREMENT)
  );*/

  Future<void> addVouchers(
      String account_no ,
      String date,
      String time,
      String account_name ,
      String payment,
      String payment_currency ,
      String jornal ,
      String discription ,
      String type
      ) async {
    Database? db = await dbHelper.openDb();
    final row = {
      'voucher_date': date,
      'voucher_time': time,
      'voucher_account': account_no,
      'voucher_dealer': account_name,
      'voucher_payment': payment,
      'voucher_currency': payment_currency,
      'voucher_journal': jornal,
      'voucher_discription': discription,
      'voucher_class': type,
    };
    await db!.insert('vouchers', row);
  }

  Future<List<Map<String, dynamic>>> getVouchersByAccount(String accountNo) async {
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * FROM vouchers WHERE voucher_account = ? ORDER BY voucher_date ASC';
    return await db!.rawQuery(sql, [accountNo]);
  }

  Future<void> deleteVouchersByJournalId(String journalId) async {
    Database? db = await dbHelper.openDb();
    await db!.delete('vouchers',
        where: 'voucher_journal = ?', whereArgs: [journalId]);
  }

  Future<void> deleteVoucherById(String voucherId) async {
    Database? db = await dbHelper.openDb();
    await db!.delete('vouchers',
        where: 'voucher_id = ?', whereArgs: [voucherId]);
  }
  Future<void> updateVoucher(int id, Map<String, dynamic> row) async {
    Database? db = await dbHelper.openDb();
    await db!.update('vouchers', row, where: 'voucher_id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getVouchersByJournal(String journalId) async {
    Database? db = await dbHelper.openDb();
    return await db!.rawQuery('SELECT * FROM vouchers WHERE voucher_journal = ?', [journalId]);
  }

  Future<void> upsertVoucherByJournal(String journalId, String descriptionPart, Map<String, dynamic> row) async {
    Database? db = await dbHelper.openDb();
    final List<Map<String, dynamic>> existing = await db!.rawQuery(
        'SELECT voucher_id FROM vouchers WHERE voucher_journal = ? AND voucher_discription LIKE ?',
        [journalId, '%$descriptionPart%']);

    if (existing.isNotEmpty) {
      await db.update('vouchers', row,
          where: 'voucher_id = ?', whereArgs: [existing.first['voucher_id']]);
    } else {
      await db.insert('vouchers', row);
    }
  }

  Future<void> deleteVoucherByJournalAndDescription(String journalId, String descriptionPart) async {
    Database? db = await dbHelper.openDb();
    await db!.delete('vouchers',
        where: 'voucher_journal = ? AND voucher_discription LIKE ?',
        whereArgs: [journalId, '%$descriptionPart%']);
  }
}
