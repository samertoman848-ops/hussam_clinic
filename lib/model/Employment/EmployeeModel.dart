class EmployeeModel {
  int _id = 1;
  String _name = "mo";
  String _mobile = "0599453796";
  String _jop = "دكتور";

  int get id => _id;

  set id(int value) {
    _id = value;
  }
  EmployeeModel(dynamic obj) {
    _id = obj["employee_id"];
    _name = obj["employee_name"];
    _mobile = obj["employee_mobile"];
    _jop = obj["employee_jop"];
  }

  EmployeeModel.full({
    required int id,
    String name = 'mo',
    String mobile = '0599453796',
    String jop = 'دكتور',
  }) {
    _id = id;
    _name = name;
    _mobile = mobile;
    _jop = jop;
  }

  EmployeeModel.fromMap(Map<String, dynamic> data) {
    _id = data["employee_id"] as int;
    _name = data["employee_name"]?? "yy";
    _mobile = data["employee_mobile"] ?? "059";
    _jop = data["employee_jop"] ?? "دكتور";
  }

  Map<String, dynamic> toMap() =>
      {'employee_id': _id, 'employee_name': _name, 'employee_mobile': _mobile, 'employee_jop': _jop};

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get mobile => _mobile;

  set mobile(String value) {
    _mobile = value;
  }

  String get jop => _jop;

  set jop(String value) {
    _jop = value;
  }
}
