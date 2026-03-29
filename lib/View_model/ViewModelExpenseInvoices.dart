import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:intl/intl.dart' as tt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/db/accounting/invoices/dbinvoicedetails.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournals.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesDetailModel.dart';
import 'package:hussam_clinc/db/accounting/invoices/dbinvoices.dart';
import 'package:hussam_clinc/db/accounting/vouchers/dbvouchers.dart';
import 'package:hussam_clinc/model/accounting/journals/journalsModel.dart';
import 'package:hussam_clinc/model/accounting/journals/JournalsDetailModel.dart';
import '../main.dart';
import '../model/accounting/invoices/InvoicesModel.dart';

class ViewModelExpenseInvoices {
  ViewModelExpenseInvoices.impty() {
    AccountingTo_select_name = 'f';
    dateDate = DateTime.now();
    Selectedtime = TimeOfDay.now();
    AccountingGroups_select = 'المرضي';
    AccountingPerson_select_name = 'o';
    AccountingPerson_select_id = 'o';
    AccountingTo_select_id = '120101';
    AccountingTo_select_name = 'صندوق العيادة';
    currencySelect = "شيكل";
    rate = 1;
    amount = 0; //'قيمة الفاتورة'
    disscount = 0; //'قيمة الخصم
    amount_all = 0; //'قيمة الفاتورة الكلية'
    payment = 0; //المدفوع كاش
    payment_app = 0; // المدفوع تطبيق
    payment_currency = "شيكل";
    remaining = 0; //المبلغ المتبقي
    saving = false;
    EditeMode = false;
    rows.clear();
    Maxjournals = VMGlobal.Maxjournals;
    MaxInvoices = VMGlobal.MaxInvoices;
    MaxVouchers = VMGlobal.MaxVouchers;
  }

