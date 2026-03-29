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

  Future<List<InvoicesModel>> getInvoicesByAccount(String accountNo) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return [];
    String sql = 'SELECT * from invoices WHERE invoice_account_no=?';
    final List<Map<String, Object?>> queryResult = await db.rawQuery(sql, [accountNo]);
    return queryResult.map((e) => InvoicesModel.fromMap(e)).toList();
  }

  Future<InvoicesModel> FindInvioce(String id) async {
    Database? db = await dbHelper.openDb();
    const sql = 'SELECT * from invoices WHERE invoice_id = ?';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql, [id]);
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

    Database? db = await dbHelper.openDb();
    await db!.insert("invoices", model.toMap());
    
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
    await db!.update(
      "invoices",
      model.toMap(),
      where: "invoice_id = ?",
      whereArgs: [id],
    );

    FirebaseSyncService.instance.pushInvoice(model);
  }

  Future<void> deleteInvoice(String id) async {
    Database? db = await dbHelper.openDb();
    if (db == null) return;
    
    // تحويل الـ id للتأكد من توافقيته مع قاعدة البيانات التي تطلبه كـ Integer رقم
    int? parsedId = int.tryParse(id);
    if (parsedId == null) return;
    
    // إيجاد رقم القيد المرتبط بالفاتورة
    final invoice = await db.rawQuery('SELECT invoice_jornal FROM invoices WHERE invoice_id = ?', [parsedId]);
    if (invoice.isNotEmpty) {
      final String journalId = invoice.first['invoice_jornal'].toString();
      // حذف القيد وتفاصيله
      if (journalId.isNotEmpty && journalId != 'null') {
        await db.rawDelete('DELETE FROM journals WHERE journal_id = ?', [journalId]);
        await db.rawDelete('DELETE FROM journals_detail WHERE JD_journal_id = ?', [journalId]);
        // حذف الإيصالات المرافقة للقيد
        await db.rawDelete('DELETE FROM vouchers WHERE voucher_journal = ?', [journalId]);
      }
    }

    // حذف أصناف الفاتورة
    await db.rawDelete(
        'DELETE FROM invoices_detail WHERE ID_invoices_id = ?', [parsedId]);
    // حذف الفاتورة الأساسية
    await db.rawDelete('DELETE FROM invoices WHERE invoice_id = ?', [parsedId]);
    
    if (kIsWeb) {
      // إزالة من مزامنة فايربيس لو كانت مفعلة مستقبلاً
    }
  }

  Future<void> addInvoicesWithDetails(InvoicesModel model) async {
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoice(model);
      for (var d in model.details) {
        await FirebaseSyncService.instance.syncInvoiceDetail(d);
      }
      return;
    }
    Database? db = await dbHelper.openDb();
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.insert("invoices", model.toMap());
      for (var detail in model.details) {
        await txn.insert("invoices_detail", detail.toMap());
      }
    });

    FirebaseSyncService.instance.pushInvoice(model);
    for (var d in model.details) {
      FirebaseSyncService.instance.pushInvoiceDetail(d);
    }
  }

  Future<void> updateInvoicesWithDetails(InvoicesModel model) async {
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoice(model);
      for (var d in model.details) {
        await FirebaseSyncService.instance.syncInvoiceDetail(d);
      }
      return;
    }
    Database? db = await dbHelper.openDb();
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.update(
        "invoices",
        model.toMap(),
        where: "invoice_id = ?",
        whereArgs: [model.id],
      );

      await txn.delete("invoices_detail",
          where: "ID_invoices_id = ?", whereArgs: [model.id]);

      for (var detail in model.details) {
        await txn.insert("invoices_detail", detail.toMap());
      }
    });

    FirebaseSyncService.instance.pushInvoice(model);
    for (var d in model.details) {
      FirebaseSyncService.instance.pushInvoiceDetail(d);
    }
  }
}
