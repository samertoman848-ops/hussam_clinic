import 'package:timetable/timetable.dart';
import 'package:flutter/material.dart';

class InvoicesModel {
  //TODO الإجمالي للفواتير
  int _id = 1;
  String _rate = '1'; // 'القيمة '
  String _date = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toString(); // 'التاريخ'
  String _time = TimeOfDay.now().toString(); // 'الوقت'
  String _account_no = '5100'; //'رقم الزبون'
  String _account_name = 'gh'; //'اسم الزبون أو المورد'
  String _accountingTo_no = '5100'; //'رقم الزبون'
  String _accountingTo_name = 'gh'; //'اسم الزبون أو المورد'
  String _amount = '1344'; //'قيمة الفاتورة'
  String _disscount = '12'; //'قيمة الخصم'
  String _amount_all = '5100'; //'قيمة الفاتورة الكلية'
  String _currency = 'شيكل'; // 'عملة الفاتورة'
  String _payment = 'شيكل'; // 'عملة الفاتورة'
  String _payment_currency = 'شيكل'; //'عملة المدفوع'
  String _remaining = '344'; // 'المدفوع'
  String _jornal = 'شيكل'; // 'رقم القيد'
  String _discription = 'الوصف'; // 'رقم القيد'
  String _type = 'مبيعات'; // 'مبيعات_مشتريات'

  InvoicesModel.name();

  // "invoice_id"	INTEGER NOT NULL UNIQUE,
  // "invoice_date"	TEXT DEFAULT 'التاريخ',
  // "invoice_time"	TEXT DEFAULT 'الوقت',
  // "invoice_account_no"	TEXT DEFAULT 'رقم الزبون',
  // "invoice_account_name"	TEXT DEFAULT 'اسم الزبون أو المورد',
  // "invoice_accountingTo_no"	TEXT DEFAULT 'رقم المدين',
  // "invoice_accountingTo_name"	TEXT DEFAULT 'اسم المدين',
  // "invoice_amount"	TEXT DEFAULT 'قيمة الفاتورة',
  // "invoice_disscount"	TEXT DEFAULT 'قيمة الخصم',
  // "invoice_amount_all"	TEXT DEFAULT 'قيمة الفاتورة الكلية',
  // "invoice_currency"	TEXT DEFAULT 'عملة الفاتورة',
  // "invoice_rate"	TEXT DEFAULT 'التحويل',
  // "invoice_payment"	TEXT DEFAULT 'المدفوع',
  // "invoice_payment_currency"	TEXT DEFAULT 'عملة المدفوع',
  // "invoice_remaining"	TEXT DEFAULT 'المبلغ المتبقي',
  // "invoice_jornal"	TEXT DEFAULT 'رقم القيد',
  // "invoice_discription"	TEXT DEFAULT 'الوصف',
  // "invoice_class"	TEXT DEFAULT 'مبيعات_مشتريات',

  InvoicesModel(dynamic obj) {
    _id = obj["invoice_id"] as int;
    _rate = obj["invoice_rate"];
    _date = obj["invoice_date"]; // 'التاريخ'
    _time = obj["invoice_time"]; // 'الوقت'
    _account_no = obj["invoice_account_no"]; //'رقم الزبون'
    _account_name = obj["invoice_account_name"]; //'اسم الزبون أو المورد'
    _accountingTo_no = obj["invoice_accountingTo_no"]; //'رقم الزبون'
    _accountingTo_name =
        obj["invoice_accountingTo_name"]; //'اسم الزبون أو المورد'
    _amount = obj["invoice_amount"]; //'قيمة الفاتورة'
    _disscount = obj["invoice_disscount"]; //'قيمة الخصم'
    _amount_all = obj["invoice_amount_all"]; //'قيمة الفاتورة الكلية'
    _currency = obj["invoice_currency"]; // 'عملة الفاتورة'
    _payment = obj["invoice_payment"]; // 'عملة الفاتورة'
    _payment_currency = obj["invoice_payment_currency"]; //'عملة المدفوع'
    _remaining = obj["invoice_remaining"]; // 'المدفوع'
    _jornal = obj["invoice_jornal"]; // 'رقم القيد'
    _discription = obj["invoice_discription"]; // 'رقم القيد'
    _type = obj["invoice_class"]; // 'مبيعات_مشتريات'
  }

