import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var dbFactory = databaseFactoryFfi;
  
  // Searching for the active DB file modified recently with size ~1MB
  String? foundDbPath;
  
  void searchIn(String dirPath) {
    if (foundDbPath != null) return;
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) return;
      
      for (var f in dir.listSync()) {
        if (f is File && f.path.endsWith('.db') && f.lengthSync() > 100000) {
           final lastMod = f.lastModifiedSync();
           if (lastMod.isAfter(DateTime.now().subtract(Duration(minutes: 60)))) {
             foundDbPath = f.path;
             return;
           }
        } else if (f is Directory) {
          // Limit depth
          if (p.split(f.path).length <= 4) searchIn(f.path);
        }
      }
    } catch (_) {}
  }

  print('Searching for active DB...');
  searchIn('D:\\');
  
  if (foundDbPath == null) {
    print('Searching in AppData...');
    final appData = Platform.environment['APPDATA'] ?? '.';
    searchIn(p.join(appData, 'hussam', 'db'));
  }
  
  if (foundDbPath == null) {
    print('No active DB found modified in the last hour!');
    return;
  }
  
  print('Repairing DB at $foundDbPath');
  final db = await dbFactory.openDatabase(foundDbPath!);
  
  try {
    await db.transaction((txn) async {
       // --- RENUMBER INVOICES ---
       print('Renumbering Invoices...');
       final oldInvoices = await txn.rawQuery('SELECT invoice_id FROM invoices WHERE invoice_id > 1000000 ORDER BY invoice_id ASC');
       final lastInvoicesSmall = await txn.rawQuery('SELECT MAX(invoice_id) as m FROM invoices WHERE invoice_id < 1000000');
       int nextInvId = (int.tryParse(lastInvoicesSmall.first['m']?.toString() ?? '0') ?? 0) + 1;
       
       for (var row in oldInvoices) {
         final oldId = row['invoice_id'];
         final newId = nextInvId++;
         print('Invoice $oldId -> $newId');
         await txn.execute('UPDATE invoices SET invoice_id = ? WHERE invoice_id = ?', [newId, oldId]);
         await txn.execute('UPDATE invoices_detail SET ID_invoices_id = ? WHERE ID_invoices_id = ?', [newId, oldId]);
       }

       // --- RENUMBER JOURNALS ---
       print('Renumbering Journals...');
       final oldJournals = await txn.rawQuery('SELECT journal_id FROM journals WHERE journal_id > 1000000 ORDER BY journal_id ASC');
       final lastJournalsSmall = await txn.rawQuery('SELECT MAX(journal_id) as m FROM journals WHERE journal_id < 1000000');
       int nextJid = (int.tryParse(lastJournalsSmall.first['m']?.toString() ?? '0') ?? 0) + 1;

       for (var row in oldJournals) {
         final oldId = row['journal_id'];
         final newId = nextJid++;
         print('Journal $oldId -> $newId');
         await txn.execute('UPDATE journals SET journal_id = ? WHERE journal_id = ?', [newId, oldId]);
         await txn.execute('UPDATE journals_detail SET JD_journal_id = ? WHERE JD_journal_id = ?', [newId, oldId]);
         await txn.execute('UPDATE invoices SET invoice_jornal = ? WHERE invoice_jornal = ?', [newId.toString(), oldId.toString()]);
         await txn.execute('UPDATE vouchers SET voucher_journal = ? WHERE voucher_journal = ?', [newId.toString(), oldId.toString()]);
       }

       // --- RENUMBER VOUCHERS ---
       print('Renumbering Vouchers...');
       final oldVouchers = await txn.rawQuery('SELECT voucher_id FROM vouchers WHERE voucher_id > 1000000 ORDER BY voucher_id ASC');
       final lastVouchersSmall = await txn.rawQuery('SELECT MAX(voucher_id) as m FROM vouchers WHERE voucher_id < 1000000');
       int nextVid = (int.tryParse(lastVouchersSmall.first['m']?.toString() ?? '0') ?? 0) + 1;

       for (var row in oldVouchers) {
         final oldId = row['voucher_id'];
         final newId = nextVid++;
         print('Voucher $oldId -> $newId');
         await txn.execute('UPDATE vouchers SET voucher_id = ? WHERE voucher_id = ?', [newId, oldId]);
       }
       
       // --- RESET SEQUENCES ---
       print('Resetting sqlite_sequence...');
       await txn.execute('INSERT OR REPLACE INTO sqlite_sequence (name, seq) VALUES (?, ?)', ['invoices', nextInvId - 1]);
       await txn.execute('INSERT OR REPLACE INTO sqlite_sequence (name, seq) VALUES (?, ?)', ['journals', nextJid - 1]);
       await txn.execute('INSERT OR REPLACE INTO sqlite_sequence (name, seq) VALUES (?, ?)', ['vouchers', nextVid - 1]);
    });
    print('Repair complete for DB: $foundDbPath');
  } catch (e) {
    print('Error: $e');
  } finally {
    await db.close();
  }
}
