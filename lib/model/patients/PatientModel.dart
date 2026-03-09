class PatientModel {
  // "patient_id"	INTEGER NOT NULL UNIQUE,
  // "patient_Name"	TEXT,
  // "patient_mobile"	TEXT,
  // "patient_sex"	TEXT,
  // "patient_status"	TEXT,
  // "patient_birthDay"	TEXT,
  // "patient_age"	INTEGER,
  // "patient_fileNo"	INTEGER UNIQUE,
  // "patient_Address"	TEXT,
  // "patient_resone"	TEXT,
  // "patient_worries"	TEXT,
  int _id = 1;
  String _name = "mo";
  String _mobile = "0599453796";
  String _mobile2 = "";
  String _address = "خانيونس";
  String _sex = "M";
  String _age = "34";
  String _fileNo = "12";
  String _resone = "12";
  String _worries = "12";
  String _status = "12";
  String _birthDay = "12";

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  PatientModel(dynamic obj) {
    _id = obj["patient_id"];
    _name = obj["patient_Name"];
    _mobile = obj["patient_mobile"];
    _mobile2 = obj["patient_mobile2"] ?? '';
    _address = obj["patient_Address"];
    _sex = obj["patient_sex"];
    _age = obj["patient_age"].toString();
    _fileNo = obj["patient_fileNo"].toString();
    _resone = obj["patient_resone"].toString();
    _worries = obj["patient_worries"].toString();
    _status = obj["patient_status"].toString();
    _birthDay = obj["patient_birthDay"].toString();
  }

  PatientModel.full({
    required int id,
    required String name,
    required String mobile,
    String mobile2 = "",
    String address = "",
    String sex = "",
    String age = "",
    required String fileNo,
    String resone = "",
    String worries = "",
    String status = "",
    String birthDay = "",
  }) {
    _id = id;
    _name = name;
    _mobile = mobile;
    _mobile2 = mobile2;
    _address = address;
    _sex = sex;
    _age = age;
    _fileNo = fileNo;
    _resone = resone;
    _worries = worries;
    _status = status;
    _birthDay = birthDay;
  }

  PatientModel.fromMap(Map<String, dynamic> data) {
    _id = (data["patient_id"] as int?) ?? 8;
    _name = data["patient_Name"] ?? "yy";
    _mobile = data["patient_mobile"] ?? "059";
    _mobile2 = data["patient_mobile2"] ?? "";
    _address = data["patient_Address"] ?? "خانيونس";
    _sex = data["patient_sex"] ?? "m";
    _age = (data["patient_age"] ?? "").toString();
    _fileNo = (data["patient_fileNo"] ?? "").toString();
    _resone = (data["patient_resone"] ?? "").toString();
    _worries = (data["patient_worries"] ?? "").toString();
    _status = (data["patient_status"] ?? "").toString();
    _birthDay = (data["patient_birthDay"] ?? "").toString();
  }

  Map<String, dynamic> toMap() => {
        'patient_id': _id,
        'patient_Name': _name,
        'patient_mobile': _mobile,
        'patient_mobile2': _mobile2,
        'patient_Address': _address,
        'patient_sex': _sex,
        'patient_age': _age,
        'patient_fileNo': _fileNo,
        "patient_resone": _resone,
        "patient_worries": _worries,
        "patient_status": _status,
        "patient_birthDay": _birthDay
      };

  String get name => _name;

  String get birthDay => _birthDay;

  set birthDay(String value) {
    _birthDay = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get worries => _worries;

  set worries(String value) {
    _worries = value;
  }

  String get resone => _resone;

  set resone(String value) {
    _resone = value;
  }

  String get fileNo => _fileNo;

  set fileNo(String value) {
    _fileNo = value;
  }

  String get age => _age;

  set age(String value) {
    _age = value;
  }

  String get sex => _sex;

  set sex(String value) {
    _sex = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get mobile => _mobile;

  set mobile(String value) {
    _mobile = value;
  }

  String get mobile2 => _mobile2;

  set mobile2(String value) {
    _mobile2 = value;
  }

  set name(String value) {
    _name = value;
  }
}
