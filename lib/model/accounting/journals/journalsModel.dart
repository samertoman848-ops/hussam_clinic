import 'package:timetable/timetable.dart';
import 'package:flutter/material.dart';

class JournalsModel {
  //TODO الإجمالي للفواتير
  int _id = 1;
  String _date = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toString(); // 'التاريخ'
  String _time = TimeOfDay.now().toString(); // 'الوقت'
  String _amount = '1344'; //'قيمة الفاتورة'
  String _currency = 'شيكل'; // 'عملة الفاتورة'
  String _rate = 'شيكل'; // 'عملة الفاتورة'
  String _discription = 'الوصف';

  int get id => _id;

  set id(int value) {
    _id = value;
  } // 'رقم القيد'

  // CREATE TABLE "journals" (
  // "journal_id"	INTEGER NOT NULL UNIQUE,
  // "journal_date"	TEXT DEFAULT 'تاريخ القيد',
  // "journal_time"	TEXT DEFAULT 'وقت القيد',
  // "journal_amount"	TEXT DEFAULT 'مبلغ القيد',
  // "journal_currency"	TEXT DEFAULT 'العملة',
  // "journal_rate"	TEXT DEFAULT 'التحويل',
  // "journal_description"	TEXT DEFAULT 'الوصف',
  // PRIMARY KEY("journal_id" AUTOINCREMENT)
  // );

  JournalsModel(dynamic obj) {
    _id = obj["journal_id"] as int;
    _date = obj["journal_date"]; // 'التاريخ'
    _time = obj["journal_time"]; // 'الوقت'
    _amount = obj["journal_amount"]; //'قيمة الفاتورة'
    _currency = obj["journal_currency"]; // 'عملة الفاتورة'
    _rate = obj["journal_rate"]; // 'عملة الفاتورة'
    _discription = obj["journal_description"]; // 'رقم القيد'
  }

  JournalsModel.fromMap(Map<String, dynamic> obj) {
    _id = obj["journal_id"] as int;
    _date = obj["journal_date"]; // 'التاريخ'
    _time = obj["journal_time"]; // 'الوقت'
    _amount = obj["journal_amount"]; //'قيمة الفاتورة'
    _currency = obj["journal_currency"]; // 'عملة الفاتورة'
    _rate = obj["journal_rate"]; // 'عملة الفاتورة'
    _discription = obj["journal_description"]; // 'رقم القيد'
  }

  Map<String, dynamic> toMap() => {
        "journal_id": _id,
        "journal_date": _date, // 'التاريخ'
        "journal_time": _time, // 'الوقت'
        "journal_amount": _amount, //'قيمة الفاتورة'
        "journal_currency": _currency, // 'عملة الفاتورة'
        "journal_rate": _rate, // 'عملة الفاتورة'
        "journal_description": _discription, // 'رقم القيد'
      };

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get discription => _discription;

  set discription(String value) {
    _discription = value;
  }

  String get rate => _rate;

  set rate(String value) {
    _rate = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
  }

  String get time => _time;

  set time(String value) {
    _time = value;
  }
}
