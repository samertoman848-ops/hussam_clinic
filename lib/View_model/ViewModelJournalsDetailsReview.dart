import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart' as tt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/db/accounting/invoices/dbinvoicedetails.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournaldetails.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournals.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesDetailModel.dart';
import '../../../db/accounting/invoices/dbinvoices.dart';
import '../../../db/accounting/vouchers/dbvouchers.dart';
import '../../../main.dart';
import '../model/accounting/invoices/InvoicesModel.dart';

class ViewModelJournalsDetailsReview {
  ViewModelJournalsDetailsReview.impty(){
    AccountingTo_select_name='f';
    dateDate = DateTime.now();
    Selectedtime = TimeOfDay.now();
    AccountingGroups_select='المرضي';
    AccountingPerson_select_name='o';
    AccountingPerson_select_id='o';
    AccountingTo_select_id='120101';
    AccountingTo_select_name='صندوق العيادة';
    currencySelect = "شيكل";
     rate = 1;
    amount=0; //'قيمة الفاتورة'
    disscount=0; //'قيمة الخصم
    amount_all=0; //'قيمة الفاتورة الكلية'
    payment=0; //المدفوع
    payment_currency="شيكل";
    remaining=0;//المبلغ المتبقي
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

  String AccountingGroups_select='المورديين';
  String AccountingPerson_select_name='o';
  String AccountingPerson_select_id='o';

  String AccountingTo_select_id='120101';
  String AccountingTo_select_name='صندوق العيادة';

  final currnceyList = ['شيكل', 'دولار', 'دينار'];
  late String currencySelect = "شيكل";
  double rate = 1;
  double amount=0; //'قيمة الفاتورة'
  double disscount=0; //'قيمة الخصم
  double amount_all=0; //'قيمة الفاتورة الكلية'
  double payment=0; //المدفوع
  String payment_currency="شيكل";
  double remaining=0;//المبلغ المتبقي
  double remaining_pre=0;// القديم المبلغ المتبقي
  double payment_pre=0;// القديم المبلغ المتبقي
  var numberFormat =tt.NumberFormat("###.0#", "en_US");
  late bool saving=false;
  bool EditeMode=false;

  DbInvoices dbInvoices = DbInvoices();
  DbInvoicesDetails dbInvoicesDetails = DbInvoicesDetails();
  InvoicesModel invoicesModelEdite = InvoicesModel.name();
  String Maxjournals ='1';
  String MaxInvoices='1';
  String MaxVouchers='1';

  late final  List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'الرقم',
      field: 'id',
      width:60,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
      hide : true,
    ),
    PlutoColumn(
      title: 'رقم الفاتورة',
      field: 'id_invoice',
      width:60,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
      hide : true,
    ),
    PlutoColumn(
      title: 'رقم الصنف',
      field: 'id_item',
      width:130,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'اسم الصنف',
      field: 'name',
      width:380,
      type:  PlutoColumnType.select(allAccountingIndex_s,enableColumnFilter : true),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'الكمية',
      width:120,
      field: 'qty',
      type: PlutoColumnType.number(negative : false),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'السعر',
      width:120,
      field: 'price',
      type: PlutoColumnType.number(format :'#.##',negative : false),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign : PlutoColumnTextAlign.center,
      titleTextAlign : PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'الاجمالي',
      field: 'total',
      width:120,
      readOnly : false,
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
  ];

  late final  List<PlutoRow> rows = [];

  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late  PlutoGridStateManager stateManager;
  List<String> persons=[];

  void selecedId(String value) {
    if( AccountingGroups_select=='المرضي'){
      for (var e in allAccountingCoustmers) {
        if(e.name==value){
          AccountingPerson_select_id=e.branch_no.toString();
        }
      }
    }else if( AccountingGroups_select=='المورديين'){
      for (var e in allAccountingSuppliers) {
        if(e.name==value){
          AccountingPerson_select_id=e.branch_no.toString();
        }
      }
    }else if(AccountingGroups_select=='الموظفين'){
      for (var e in allAccountingEmployees) {
        if(e.name==value){
          AccountingPerson_select_id=e.branch_no.toString();
        }
      }
    }
  }

  void selecedIndexId(String value) {
    for (var e in allAccountingIndex) {
      if(e.name==value){
        AccountingIndexModel=e;
        AccountingIndx_select_id=e.no.toString();
      }
    }
  }

  void checkValues2() {
    persons.clear();
    if( AccountingGroups_select=='المرضي'){
      persons.addAll(allAccountingCoustmers_s) ;
    }else if( AccountingGroups_select=='المورديين'){
      persons.addAll(allAccountingSuppliers_s);
    }else if(AccountingGroups_select=='الموظفين'){
      persons .addAll(allAccountingEmployees_s);
    }
  }

