import 'package:timetable/timetable.dart';

class DateModel {
  int _id = 1;
  String _kind = 'مواعيد المرضى'; //  'مواعيد المرضى' 'مواعيد الدكتور'
  String _place = "غرفة 1"; // ['غرفة 1', 'غرفة 2', 'غرفة 3']
  String _dateStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toString();
  String _dateEnd = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).toString();
  String _note = "d";
  String _doctorId = "mo";
  String _doctorName = "mo";
  String _costumerId = "mo";
  String _costumerName = "mo";

  int get id => _id;

  set id(int value) {
    _id = value;
  } // CREATE TABLE "dates" (
  // "date_id"	INTEGER NOT NULL UNIQUE,
  // "date_kind"	TEXT,
  // "date_place"	TEXT,
  // "date_dateStart"	TEXT,
  // "date_dateEnd"	TEXT,
  // "date_note"	TEXT,
  // "date_doctorId"	TEXT,
  // "date_doctorName"	TEXT,
  // "date_costumerId"	TEXT,
  // "date_costumerName"	TEXT,

  DateModel(dynamic obj) {
    _id = obj["date_id"] as int;
    _kind = obj["date_kind"];
    _place = obj["date_place"];
    _dateStart = obj["date_dateStart"];
    _dateEnd = obj["date_dateEnd"];
    _note = obj["date_note"];
    _doctorId = obj["date_doctorId"];
    _doctorName = obj["date_doctorName"];
    _costumerId = obj["date_costumerId"];
    _costumerName = obj["date_costumerName"];
  }

  DateModel.full({
    required int id,
    String kind = 'مواعيد المرضى',
    String place = 'غرفة 1',
    String? dateStart,
    String? dateEnd,
    String note = '',
    String doctorId = '',
    String doctorName = '',
    String costumerId = '',
    String costumerName = '',
  }) {
    _id = id;
    _kind = kind;
    _place = place;
    _dateStart = dateStart ?? DateTime.now().toString();
    _dateEnd = dateEnd ?? DateTime.now().toString();
    _note = note;
    _doctorId = doctorId;
    _doctorName = doctorName;
    _costumerId = costumerId;
    _costumerName = costumerName;
  }

  DateModel.fromMap(Map<String, dynamic> data) {
    _id = data["date_id"] as int;
    _kind = data["date_kind"];
    _place = data["date_place"];
    _dateStart = data["date_dateStart"];
    _dateEnd = data["date_dateEnd"];
    _note = data["date_note"];
    _doctorId = data["date_doctorId"];
    _doctorName = data["date_doctorName"];
    _costumerId = data["date_costumerId"];
    _costumerName = data["date_costumerName"];
  }
  Map<String, dynamic> toMap() => {
    "date_id": _id,
    "date_kind": _kind,
    "date_place": _place,
    "date_dateStart": _dateStart,
    "date_dateEnd": _dateEnd,
    "date_note": _note,
    "date_doctorId": _doctorId,
    "date_doctorName": _doctorName,
    "date_costumerId": _costumerId,
    "date_costumerName": _costumerName,
  };

  String get kind => _kind;

  set kind(String value) {
    _kind = value;
  }

  String get place => _place;

  set place(String value) {
    _place = value;
  }

  String get dateStart => _dateStart;

  set dateStart(String value) {
    _dateStart = value;
  }

  String get dateEnd => _dateEnd;

  set dateEnd(String value) {
    _dateEnd = value;
  }

  String get note => _note;

  set note(String value) {
    _note = value;
  }

  String get doctorId => _doctorId;

  set doctorId(String value) {
    _doctorId = value;
  }

  String get doctorName => _doctorName;

  set doctorName(String value) {
    _doctorName = value;
  }

  String get costumerId => _costumerId;

  set costumerId(String value) {
    _costumerId = value;
  }

  String get costumerName => _costumerName;

  set costumerName(String value) {
    _costumerName = value;
  }
}