  /// Styles and Color
  Color primaryColor = const Color(0xffd0d4d7); //corner
  Color accentColor = const Color(0xff3f86bd); //background
  TextStyle textStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.green,
    fontSize: 18,
  );
  TextStyle textStyleLabel = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontSize: 18,
  );

  ///
  /// Styles and Color

  DateTime dateDate = DateTime.now();
  TimeOfDay Selectedtime = TimeOfDay.now();

  String AccountingGroups_select = 'المورديين';
  String AccountingPerson_select_name = 'o';
  String AccountingPerson_select_id = 'o';

  String AccountingTo_select_id = '120101';
  String AccountingTo_select_name = 'صندوق العيادة';

  final currnceyList = ['شيكل', 'دولار', 'دينار'];
  late String currencySelect = "شيكل";
  double rate = 1;
  double amount = 0; //'قيمة الفاتورة'
  double disscount = 0; //'قيمة الخصم
  double amount_all = 0; //'قيمة الفاتورة الكلية'
  double payment = 0; //المدفوع كاش
  double payment_app = 0; // المدفوع تطبيق
  String payment_currency = "شيكل";
  double remaining = 0; //المبلغ المتبقي
  double remaining_pre = 0; // القديم المبلغ المتبقي
  double payment_pre = 0; // القديم المبلغ المتبقي
  var numberFormat = tt.NumberFormat("###.0#", "en_US");
  late bool saving = false;
  bool EditeMode = false;

  DbInvoices dbInvoices = DbInvoices();
  DbInvoicesDetails dbInvoicesDetails = DbInvoicesDetails();
  InvoicesModel invoicesModelEdite = InvoicesModel.name();
  String Maxjournals = '1';
  String MaxInvoices = '1';
  String MaxVouchers = '1';

  late final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'الرقم',
      field: 'id',
      width: 60,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
      hide: true,
    ),
    PlutoColumn(
      title: 'رقم الفاتورة',
      field: 'id_invoice',
      width: 60,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
      hide: true,
    ),
    PlutoColumn(
      title: 'رقم الصنف',
      field: 'id_item',
      width: 130,
      type: PlutoColumnType.text(),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'اسم الصنف',
      field: 'name',
      width: 380,
      type: PlutoColumnType.select(allAccountingIndex_s,
          enableColumnFilter: true),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'الكمية',
      width: 120,
      field: 'qty',
      type: PlutoColumnType.number(negative: false),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'السعر',
      width: 120,
      field: 'price',
      type: PlutoColumnType.number(format: '#.##', negative: false),
      enableAutoEditing: true,
      enableEditingMode: true,
      textAlign: PlutoColumnTextAlign.center,
      titleTextAlign: PlutoColumnTextAlign.center,
    ),
    PlutoColumn(
      title: 'الاجمالي',
      field: 'total',
      width: 120,
      readOnly: false,
      type: PlutoColumnType.currency(
        locale: "ar",
        allowFirstDot: true,
        format: '#,###.##',
      ),
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
              TextSpan(
                text: text,
                style: const TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: currencySelect,
                style: const TextStyle(color: Colors.red),
              ),
            ];
          },
        );
      },
    ),
  ];

  late final List<PlutoRow> rows = [];

  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late PlutoGridStateManager stateManager;
  List<String> persons = [];

  void calculateTotals() {
    amount = 0;
    // Check if stateManager is initialized is not directly possible for late fields without catch
    // but we can skip if it throws
    try {
      if (stateManager.rows.isEmpty) return;
    } catch (e) {
      return;
    }

    for (var e in stateManager.rows) {
      final val = e.cells['total']?.value;
      if (val is num) {
        amount += val.toDouble();
      } else if (val is String) {
        amount += double.tryParse(val) ?? 0.0;
      }
    }

    amount_all = amount - disscount;
    remaining = amount_all - (payment + payment_app);
  }

  void selecedId(String value) {
    if (AccountingGroups_select == 'المرضي') {
      for (var e in allAccountingCoustmers) {
        if (e.name == value) {
          AccountingPerson_select_id = e.branch_no.toString();
        }
      }
    } else if (AccountingGroups_select == 'المورديين') {
      for (var e in allAccountingSuppliers) {
        if (e.name == value) {
          AccountingPerson_select_id = e.branch_no.toString();
        }
      }
    } else if (AccountingGroups_select == 'الموظفين') {
      for (var e in allAccountingEmployees) {
        if (e.name == value) {
          AccountingPerson_select_id = e.branch_no.toString();
        }
      }
    }
  }

  void selecedIndexId(String value) {
    for (var e in allAccountingIndex) {
      if (e.name == value) {
        AccountingIndexModel = e;
        AccountingIndx_select_id = e.no.toString();
      }
    }
  }

  void checkValues2() {
    persons.clear();
    if (AccountingGroups_select == 'المرضي') {
      persons.addAll(allAccountingCoustmers_s);
    } else if (AccountingGroups_select == 'المورديين') {
      persons.addAll(allAccountingSuppliers_s);
    } else if (AccountingGroups_select == 'الموظفين') {
      persons.addAll(allAccountingEmployees_s);
    }
  }

  ///TODO Functions
  ///
  void checkValues() {
    AccountingGroups_select = 'المرضي';
    allAccountingContens.clear();
    if (allAccountingCoustmers_s.isNotEmpty) {
      allAccountingContens.add('المرضي');
    }
    if (allAccountingSuppliers_s.isNotEmpty) {
      allAccountingContens.add('المورديين');
    }
    if (allAccountingEmployees_s.isNotEmpty) {
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
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  void AddNewRecord() {
    final int lastIndex = stateManager.refRows.originalList.length;
    stateManager.insertRows(lastIndex, [
      PlutoRow(
        cells: {
          'id': PlutoCell(value: '0'),
          'id_invoice': PlutoCell(value: MaxInvoices),
          'id_item': PlutoCell(value: ''),
          'name': PlutoCell(value: ''),
          'qty': PlutoCell(value: 1),
          'price': PlutoCell(value: ''),
          'total': PlutoCell(value: 0),
        },
      )
    ]);
  }

  Future<void> EditeAlreadyInvoices(String id) async {
    try {
      final value = await dbInvoices.FindInvioce(id);
      dateDate = DateTime.parse(value.date);
      Selectedtime = TimeOfDay.fromDateTime(dateDate);
      AccountingTo_select_id = value.accountingTo_no;
      AccountingTo_select_name = value.accountingTo_name;
      AccountingPerson_select_id = value.account_no;
      AccountingPerson_select_name = value.account_name;
      currencySelect = value.currency;
      rate = double.parse(value.rate);
      amount = double.parse(value.amount); //'قيمة الفاتورة'
      disscount = double.parse(value.disscount); //'قيمة الخصم'
      amount_all = double.parse(value.amount_all); //'قيمة الفاتورة الكلية'
      payment = double.parse(value.payment); //المدفوع
      payment_pre = payment;
      payment_currency = value.payment_currency;
      remaining = double.parse(value.remaining); //المبلغ المتبقي
      remaining_pre = remaining;
      EditeMode = true;
      saving = true;
      invoicesModelEdite = value;
      MaxInvoices = value.id.toString();
      Maxjournals = value.jornal;

      rows.clear();
      final invoicesDetails = await dbInvoicesDetails.searchInvoicesDetails(id);
      for (var invoicesDetail in invoicesDetails) {
        rows.add(
          PlutoRow(
            cells: {
              'id': PlutoCell(value: invoicesDetail.id),
              'id_invoice': PlutoCell(value: invoicesDetail.invoices_id),
              'id_item': PlutoCell(value: invoicesDetail.item_no),
              'name': PlutoCell(value: invoicesDetail.item_name),
              'qty': PlutoCell(value: num.tryParse(invoicesDetail.unit_qty) ?? 1),
              'price': PlutoCell(value: num.tryParse(invoicesDetail.unit_price) ?? 0),
              'total': PlutoCell(value: num.tryParse(invoicesDetail.net_price) ?? 0),
            },
          ),
        );
      }
      print('تم تحميل ${rows.length} صنف');
    } catch (e) {
      print('خطأ في تحميل الفاتورة: $e');
    }
  }

  Future<void> AddNewInvoices() async {
    if (AccountingPerson_select_name == 'o') return;

    DbInvoices dbInvoices = DbInvoices();
    DbVouchers dbVouchers = DbVouchers();
    DbJournals dbJournals = DbJournals();

    try {
      saving = true;

      // 1. Create main Journal entry
      final journalMaster = JournalsModel.fromMap({
        'journal_id': int.tryParse(Maxjournals) ?? 0,
        'journal_date': dateDate.toString(),
        'journal_time': '${Selectedtime.hour}:${Selectedtime.minute}',
        'journal_amount': numberFormat.format(amount_all),
        'journal_currency': payment_currency,
        'journal_rate': numberFormat.format(rate),
        'journal_description': ' فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
      });

      // 2. Prepare Journal Details
      if (remaining > 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': AccountingPerson_select_id,
          'JD_account_name': AccountingPerson_select_name,
          'JD_debit': "0",
          'JD_credit': numberFormat.format(remaining),
          'JD_description': ' فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(rate * remaining),
        }));
      }

      if (amount_all >= 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': "51",
          'JD_account_name': "المشتريات",
          'JD_debit': numberFormat.format(amount_all),
          'JD_credit': "0",
          'JD_description': ' فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(amount_all),
        }));
      }

      if (payment > 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': AccountingTo_select_id,
          'JD_account_name': AccountingTo_select_name,
          'JD_debit': "0",
          'JD_credit': numberFormat.format(payment),
          'JD_description': ' إيصال صرف (كاش) $MaxVouchers / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(rate * payment),
        }));

        await dbVouchers.addVouchers(
            AccountingPerson_select_id,
            dateDate.toString(),
            '${Selectedtime.hour}:${Selectedtime.minute}',
            AccountingPerson_select_name,
            numberFormat.format(payment),
            payment_currency,
            Maxjournals,
            ' إيصال صرف (كاش) $MaxVouchers / $AccountingPerson_select_name',
            "صرف");
      }

      if (payment_app > 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': AccountingTo_select_id,
          'JD_account_name': AccountingTo_select_name,
          'JD_debit': "0",
          'JD_credit': numberFormat.format(payment_app),
          'JD_description': ' إيصال صرف (تطبيق) $MaxVouchers / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(rate * payment_app),
        }));

        await dbVouchers.addVouchers(
            AccountingPerson_select_id,
            dateDate.toString(),
            '${Selectedtime.hour}:${Selectedtime.minute}',
            AccountingPerson_select_name,
            numberFormat.format(payment_app),
            payment_currency,
            Maxjournals,
            ' إيصال صرف (تطبيق) $MaxVouchers / $AccountingPerson_select_name',
            "صرف");
      }

      // 3. Save Journal with Details
      await dbJournals.addJournalWithDetails(journalMaster);

      // 4. Prepare Invoice
      double totalPayment = payment + payment_app;
      final invoiceMaster = InvoicesModel.full(
        id: int.tryParse(MaxInvoices) ?? DateTime.now().millisecondsSinceEpoch,
        rate: rate.toString(),
        date: dateDate.toString(),
        time: '${Selectedtime.hour}:${Selectedtime.minute}',
        accountNo: AccountingPerson_select_id,
        accountName: AccountingPerson_select_name,
        accountingToNo: AccountingTo_select_id,
        accountingToName: AccountingTo_select_name,
        amount: amount.toString(),
        disscount: disscount.toString(),
        amountAll: amount_all.toString(),
        currency: currencySelect,
        payment: totalPayment.toString(),
        paymentCurrency: payment_currency,
        remaining: remaining.toString(),
        jornal: Maxjournals,
        discription: "",
        type: 'المشتريات',
      );

      // 5. Populate Invoice Items
      for (var e in stateManager.rows) {
        invoiceMaster.details.add(InvoicesDetailModel.full(
          id: 0,
          invoicesId: MaxInvoices,
          itemNo: e.cells['id_item']!.value.toString(),
          itemName: e.cells['name']!.value.toString(),
          unitName: 'وحدة',
          unitQty: e.cells['qty']!.value.toString(),
          unitPrice: e.cells['price']!.value.toString(),
          netPrice: e.cells['total']!.value.toString(),
        ));
      }

      // 6. Save Invoice with Details
      await dbInvoices.addInvoicesWithDetails(invoiceMaster);

      print('✅ تم إضافة فاتورة المشتريات والقيود بنجاح');
    } catch (e) {
      print('❌ خطأ في إضافة الفاتورة: $e');
    } finally {
      saving = false;
    }
  }

  Future<void> EditeInvoices(String InvoiceNo) async {
    if (AccountingPerson_select_name == 'o') return;

    DbInvoices dbInvoices = DbInvoices();
    DbVouchers dbVouchers = DbVouchers();
    DbJournals dbJournals = DbJournals();

    try {
      saving = true;

      // 1. Prepare Journal
      final journalMaster = JournalsModel.fromMap({
        'journal_id': int.tryParse(Maxjournals) ?? 0,
        'journal_date': dateDate.toString(),
        'journal_time': '${Selectedtime.hour}:${Selectedtime.minute}',
        'journal_amount': numberFormat.format(amount_all),
        'journal_currency': payment_currency,
        'journal_rate': numberFormat.format(rate),
        'journal_description': 'فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
      });

      // 2. Prepare Journal Details
      if (remaining > 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': AccountingPerson_select_id,
          'JD_account_name': AccountingPerson_select_name,
          'JD_debit': "0",
          'JD_credit': numberFormat.format(remaining),
          'JD_description': 'فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(rate * remaining),
        }));
      }

      if (amount_all >= 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': "51",
          'JD_account_name': "المشتريات",
          'JD_debit': numberFormat.format(amount_all),
          'JD_credit': "0",
          'JD_description': 'فاتورة شراء رقم $MaxInvoices / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(amount_all),
        }));
      }

      // Handling Cash Payment
      if (payment > 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': AccountingTo_select_id,
          'JD_account_name': AccountingTo_select_name,
          'JD_debit': "0",
          'JD_credit': numberFormat.format(payment),
          'JD_description': 'إيصال صرف (كاش) $MaxVouchers / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(rate * payment),
        }));

        await dbVouchers.upsertVoucherByJournal(Maxjournals, "(كاش)", {
          'voucher_date': dateDate.toString(),
          'voucher_time': '${Selectedtime.hour}:${Selectedtime.minute}',
          'voucher_account': AccountingPerson_select_id,
          'voucher_dealer': AccountingPerson_select_name,
          'voucher_payment': numberFormat.format(payment),
          'voucher_currency': payment_currency,
          'voucher_journal': Maxjournals,
          'voucher_discription': 'إيصال صرف (كاش) $MaxVouchers / $AccountingPerson_select_name',
          'voucher_class': "صرف",
        });
      } else {
        await dbVouchers.deleteVoucherByJournalAndDescription(Maxjournals, "(كاش)");
      }

      // Handling App Payment
      if (payment_app > 0) {
        journalMaster.details.add(JournalsDetailModel.fromMap({
          'JD_id': 0,
          'JD_journal_id': Maxjournals,
          'JD_account_id': AccountingTo_select_id,
          'JD_account_name': AccountingTo_select_name,
          'JD_debit': "0",
          'JD_credit': numberFormat.format(payment_app),
          'JD_description': 'إيصال صرف (تطبيق) $MaxVouchers / $AccountingPerson_select_name',
          'JD_currency': currencySelect,
          'JD_rate': rate.toString(),
          'JD_acc_amount': numberFormat.format(rate * payment_app),
        }));

        await dbVouchers.upsertVoucherByJournal(Maxjournals, "(تطبيق)", {
          'voucher_date': dateDate.toString(),
          'voucher_time': '${Selectedtime.hour}:${Selectedtime.minute}',
          'voucher_account': AccountingPerson_select_id,
          'voucher_dealer': AccountingPerson_select_name,
          'voucher_payment': numberFormat.format(payment_app),
          'voucher_currency': payment_currency,
          'voucher_journal': Maxjournals,
          'voucher_discription': 'إيصال صرف (تطبيق) $MaxVouchers / $AccountingPerson_select_name',
          'voucher_class': "صرف",
        });
      } else {
        await dbVouchers.deleteVoucherByJournalAndDescription(Maxjournals, "(تطبيق)");
      }

      // 3. Update Journal with Details
      await dbJournals.updateJournalWithDetails(journalMaster);

      // 4. Prepare Invoice
      double totalPayment = payment + payment_app;
      final invoiceMaster = InvoicesModel.full(
        id: int.tryParse(InvoiceNo) ?? 0,
        rate: rate.toString(),
        date: dateDate.toString(),
        time: '${Selectedtime.hour}:${Selectedtime.minute}',
        accountNo: AccountingPerson_select_id,
        accountName: AccountingPerson_select_name,
        accountingToNo: AccountingTo_select_id,
        accountingToName: AccountingTo_select_name,
        amount: amount.toString(),
        disscount: disscount.toString(),
        amountAll: amount_all.toString(),
        currency: currencySelect,
        payment: totalPayment.toString(),
        paymentCurrency: payment_currency,
        remaining: remaining.toString(),
        jornal: Maxjournals,
        discription: "",
        type: 'المشتريات',
      );

      // 5. Populate Invoice Items
      for (var e in stateManager.rows) {
        invoiceMaster.details.add(InvoicesDetailModel.full(
          id: int.tryParse(e.cells['id']!.value.toString()) ?? 0,
          invoicesId: InvoiceNo,
          itemNo: e.cells['id_item']!.value.toString(),
          itemName: e.cells['name']!.value.toString(),
          unitName: 'وحدة',
          unitQty: e.cells['qty']!.value.toString(),
          unitPrice: e.cells['price']!.value.toString(),
          netPrice: e.cells['total']!.value.toString(),
        ));
      }

      // 6. Save Invoice with Details
      await dbInvoices.updateInvoicesWithDetails(invoiceMaster);

      print('✅ تم تحديث فاتورة المشتريات رقم $InvoiceNo وتفاصيلها بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث الفاتورة: $e');
    } finally {
      saving = false;
    }
  }

  InputDecoration inputDecorationNoIcon(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      errorStyle: const TextStyle(
          color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.grey),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Color(0xffF02E65)),
      ),
      border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
    );
  }

  InputDecoration inputDecoration(IconData icon, String hintText) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 35),
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(fontSize: 20),
      errorStyle: const TextStyle(
          color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 3, color: Colors.white),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 4, color: Color(0xffF02E65)),
      ),
      border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
    );
  }
}