  ///TODO Functions
  ///
  void checkValues() {
    AccountingGroups_select='المرضي';
    allAccountingContens.clear();
    if(allAccountingCoustmers_s.isNotEmpty){
      allAccountingContens.add('المرضي');
    }
    if(allAccountingSuppliers_s.isNotEmpty){
      allAccountingContens.add('المورديين');
    }
    if(allAccountingEmployees_s.isNotEmpty){
      allAccountingContens.add('الموظفين');
    }
  }

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
  void AddNewRecord(){
    final int lastIndex = stateManager.refRows.originalList.length;
    stateManager.insertRows(lastIndex,
        [
          PlutoRow(cells:
          {
            'id': PlutoCell(value: '0'),
            'id_invoice': PlutoCell(value: MaxInvoices),
            'id_item': PlutoCell(value: ''),
            'name': PlutoCell(value: ''),
            'qty': PlutoCell(value:1),
            'price': PlutoCell(value: ''),
            'total': PlutoCell(value: 0),
          },)
        ]);
  }

  void EditeAlreadyInvoices(String id) {
    dbInvoices.FindInvioce(id).then((value) {
      dateDate = DateTime.parse(value.date);
      Selectedtime =TimeOfDay.fromDateTime(dateDate);
      AccountingTo_select_id=value.accountingTo_no;
      AccountingTo_select_name=value.accountingTo_name;
      AccountingPerson_select_id= value.account_no;
      AccountingPerson_select_name= value.account_name;
      currencySelect=value.currency;
      rate= double.parse(value.rate);
      amount= double.parse(value.amount) ; //'قيمة الفاتورة'
      disscount=double.parse(value.disscount); //'قيمة الخصم
      amount_all=double.parse(value.amount_all); //'قيمة الفاتورة الكلية'
      payment=double.parse(value.payment); //المدفوع
      payment_pre=payment;
      payment_currency=value.payment_currency;
      remaining=double.parse(value.remaining);//المبلغ المتبقي
      remaining_pre=remaining;
      EditeMode=true;
      saving=true;
      invoicesModelEdite=value;
      Maxjournals= value.jornal;
    });
    rows.clear();
    dbInvoicesDetails.searchInvoicesDetails(id).then((invoicesDetails) {
      for (var invoicesDetail in invoicesDetails) {
        rows.add(
          PlutoRow(
            cells: {
              'id': PlutoCell(value: invoicesDetail.id),
              'id_invoice': PlutoCell(value: invoicesDetail.invoices_id),
              'id_item': PlutoCell(value: invoicesDetail.item_no),
              'name': PlutoCell(value: invoicesDetail.item_name),
              'qty': PlutoCell(value:invoicesDetail.unit_qty),
              'price': PlutoCell(value:invoicesDetail.unit_price),
              'total': PlutoCell(value: invoicesDetail.net_price),
            },
          ),
        );
      }
    });
  }

