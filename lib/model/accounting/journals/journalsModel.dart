import 'package:hussam_clinc/model/accounting/journals/JournalsDetailModel.dart';

class JournalsModel {
  int _id = 0;
  String _date = DateTime.now().toString();
  String _time = '';
  String _amount = '0';
  String _currency = 'شيكل';
  String _rate = '1';
  String _discription = '';
  
  List<JournalsDetailModel> details = [];

  JournalsModel.name();

  JournalsModel(dynamic obj) {
    _id = obj["journal_id"] as int;
    _date = obj["journal_date"];
    _time = obj["journal_time"];
    _amount = obj["journal_amount"];
    _currency = obj["journal_currency"];
    _rate = obj["journal_rate"];
    _discription = obj["journal_description"];
  }

  JournalsModel.fromMap(Map<String, dynamic> obj) {
    _id = (obj["journal_id"] as int?) ?? 0;
    _date = obj["journal_date"]?.toString() ?? '';
    _time = obj["journal_time"]?.toString() ?? '';
    _amount = obj["journal_amount"]?.toString() ?? '0';
    _currency = obj["journal_currency"]?.toString() ?? '';
    _rate = obj["journal_rate"]?.toString() ?? '1';
    _discription = obj["journal_description"]?.toString() ?? '';
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      "journal_date": _date,
      "journal_time": _time,
      "journal_amount": _amount,
      "journal_currency": _currency,
      "journal_rate": _rate,
      "journal_description": _discription,
    };
    if (_id != 0) {
      map["journal_id"] = _id;
    }
    return map;
  }

  int get id => _id;
  set id(int value) => _id = value;

  String get date => _date;
  set date(String value) => _date = value;

  String get time => _time;
  set time(String value) => _time = value;

  String get amount => _amount;
  set amount(String value) => _amount = value;

  String get currency => _currency;
  set currency(String value) => _currency = value;

  String get rate => _rate;
  set rate(String value) => _rate = value;

  String get discription => _discription;
  set discription(String value) => _discription = value;
}
