import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart' as tt;
import 'package:flutter/material.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournaldetails.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournals.dart';
import '../../../main.dart';

class ViewModelJournals {
  ViewModelJournals.impty(){
    dateDate = DateTime.now();
    Selectedtime = TimeOfDay.now();
    currencySelect = "شيكل";
    rate = 1;
    amount=0; //'قيمة الفاتورة'
    saving=false;
    EditeMode=false;
    rows.clear();
    Maxjournals =VMGlobal.Maxjournals;
    MaxInvoices=VMGlobal.MaxInvoices;
    MaxVouchers=VMGlobal.MaxVouchers;
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

  void EditeAlreadyJournals(String id) {
    dbJournals.findJournals(id).then((value) {
      dateDate = DateTime.parse(value.date);
      Selectedtime =TimeOfDay.fromDateTime(dateDate);
      currencySelect=value.currency;
      rate= double.parse(value.rate);
      description=value.discription;
      amount= double.parse(value.amount) ; //'قيمة الفاتورة'
      EditeMode=true;
      saving=true;
      Maxjournals= value.id.toString();
    });
    rows.clear();
    dbJournalDetails.searchJournalsDetail(id).then((journalDetails) {
      int no=0;
      for (var journalDetail in journalDetails) {
        no=no+1;
        rows.add(
          PlutoRow(
            cells: {
              'id': PlutoCell(value: no),
              'id_account': PlutoCell(value: journalDetail.account_id),
              'acc_name': PlutoCell(value: journalDetail.account_name),
              'debit': PlutoCell(value: journalDetail.debit),
              'credit': PlutoCell(value:journalDetail.credit),
              'description': PlutoCell(value:journalDetail.description),
              'currncey': PlutoCell(value: journalDetail.currency),
              'rate': PlutoCell(value: journalDetail.rate),
              'total': PlutoCell(value:journalDetail.debit=='0'?  numberFormat.format(double.parse(journalDetail.rate) * double.parse(journalDetail.credit)) :numberFormat.format(double.parse(journalDetail.rate)* double.parse(journalDetail.debit))),
            },
          ),
        );
      }
    });
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
