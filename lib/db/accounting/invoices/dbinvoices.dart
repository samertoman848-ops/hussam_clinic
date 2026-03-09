import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../../../model/accounting/invoices/InvoicesModel.dart';

class DbInvoices {
  DbHelper dbHelper = DbHelper();

  Future<List<InvoicesModel>> allInvioces() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('invoices')
          .where('invoice_class', isEqualTo: 'المبيعات')
          .get();
      return snap.docs.map((doc) => InvoicesModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from invoices where invoice_class=?';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql, ['المبيعات']);
    return queryResult.map((e) => InvoicesModel.fromMap(e)).toList();
  }

  Future<List<InvoicesModel>> expenseInvioces() async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('invoices')
          .where('invoice_class', isEqualTo: 'المشتريات')
          .get();
      return snap.docs.map((doc) => InvoicesModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    String sql = 'SELECT * from invoices where invoice_class=?';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql, ['المشتريات']);
    return queryResult.map((e) => InvoicesModel.fromMap(e)).toList();
  }

  Future<List<InvoicesModel>> getAllInvoices() async {
    Database? db = await dbHelper.openDb();
    if (db == null) return [];
    String sql = 'SELECT * from invoices';
    final List<Map<String, Object?>> queryResult = await db.rawQuery(sql);
    return queryResult.map((e) => InvoicesModel.fromMap(e)).toList();
  }

  Future<InvoicesModel> FindInvioce(String id) async {
    Database? db = await dbHelper.openDb();
    String sql = "";
    sql = 'SELECT * from invoices WHERE invoice_id=$id ';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
    return InvoicesModel.fromMap(queryResult.first);
  }
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

  Future<void> addInvoices(InvoicesModel model) async {
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoice(model);
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.insert("invoices", model.toMap());
    
    FirebaseSyncService.instance.pushInvoice(model);
  }

  Future<void> addInvoices2(
      String rate,
      String date,
      String time,
      String account_no,
      String account_name,
      String accountingTo_no,
      String accountingTo_name,
      String amount,
      String disscount,
      String amount_all,
      String currency,
      String payment,
      String payment_currency,
      String remaining,
      String jornal,
      String discription,
      String type) async {
    
    final model = InvoicesModel.full(
      id: DateTime.now().millisecondsSinceEpoch, // temporary ID for web or before SQL insert
      rate: rate,
      date: date,
      time: time,
      accountNo: account_no,
      accountName: account_name,
      accountingToNo: accountingTo_no,
      accountingToName: accountingTo_name,
      amount: amount,
      disscount: disscount,
      amountAll: amount_all,
      currency: currency,
      payment: payment,
      paymentCurrency: payment_currency,
      remaining: remaining,
      jornal: jornal,
      discription: discription,
      type: type,
    );

    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoice(model);
      return;
    }

    String Sql =
        'INSERT INTO invoices (invoice_rate, invoice_date, invoice_time, invoice_account_no, invoice_account_name, invoice_accountingTo_no, invoice_accountingTo_name, invoice_amount, invoice_disscount, invoice_amount_all, invoice_currency, invoice_payment, invoice_payment_currency, invoice_remaining, invoice_jornal, invoice_discription, invoice_class) VALUES ';
    Sql = Sql +
        '("$rate","$date","$time","$account_no","$account_name","$accountingTo_no", "$accountingTo_name","$amount","$disscount","$amount_all","$currency","$payment","$payment_currency","$remaining","$jornal","","$type");';
    Database? db = await dbHelper.openDb();
    await db!.execute(Sql);
    
    FirebaseSyncService.instance.pushInvoice(model);
  }

  Future<void> updateInvoices(
      String id,
      String rate,
      String date,
      String time,
      String account_no,
      String account_name,
      String accountingTo_no,
      String accountingTo_name,
      String amount,
      String disscount,
      String amount_all,
      String currency,
      String payment,
      String payment_currency,
      String remaining,
      String jornal,
      String discription,
      String type) async {
    
    final model = InvoicesModel.full(
      id: int.tryParse(id) ?? 0,
      rate: rate,
      date: date,
      time: time,
      accountNo: account_no,
      accountName: account_name,
      accountingToNo: accountingTo_no,
      accountingToName: accountingTo_name,
      amount: amount,
      disscount: disscount,
      amountAll: amount_all,
      currency: currency,
      payment: payment,
      paymentCurrency: payment_currency,
      remaining: remaining,
      jornal: jornal,
      discription: discription,
      type: type,
    );

    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoice(model);
      return;
    }

    Database? db = await dbHelper.openDb();
    String sql =
        'UPDATE invoices SET invoice_rate="$rate",invoice_date="$date",invoice_time="$time",invoice_account_no="$account_no",invoice_account_name="$account_name"';
    sql = sql +
        ' ,invoice_accountingTo_no="$accountingTo_no" ,invoice_accountingTo_name="$accountingTo_name" ,invoice_amount="$amount" ,invoice_disscount="$disscount" ';
    sql = sql +
        ' ,invoice_amount_all="$amount_all" ,invoice_currency="$currency" ,invoice_payment="$payment" ,invoice_payment_currency="$payment_currency"  ,invoice_remaining="$remaining" ';
    sql = sql +
        ' ,invoice_jornal="$jornal"  ,invoice_discription="$discription"  ,invoice_class="$type"  WHERE invoice_id="$id"';
    await db!.rawQuery(sql);

    FirebaseSyncService.instance.pushInvoice(model);
  }

  Future<void> deleteInvoice(String id) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;
    // delete invoice details first
    await db.rawDelete(
        'DELETE FROM invoices_detail WHERE ID_invoices_id = ?', [id]);
    // delete the invoice
    await db.rawDelete('DELETE FROM invoices WHERE invoice_id = ?', [id]);
  }
}
