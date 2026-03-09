import 'package:timetable/timetable.dart';
import 'package:flutter/material.dart';

/// this is سندات الصرف والقبض
class VoucherModel {
  int _id = 1;
  String _date = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toString(); // 'التاريخ'
  String _time = TimeOfDay.now().toString(); // 'الوقت'
  String _account = '5100'; //'الحساب/رقم الشخص'
  String _dealer = 'gh'; //'اسم الشخص'
  String _payment = '1344'; // 'المبلغ المدفوع'
  String _currency = 'شيكل'; // 'العملة'
  String _jornal = 'شيكل'; // 'رقم القيد'
  String _discription = 'الوصف'; // 'رقم القيد'
  String _class = 'مبيعات'; // 'صرف_قبض'

  /*  "voucher_id"	INTEGER NOT NULL UNIQUE,
  "voucher_no"	INTEGER,
  "voucher_date"	TEXT DEFAULT 'التاريخ',
  "voucher_time"	TEXT DEFAULT 'الساعة',
  "voucher_account"	TEXT DEFAULT 'الحساب/رقم الشخص',
  "voucher_dealer"	TEXT DEFAULT 'اسم الشخص',
  "voucher_payment"	TEXT DEFAULT 'المبلغ المدفوع',
  "voucher_currency"	TEXT DEFAULT 'العملة',
  "voucher_journal"	TEXT DEFAULT 'رقم القيد',
  "voucher_discription"	TEXT DEFAULT 'الوصف',
  "voucher_class"	TEXT DEFAULT 'صرف_قبض',
  PRIMARY KEY("voucher_id" AUTOINCREMENT)*/

  VoucherModel(dynamic obj) {
    _id = obj["voucher_id"] as int;
    _date = obj["voucher_date"];
    _time = obj["voucher_time"];
    _account = obj["voucher_account"];
    _dealer = obj["voucher_dealer"];
    _payment = obj["invoice_payment"];
    _currency = obj["invoice_currency"];
    _jornal = obj["voucher_jornal"];
    _discription = obj["voucher_discription"];
    _class = obj["voucher_class"];
  }

  VoucherModel.fromMap(Map<String, dynamic> obj) {
    _id = obj["voucher_id"] as int;
    _date = obj["voucher_date"];
    _time = obj["voucher_time"];
    _account = obj["voucher_account"];
    _dealer = obj["voucher_dealer"];
    _payment = obj["invoice_payment"];
    _currency = obj["invoice_currency"];
    _jornal = obj["voucher_jornal"];
    _discription = obj["voucher_discription"];
    _class = obj["voucher_class"];
  }

  Map<String, dynamic> toMap() => {
        "voucher_id": _id,
        "voucher_date": _date, // 'التاريخ'
        "voucher_time": _time, // 'الوقت'
        "voucher_account": _account,
        "voucher_dealer": _dealer,
        "invoice_payment": _payment,
        "invoice_currency": _currency,
        "voucher_jornal": _jornal,
        "voucher_discription": _discription,
        "voucher_class": _class,
      };

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get discription => _discription;

  set discription(String value) {
    _discription = value;
  }

  String get jornal => _jornal;

  set jornal(String value) {
    _jornal = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get payment => _payment;

  set payment(String value) {
    _payment = value;
  }

  String get className => _class;

  String get dealer => _dealer;

  set dealer(String value) {
    _dealer = value;
  }

  String get account => _account;

  set account(String value) {
    _account = value;
  }

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }
}
