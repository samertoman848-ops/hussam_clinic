import 'package:sqflite/sqflite.dart';
import '../dbhelper.dart';

class DbCleanup {
  static Future<void> resetSequences() async {
    final dbHelper = DbHelper();
    final db = await dbHelper.openDb();
    if (db == null) return;

    await db.transaction((txn) async {
      // Get current max IDs
      final maxJournal = await txn.rawQuery('SELECT MAX(journal_id) as max_id FROM journals');
      final maxInvoice = await txn.rawQuery('SELECT MAX(invoice_id) as max_id FROM invoices');
      final maxVoucher = await txn.rawQuery('SELECT MAX(voucher_id) as max_id FROM vouchers');

      int nextJ = (maxJournal.first['max_id'] as int? ?? 0);
      int nextI = (maxInvoice.first['max_id'] as int? ?? 0);
      int nextV = (maxVoucher.first['max_id'] as int? ?? 0);

      // Reset sequences. 
      // Note: If the MAX is already very large, this won't help unless those records are deleted.
      // But it ensures we don't jump further if the sequence was accidentally set high.
      await txn.rawUpdate("UPDATE sqlite_sequence SET seq = ? WHERE name = 'journals'", [nextJ]);
      await txn.rawUpdate("UPDATE sqlite_sequence SET seq = ? WHERE name = 'invoices'", [nextI]);
      await txn.rawUpdate("UPDATE sqlite_sequence SET seq = ? WHERE name = 'vouchers'", [nextV]);
      
      print('Sequences updated to: Journals=$nextJ, Invoices=$nextI, Vouchers=$nextV');
    });
  }
}