  InvoicesModel.full({
    required int id,
    String rate = '1',
    String? date,
    String? time,
    String accountNo = '',
    String accountName = '',
    String accountingToNo = '',
    String accountingToName = '',
    String amount = '',
    String disscount = '',
    String amountAll = '',
    String currency = '',
    String payment = '',
    String paymentCurrency = '',
    String remaining = '',
    String jornal = '',
    String discription = '',
    String type = '',
  }) {
    _id = id;
    _rate = rate;
    _date = date ?? DateTime.now().toString();
    _time = time ?? TimeOfDay.now().toString();
    _account_no = accountNo;
    _account_name = accountName;
    _accountingTo_no = accountingToNo;
    _accountingTo_name = accountingToName;
    _amount = amount;
    _disscount = disscount;
    _amount_all = amountAll;
    _currency = currency;
    _payment = payment;
    _payment_currency = paymentCurrency;
    _remaining = remaining;
    _jornal = jornal;
    _discription = discription;
    _type = type;
  }

  InvoicesModel.fromMap(Map<String, dynamic> obj) {
    _id = obj["invoice_id"] as int;
    _rate = obj["invoice_rate"]; // 'رقم الفاتورة حسب التصنيف'
    _date = obj["invoice_date"]; // 'التاريخ'
    _time = obj["invoice_time"]; // 'الوقت'
    _account_no = obj["invoice_account_no"]; //'رقم الزبون'
    _account_name = obj["invoice_account_name"]; //'اسم الزبون أو المورد'
    _accountingTo_no = obj["invoice_accountingTo_no"]; //'رقم الزبون'
    _accountingTo_name =
        obj["invoice_accountingTo_name"]; //'اسم الزبون أو المورد'
    _amount = obj["invoice_amount"]; //'قيمة الفاتورة'
    _disscount = obj["invoice_disscount"]; //'قيمة الخصم'
    _amount_all = obj["invoice_amount_all"]; //'قيمة الفاتورة الكلية'
    _currency = obj["invoice_currency"]; // 'عملة الفاتورة'
    _payment = obj["invoice_payment"]; // 'عملة الفاتورة'
    _payment_currency = obj["invoice_payment_currency"]; //'عملة المدفوع'
    _remaining = obj["invoice_remaining"]; // 'المدفوع'
    _jornal = obj["invoice_jornal"]; // 'رقم القيد'
    _discription = obj["invoice_discription"].toString(); // 'رقم القيد'
    _type = obj["invoice_class"]; // 'مبيعات_مشتريات'
  }

  Map<String, dynamic> toMap() => {
        "invoice_id": _id,
        "invoice_rate": _rate, // 'رقم الفاتورة حسب التصنيف'
        "invoice_date": _date, // 'التاريخ'
        "invoice_time": _time, // 'الوقت'
        "invoice_account_no": _account_no, //'رقم الزبون'
        "invoice_account_name": _account_name, //'اسم الزبون أو المورد'
        "invoice_accountingTo_no": _accountingTo_no, //'رقم الزبون'
        "invoice_accountingTo_name":
            _accountingTo_name, //'اسم الزبون أو المورد'
        "invoice_amount": _amount, //'قيمة الفاتورة'
        "invoice_disscount": _disscount, //'قيمة الخصم'
        "invoice_amount_all": _amount_all, //'قيمة الفاتورة الكلية'
        "invoice_currency": _currency, // 'عملة الفاتورة'
        "invoice_payment": _payment, // 'عملة الفاتورة'
        "invoice_payment_currency": _payment_currency, //'عملة المدفوع'
        "invoice_remaining": _remaining, // 'المدفوع'
        "invoice_jornal": _jornal, // 'رقم القيد'
        "invoice_discription": _discription, // 'رقم القيد'
        "invoice_class": _type, // 'مبيعات_مشتريات'
      };

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get discription => _discription;

  set discription(String value) {
    _discription = value;
  }

  String get jornal => _jornal;

  set jornal(String value) {
    _jornal = value;
  }

  String get remaining => _remaining;

  set remaining(String value) {
    _remaining = value;
  }

  String get accountingTo_no => _accountingTo_no;

  set accountingTo_no(String value) {
    _accountingTo_no = value;
  }

  String get payment_currency => _payment_currency;

  set payment_currency(String value) {
    _payment_currency = value;
  }

  String get payment => _payment;

  set payment(String value) {
    _payment = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get amount_all => _amount_all;

  set amount_all(String value) {
    _amount_all = value;
  }

  String get disscount => _disscount;

  set disscount(String value) {
    _disscount = value;
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
  }

  String get account_name => _account_name;

  set account_name(String value) {
    _account_name = value;
  }

  String get account_no => _account_no;

  set account_no(String value) {
    _account_no = value;
  }

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get rate => _rate;

  set rate(String value) {
    _rate = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get accountingTo_name => _accountingTo_name;

  set accountingTo_name(String value) {
    _accountingTo_name = value;
  }
}