  void AddNewInvoices() {
    /// add jornals
    /// the record is not  execces you must add new record

    /// add Custmer Journal Details

    if(AccountingPerson_select_name=='o'){

    }else{
      DbInvoices dbInvoices = DbInvoices();
      DbJournalDetails dbJournalDetails = DbJournalDetails();
      DbVouchers dbVouchers = DbVouchers();
      DbJournals dbJournals = DbJournals();
      DbInvoicesDetails dbInvoicesDetails = DbInvoicesDetails();
      InvoicesDetailModel invoicesDetailModel  = InvoicesDetailModel.name();

      ///jounral
      dbJournals.addjournals(
        dateDate.toString(),
        '${Selectedtime.hour}:${Selectedtime.minute}',
        numberFormat.format(amount_all),
        payment_currency,
        numberFormat.format(rate),
        ' فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
      );

      /// add Invioces
      dbInvoices.addInvoices2(
          rate.toString(),
          dateDate.toString(),
          '${Selectedtime.hour}:${Selectedtime.minute}',
          AccountingPerson_select_id,
          AccountingPerson_select_name,
          AccountingTo_select_id,
          AccountingTo_select_name,
          amount.toString(),
          disscount.toString(),
          amount_all.toString(),
          currencySelect,
          payment.toString(),
          payment_currency,
          remaining.toString(),
          Maxjournals,
          "",
          'المشتريات'
      );
      /// add first Journals    المتبقي
      if(remaining>0) {
        dbJournalDetails.addjournalDetails(
            Maxjournals,
            AccountingPerson_select_id,
            AccountingPerson_select_name,
            "0",
            numberFormat.format(remaining),
            ' فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
            currencySelect,
            rate.toString(),
            numberFormat.format(rate * remaining)
        );
      }
      if (remaining>=0){
        dbJournalDetails.addjournalDetails(
            Maxjournals,
            "51",
            "المشتريات",
            numberFormat.format(amount_all),
            "0",
            ' فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
            currencySelect,
            rate.toString(),
            numberFormat.format(amount_all)
        );
      }
      /// add second  Journals    المدفوع
      if(payment>0){
        dbJournalDetails.addjournalDetails(
            Maxjournals,
            AccountingTo_select_id,
            AccountingTo_select_name,
            "0",
            numberFormat.format(payment),
            ' إيصال صرف  $MaxVouchers / $AccountingPerson_select_name',
            currencySelect,
            rate.toString(),
            numberFormat.format(rate*remaining)
        );
        // addVouchers   إضافة ايصال صرف
        dbVouchers.addVouchers(
            AccountingPerson_select_id ,
            dateDate.toString(),
            '${Selectedtime.hour}:${Selectedtime.minute}',
            AccountingPerson_select_name ,
            numberFormat.format(payment),
            payment_currency ,
            Maxjournals ,
            ' إيصال صرف  $MaxVouchers / $AccountingPerson_select_name',
            "صرف"
        );
      }
      ///
      for (var e in stateManager.rows) {
        invoicesDetailModel.invoices_id=e.cells['id_invoice']!.value.toString();
        invoicesDetailModel.item_no=e.cells['id_item']!.value.toString();
        invoicesDetailModel.item_name=e.cells['name']!.value;
        invoicesDetailModel.unit_price=e.cells['price']!.value.toString();
        invoicesDetailModel.unit_qty=e.cells['qty']!.value.toString();
        invoicesDetailModel.net_price=e.cells['total']!.value.toString();

        dbInvoicesDetails.addInvoicesDetails2(
            e.cells['id_invoice']!.value,
            e.cells['id_item']!.value,
            e.cells['name']!.value,
            'وحدة',
            e.cells['qty']!.value.toString(),
            e.cells['price']!.value.toString(),
            e.cells['total']!.value.toString()
        );
      }
    }///enf
  }

  void EditeInvoices(String InvoiceNo) {
    /// Edite jornals
    /// Edite Journal Details
    if(AccountingPerson_select_name=='o'){

    }else{
      DbInvoices dbInvoices = DbInvoices();
      DbInvoicesDetails dbInvoicesDetails = DbInvoicesDetails();
      InvoicesDetailModel invoicesDetailModel  = InvoicesDetailModel.name();
      /// add Invioces
      dbInvoices.updateInvoices(
          InvoiceNo,
          rate.toString(),
          dateDate.toString(),
          '${Selectedtime.hour}:${Selectedtime.minute}',
          AccountingPerson_select_id,
          AccountingPerson_select_name,
          AccountingTo_select_id,
          AccountingTo_select_name,
          amount.toString(),
          disscount.toString(),
          amount_all.toString(),
          currencySelect,
          payment.toString(),
          payment_currency,
          remaining.toString(),
          Maxjournals,
          "",
          'المشتريات'
      );
      ///
      for (var e in stateManager.rows) {
        invoicesDetailModel.id= int.parse(e.cells['id']!.value.toString());
        invoicesDetailModel.invoices_id=e.cells['id_invoice']!.value.toString();
        invoicesDetailModel.item_no=e.cells['id_item']!.value.toString();
        invoicesDetailModel.item_name=e.cells['name']!.value;
        invoicesDetailModel.unit_price=e.cells['price']!.value.toString();
        invoicesDetailModel.unit_qty=e.cells['qty']!.value.toString();
        invoicesDetailModel.net_price=e.cells['total']!.value.toString();
        if (invoicesDetailModel.id>0){
          dbInvoicesDetails.UpdateInvoicesDetails(
              e.cells['id']!.value.toString(),
              e.cells['id_invoice']!.value,
              e.cells['id_item']!.value,
              e.cells['name']!.value,
              'وحدة',
              e.cells['qty']!.value.toString(),
              e.cells['price']!.value.toString(),
              e.cells['total']!.value.toString()
          );
        }else{
          dbInvoicesDetails.addInvoicesDetails2(
              e.cells['id_invoice']!.value,
              e.cells['id_item']!.value,
              e.cells['name']!.value,
              'وحدة',
              e.cells['qty']!.value.toString(),
              e.cells['price']!.value.toString(),
              e.cells['total']!.value.toString()
          );
        }
      }
    }///enf
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
