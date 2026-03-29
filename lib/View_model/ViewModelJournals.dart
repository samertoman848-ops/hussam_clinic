import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart' as tt;
import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournaldetails.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournals.dart';
import '../../../main.dart';

class ViewModelJournals {
  ViewModelJournals.impty(){
    reset();
  }
  
  void reset() {
    dateDate = DateTime.now();
    Selectedtime = TimeOfDay.now();
    currencySelect = "شيكل";
    rate = 1;
    amount = 0;
    saving = false;
    EditeMode = false;
    rows.clear();
    Maxjournals = VMGlobal.Maxjournals;
    MaxInvoices = VMGlobal.MaxInvoices;
    MaxVouchers = VMGlobal.MaxVouchers;
    stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: FocusNode(),
      scroll: PlutoGridScrollController(),
    );
  }
  
  void addNewRow() {
    final int lastIndex = stateManager.refRows.originalList.length;
    stateManager.insertRows(lastIndex, [
      PlutoRow(
        cells: {
          'id': PlutoCell(value: lastIndex + 1),
          'id_account': PlutoCell(value: ''),
          'acc_name': PlutoCell(value: ''),
          'debit': PlutoCell(value: 0),
          'credit': PlutoCell(value: 0),
          'description': PlutoCell(value: ''),
          'currncey': PlutoCell(value: currencySelect),
          'rate': PlutoCell(value: rate),
          'total': PlutoCell(value: 0),
        },
      )
    ]);
  }
  /// Styles and Color
  Color primaryColor = const Color(0xffd0d4d7); //corner
  Color accentColor = const Color(0xff3f86bd); //background
  TextStyle textStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.green,
    fontSize: 18,
  );
  TextStyle textStyleLabel =const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontSize: 18,);
  ///
  /// Styles and Color

  DateTime dateDate = DateTime.now();
  TimeOfDay Selectedtime = TimeOfDay.now();

  final currnceyList = ['شيكل', 'دولار', 'دينار'];
  late String currencySelect = "شيكل";
  double rate = 1;
  double amount=0; //'قيمة الفاتورة'
  String  description = "شيكل";
  var numberFormat =tt.NumberFormat("###.0#", "en_US");
  late bool saving=false;
  bool EditeMode=false;

  DbJournals dbJournals = DbJournals();
  DbJournalDetails dbJournalDetails = DbJournalDetails();
 String Maxjournals ='1';
  String MaxInvoices='1';
  String MaxVouchers='1';

  late final  List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'الرقم',
      field: 'id',
      width:60,
      minWidth:PlutoGridSettings.minColumnWidth,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'رقم الحساب',
      field: 'id_account',
      //width:60,
      minWidth:100,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
      //hide : true,
    ),
    PlutoColumn(
      title: 'اسم الحساب',
      field: 'acc_name',
      width:300,
      minWidth:140,
      type:PlutoColumnType.text(),//PlutoColumnType.select(<AccoutingTreeModel> allAccountingTree ),//
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'مدين',
      field: 'debit',
      minWidth:120,
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
      type: PlutoColumnType.currency(locale:"ar",allowFirstDot : true,format: '#,###.##',),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.sum,
          format: '#,###.##',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'الاجمالي',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ' : '),
              TextSpan(text: text,style: const TextStyle(color: Colors.red),),
              const TextSpan(text: ' '),
              TextSpan(text: currencySelect,style: const TextStyle(color: Colors.red),),
            ];
          },
        );
      },
    ),
    PlutoColumn(
      title: 'دائن',
      field: 'credit',
      //width:120,
      minWidth:120,
      //type: PlutoColumnType.number(negative : false),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
      type: PlutoColumnType.currency(locale:"ar",allowFirstDot : true,format: '#,###.##',),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          type: PlutoAggregateColumnType.sum,
          format: '#,###.##',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'الاجمالي',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ' : '),
              TextSpan(text: text,style: const TextStyle(color: Colors.red),),
              const TextSpan(text: ' '),
              TextSpan(text: currencySelect,style: const TextStyle(color: Colors.red),),
            ];
          },
        );
      },
    ),
    PlutoColumn(
      title: 'الوصف',
      field: 'description',
      //width:120,
      minWidth:300,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title:  'عملة الحساب',
      field: 'currncey',
      width:200,
      minWidth:140,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title:  'سعر العملة',
      field: 'rate',
      width:200,
      minWidth:140,
      type: PlutoColumnType.number(format :'#.##',negative : false),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'مبلغ الحساب ',
      field: 'total',
      width:200,
      minWidth:140,
      readOnly : false,
      type: PlutoColumnType.currency(locale:"ar",allowFirstDot : true,format: '#,###.##',),
    ),
  ];

  late final  List<PlutoRow> rows = [];

  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late  PlutoGridStateManager stateManager;
  List<String> persons=[];


  ///TODO Functions
  ///
  Future<DateTime?> pickDate(context) {
    return showDatePicker(
      context: context,
      initialDate: dateDate,
      firstDate: DateTime(2019),
      lastDate: DateTime(2620),
    );
  }

  Future<TimeOfDay?> picktime(context) async {
    return  showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  Future<void> EditeAlreadyJournals(String id) async {
    reset(); 
    final value = await dbJournals.findJournals(id);
    dateDate = DateTime.parse(value.date);
    Selectedtime = TimeOfDay.fromDateTime(dateDate);
    currencySelect = value.currency;
    rate = double.tryParse(value.rate) ?? 1.0;
    description = value.discription;
    amount = double.tryParse(value.amount) ?? 0.0;
    EditeMode = true;
    saving = true;
    Maxjournals = value.id.toString();

    rows.clear();
    final journalDetails = await dbJournalDetails.searchJournalsDetail(id);
    int no = 0;
    for (var journalDetail in journalDetails) {
      no = no + 1;
      rows.add(
        PlutoRow(
          cells: {
            'id': PlutoCell(value: no),
            'id_account': PlutoCell(value: journalDetail.account_id),
            'acc_name': PlutoCell(value: journalDetail.account_name),
            'debit': PlutoCell(value: double.tryParse(journalDetail.debit) ?? 0.0),
            'credit': PlutoCell(value: double.tryParse(journalDetail.credit) ?? 0.0),
            'description': PlutoCell(value: journalDetail.description),
            'currncey': PlutoCell(value: journalDetail.currency),
            'rate': PlutoCell(value: double.tryParse(journalDetail.rate) ?? 1.0),
            'total': PlutoCell(value: journalDetail.debit == '0'
                ? double.parse(journalDetail.rate) * double.parse(journalDetail.credit)
                : double.parse(journalDetail.rate) * double.parse(journalDetail.debit)),
          },
        ),
      );
    }
    stateManager.refRows.clear();
    stateManager.insertRows(0, rows);
  }

  Future<void> saveJournal() async {
    try {
      saving = true;
      final dateStr = '${dateDate.year}-${dateDate.month.toString().padLeft(2, '0')}-${dateDate.day.toString().padLeft(2, '0')}';
      final timeStr = '${Selectedtime.hour}:${Selectedtime.minute.toString().padLeft(2, '0')}';
      
      // Calculate total amount from debits
      double totalDebit = 0;
      for (var row in stateManager.rows) {
        totalDebit += (row.cells['debit']?.value ?? 0).toDouble();
      }

      if (EditeMode) {
        // 1. Update Journal Header
        await dbJournals.updatejournals(
          dateStr,
          timeStr,
          totalDebit.toString(),
          currencySelect,
          rate.toString(),
          description,
          Maxjournals,
        );

        // 2. Refresh Details
        await dbJournalDetails.deleteJournalDetailsByJournalId(Maxjournals);
        for (var row in stateManager.rows) {
          await dbJournalDetails.addjournalDetails(
            Maxjournals,
            row.cells['id_account']!.value.toString(),
            row.cells['acc_name']!.value.toString(),
            row.cells['debit']!.value.toString(),
            row.cells['credit']!.value.toString(),
            row.cells['description']!.value.toString(),
            row.cells['currncey']!.value.toString(),
            row.cells['rate']!.value.toString(),
            row.cells['total']!.value.toString(),
          );
        }

        // 3. Sync with Source Records (Invoices/Vouchers)
        final dbConn = await dbJournals.dbHelper.openDb();
        
        // Update linked vouchers
        await dbConn!.update(
          'vouchers',
          {'voucher_payment': totalDebit.toString()},
          where: 'voucher_journal = ?',
          whereArgs: [Maxjournals],
        );
        
        // Update linked invoices
        // Note: For invoices, we update amount_all and net totals
        await dbConn.update(
          'invoices',
          {
            'invoice_amount': totalDebit.toString(),
            'invoice_amount_all': totalDebit.toString(),
          },
          where: 'invoice_jornal = ?',
          whereArgs: [Maxjournals],
        );

      } else {
        // NEW JOURNAL
        await dbJournals.addjournals(
          dateStr,
          timeStr,
          totalDebit.toString(),
          currencySelect,
          rate.toString(),
          description,
        );
        
        final dbConn = await dbJournals.dbHelper.openDb();
        final lastJ = await dbConn!.rawQuery("SELECT MAX(journal_id) as id FROM journals");
        final newId = lastJ.first['id'].toString();

        for (var row in stateManager.rows) {
          await dbJournalDetails.addjournalDetails(
            newId,
            row.cells['id_account']!.value.toString(),
            row.cells['acc_name']!.value.toString(),
            row.cells['debit']!.value.toString(),
            row.cells['credit']!.value.toString(),
            row.cells['description']!.value.toString(),
            row.cells['currncey']!.value.toString(),
            row.cells['rate']!.value.toString(),
            row.cells['total']!.value.toString(),
          );
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      saving = false;
    }
  }

  InputDecoration inputDecorationNoIcon (String hintText) {
    return InputDecoration(
      hintText:hintText,
      filled:true,
      fillColor:Colors.white,
      hintStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
      errorStyle: const TextStyle(color:Colors.yellow,fontSize: 15,fontWeight: FontWeight.bold),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.grey),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
            width: 1, color: Color(0xffF02E65)),
      ),
      border: const OutlineInputBorder(
          borderSide: BorderSide(width: 1)),
    );
  }

  InputDecoration inputDecoration (IconData icon,String hintText) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 35),
      hintText:hintText,
      filled:true,
      fillColor:Colors.white,
      hintStyle: const TextStyle(fontSize: 20),
      errorStyle: const TextStyle(color:Colors.yellow,fontSize: 15,fontWeight: FontWeight.bold),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 3, color: Colors.white),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
            width: 4, color: Color(0xffF02E65)),
      ),
      border: const OutlineInputBorder(
          borderSide: BorderSide(width: 1)),
    );
  }

}
