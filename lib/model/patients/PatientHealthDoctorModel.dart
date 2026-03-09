class PatienHealthtDoctorModel {
  int _id = 1;
  String _patientId = "2333";
  String _doctorId = "1";
  String _doctorName = "حسام العايدي";
  String _date = "27/05/2023";
  String _treatment = "العلاج";
  String _diagnosis= "التشخيص";

  int get id => _id;

  set id(int value) {
    _id = value;
  } // CREATE TABLE "patient_health_doctor" (
  // "PHD_id"	INTEGER NOT NULL UNIQUE,
  // "PHD_patientId"	INTEGER,
  // "PHD_doctorId"	INTEGER,
  // "PHD_doctorName"	TEXT,
  // "PHD_date"	TEXT,
  // "PHD_treatment"	TEXT,
  // "PHD_diagnosis"	TEXT,
  PatienHealthtDoctorModel.name();
  PatienHealthtDoctorModel(dynamic obj) {
    id = obj["PHD_id"];
    patientId =  obj["PHD_patientId"].toString();
    doctorId= obj["PHD_doctorId"].toString();
    doctorName = obj["PHD_doctorName"];
    date =  obj["PHD_date"];
    treatment = obj["PHD_treatment"];
    diagnosis =  obj["PHD_diagnosis"];
  }

  PatienHealthtDoctorModel.fromMap(Map<String, dynamic> obj) {
    id = obj["PHD_id"];
    patientId =  obj["PHD_patientId"].toString();
    doctorId= obj["PHD_doctorId"].toString();
    doctorName = obj["PHD_doctorName"];
    date =  obj["PHD_date"];
    treatment = obj["PHD_treatment"];
    diagnosis =  obj["PHD_diagnosis"];
  }

  Map<String, dynamic> toMap() =>
      {
        'PHD_id':id,
        "PHD_patientId":patientId,
        "PHD_doctorId":doctorId,
        "PHD_doctorName":doctorName,
        "PHD_date": date,
        "PHD_treatment":  treatment,
        "PHD_diagnosis":diagnosis,
      };

  String get patientId => _patientId;

  set patientId(String value) {
    _patientId = value;
  }

  String get doctorId => _doctorId;

  set doctorId(String value) {
    _doctorId = value;
  }

  String get doctorName => _doctorName;

  set doctorName(String value) {
    _doctorName = value;
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get treatment => _treatment;

  set treatment(String value) {
    _treatment = value;
  }

  String get diagnosis => _diagnosis;

  set diagnosis(String value) {
    _diagnosis = value;
  }
}
