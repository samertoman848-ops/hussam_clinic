import 'package:sqflite/sqflite.dart';
import '../../model/patients/InvoiceModel.dart';
import '../dbhelper.dart';

class DbInvoices {
  final String tableName = 'invoices';

  // Create table
  Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        inv_id INTEGER PRIMARY KEY AUTOINCREMENT,
        inv_treatment_plan_id INTEGER NOT NULL,
        inv_patient_id INTEGER NOT NULL,
        inv_tooth_number TEXT NOT NULL,
        inv_treatment_name TEXT NOT NULL,
        inv_treatment_cost REAL NOT NULL,
        inv_doctor_name TEXT NOT NULL,
        inv_invoice_date TEXT NOT NULL,
        inv_is_paid INTEGER NOT NULL DEFAULT 0,
        inv_payment_method TEXT,
        inv_notes TEXT,
        FOREIGN KEY (inv_treatment_plan_id) REFERENCES treatment_plans (tp_id),
        FOREIGN KEY (inv_patient_id) REFERENCES patients (patient_id)
      )
    ''');
  }

  // Insert invoice
  Future<int> insertInvoice(InvoiceModel invoice) async {
    try {
      final db = await DbHelper().getDatabase();
      return await db.insert(tableName, invoice.toMap());
    } catch (e) {
      print('Error inserting invoice: $e');
      return -1;
    }
  }

  // Get all invoices
  Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      final db = await DbHelper().getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      return maps.map((e) => InvoiceModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getting invoices: $e');
      return [];
    }
  }

  // Get invoices by patient
  Future<List<InvoiceModel>> getInvoicesByPatient(int patientId) async {
    try {
      final db = await DbHelper().getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'inv_patient_id = ?',
        whereArgs: [patientId],
      );
      return maps.map((e) => InvoiceModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getting patient invoices: $e');
      return [];
    }
  }

  // Get invoices by doctor
  Future<List<InvoiceModel>> getInvoicesByDoctor(String doctorName) async {
    try {
      final db = await DbHelper().getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'inv_doctor_name = ?',
        whereArgs: [doctorName],
      );
      return maps.map((e) => InvoiceModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getting doctor invoices: $e');
      return [];
    }
  }

  // Get unpaid invoices
  Future<List<InvoiceModel>> getUnpaidInvoices() async {
    try {
      final db = await DbHelper().getDatabase();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'inv_is_paid = 0',
      );
      return maps.map((e) => InvoiceModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getting unpaid invoices: $e');
      return [];
    }
  }

  // Update invoice
  Future<int> updateInvoice(InvoiceModel invoice) async {
    try {
      final db = await DbHelper().getDatabase();
      return await db.update(
        tableName,
        invoice.toMap(),
        where: 'inv_id = ?',
        whereArgs: [invoice.invoiceId],
      );
    } catch (e) {
      print('Error updating invoice: $e');
      return -1;
    }
  }

  // Mark invoice as paid
  Future<int> markAsPaid(int invoiceId) async {
    try {
      final db = await DbHelper().getDatabase();
      return await db.update(
        tableName,
        {'inv_is_paid': 1},
        where: 'inv_id = ?',
        whereArgs: [invoiceId],
      );
    } catch (e) {
      print('Error marking invoice as paid: $e');
      return -1;
    }
  }

  // Delete invoice
  Future<int> deleteInvoice(int invoiceId) async {
    try {
      final db = await DbHelper().getDatabase();
      return await db.delete(
        tableName,
        where: 'inv_id = ?',
        whereArgs: [invoiceId],
      );
    } catch (e) {
      print('Error deleting invoice: $e');
      return -1;
    }
  }

  // Get doctor's total earnings
  Future<double> getDoctorTotalEarnings(String doctorName) async {
    try {
      final db = await DbHelper().getDatabase();
      final result = await db.rawQuery(
        'SELECT SUM(inv_treatment_cost) as total FROM $tableName WHERE inv_doctor_name = ? AND inv_is_paid = 1',
        [doctorName],
      );
      if (result.isNotEmpty && result[0]['total'] != null) {
        return (result[0]['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Error calculating doctor earnings: $e');
      return 0.0;
    }
  }

  // Get doctor's pending earnings
  Future<double> getDoctorPendingEarnings(String doctorName) async {
    try {
      final db = await DbHelper().getDatabase();
      final result = await db.rawQuery(
        'SELECT SUM(inv_treatment_cost) as total FROM $tableName WHERE inv_doctor_name = ? AND inv_is_paid = 0',
        [doctorName],
      );
      if (result.isNotEmpty && result[0]['total'] != null) {
        return (result[0]['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Error calculating pending earnings: $e');
      return 0.0;
    }
  }
}
