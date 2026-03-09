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
    String sql = "";
    sql = 'SELECT * from invoices_detail WHERE ID_invoices_id=$id ';
    final List<Map<String, Object?>> queryResult = await db!.rawQuery(sql);
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

    String Sql =
        'INSERT INTO invoices_detail (ID_invoices_id, ID_item_no, ID_item_name, ID_unit_name, ID_unit_qty, ID_unit_price, ID_net_price)  VALUES ';
    Sql = Sql +
        '("$invoices_id","$item_no","$item_name","$unit_name","$unit_qty","$unit_price","$net_price");';
    Database? db = await dbHelper.openDb();
    await db!.execute(Sql);
    
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

    String Sql =
        'UPDATE invoices_detail SET ID_invoices_id="$invoices_id",ID_item_no="$item_no",ID_item_name="$item_name" ';
    Sql =
        '$Sql ,ID_unit_name="وحدة" ,ID_unit_qty="$unit_qty" ,ID_unit_price="$unit_price" ,ID_net_price="$net_price" ';
    Sql = '$Sql    WHERE ID_id="$id"';

    Database? db = await dbHelper.openDb();
    await db!.execute(Sql);

    FirebaseSyncService.instance.pushInvoiceDetail(model);
  }

  // دالة حذف جميع تفاصيل الفاتورة برقمها
  Future<void> deleteInvoicesDetailsByInvoiceNo(String invoiceNo) async {
    String sql =
        'DELETE FROM invoices_detail WHERE ID_invoices_id="$invoiceNo"';
    Database? db = await dbHelper.openDb();
    print('حذف تفاصيل الفاتورة رقم: $invoiceNo');
    return db!.execute(sql);
  }

  // دالة حذف صنف واحد برقمه
  Future<void> deleteInvoicesDetailById(String detailId) async {
    String sql = 'DELETE FROM invoices_detail WHERE ID_id="$detailId"';
    Database? db = await dbHelper.openDb();
    print('حذف تفصيل الفاتورة رقم: $detailId');
    return db!.execute(sql);
  }
}
