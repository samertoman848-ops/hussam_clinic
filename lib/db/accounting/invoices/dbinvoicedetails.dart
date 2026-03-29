import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesDetailModel.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DbInvoicesDetails {
  DbHelper dbHelper = DbHelper();

  // CREATE TABLE "invoices_detail" (
  // "ID_id"	INTEGER NOT NULL UNIQUE,
  // "ID_invoices_id"	TEXT DEFAULT 'رقم الفاتورة',
  // "ID_item_no"	TEXT DEFAULT 'رقم الصنف',
  // "ID_item_name"	TEXT DEFAULT 'اسم الصنف',
  // "ID_unit_name"	TEXT DEFAULT 'الوحدة',
  // "ID_unit_qty"	TEXT DEFAULT 'الكمية',
  // "ID_unit_price"	TEXT DEFAULT 'سعر الوحدة',
  // "ID_net_price"	TEXT DEFAULT 'الإجمالي',
  // PRIMARY KEY("ID_id" AUTOINCREMENT)
  // );

  Future<void> addInvoicesDetails(
      InvoicesDetailModel invoicesDetailModel) async {
    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoiceDetail(invoicesDetailModel);
      return;
    }
    Database? db = await dbHelper.openDb();
    await db!.insert("invoices_detail", invoicesDetailModel.toMap());
    
    FirebaseSyncService.instance.pushInvoiceDetail(invoicesDetailModel);
  }

  Future<List<InvoicesDetailModel>> searchInvoicesDetails(String id) async {
    if (kIsWeb) {
      final snap = await FirebaseFirestore.instance
          .collection('invoices/$id/details')
          .get();
      return snap.docs.map((doc) => InvoicesDetailModel.fromMap(doc.data())).toList();
    }
    Database? db = await dbHelper.openDb();
    const sql = 'SELECT * from invoices_detail WHERE ID_invoices_id = ?';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql, [id]);
    return queryResult.map((e) => InvoicesDetailModel.fromMap(e)).toList();
  }

  Future<List<InvoicesDetailModel>> getAllInvoicesDetails() async {
    Database? db = await dbHelper.openDb();
    if (db == null) return [];
    String sql = 'SELECT * from invoices_detail';
    final List<Map<String, Object?>> queryResult = await db.rawQuery(sql);
    return queryResult.map((e) => InvoicesDetailModel.fromMap(e)).toList();
  }

  Future<void> addInvoicesDetails2(
      String invoices_id,
      String item_no,
      String item_name,
      String unit_name,
      String unit_qty,
      String unit_price,
      String net_price) async {
    
    final model = InvoicesDetailModel.full(
      id: DateTime.now().millisecondsSinceEpoch,
      invoicesId: invoices_id,
      itemNo: item_no,
      itemName: item_name,
      unitName: unit_name,
      unitQty: unit_qty,
      unitPrice: unit_price,
      netPrice: net_price,
    );

    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoiceDetail(model);
      return;
    }

    Database? db = await dbHelper.openDb();
    await db!.insert("invoices_detail", model.toMap());
    
    FirebaseSyncService.instance.pushInvoiceDetail(model);
  }

  Future<void> UpdateInvoicesDetails(
      String id,
      String invoices_id,
      String item_no,
      String item_name,
      String unit_name,
      String unit_qty,
      String unit_price,
      String net_price) async {
    
    final model = InvoicesDetailModel.full(
        id: int.tryParse(id) ?? 0,
        invoicesId: invoices_id,
        itemNo: item_no,
        itemName: item_name,
        unitName: unit_name,
        unitQty: unit_qty,
        unitPrice: unit_price,
        netPrice: net_price,
    );

    if (kIsWeb) {
      await FirebaseSyncService.instance.syncInvoiceDetail(model);
      return;
    }

    Database? db = await dbHelper.openDb();
    await db!.update(
      "invoices_detail",
      model.toMap(),
      where: "ID_id = ?",
      whereArgs: [id],
    );

    FirebaseSyncService.instance.pushInvoiceDetail(model);
  }

  // دالة حذف جميع تفاصيل الفاتورة برقمها
  Future<void> deleteInvoicesDetailsByInvoiceNo(String invoiceNo) async {
    Database? db = await dbHelper.openDb();
    print('حذف تفاصيل الفاتورة رقم: $invoiceNo');
    await db!.delete(
      "invoices_detail",
      where: "ID_invoices_id = ?",
      whereArgs: [invoiceNo],
    );
  }

  // دالة حذف صنف واحد برقمه
  Future<void> deleteInvoicesDetailById(String detailId) async {
    Database? db = await dbHelper.openDb();
    print('حذف تفصيل الفاتورة رقم: $detailId');
    await db!.delete(
      "invoices_detail",
      where: "ID_id = ?",
      whereArgs: [detailId],
    );
  }
}
