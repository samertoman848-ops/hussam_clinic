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

    String Sql='INSERT INTO vouchers ( "voucher_date", "voucher_time", "voucher_account", "voucher_dealer", "voucher_payment", "voucher_currency", "voucher_journal", "voucher_discription", "voucher_class") VALUES ';
    Sql=Sql+'("$date","$time","$account_no","$account_name","$payment","$payment_currency","$jornal","$discription","$type");';
    Database? db = await dbHelper.openDb();
    return db!.execute(Sql) ;
  }
}
