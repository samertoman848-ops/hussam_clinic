class PatienHealthtModel {
  // "PH_id"	INTEGER NOT NULL UNIQUE,
  // "PH_patientId"	INTEGER,
  // "PH"	TEXT,
  // "PH_sensitive"	TEXT,
  // "PH_sensitive_Ex"	TEXT,
  // "PH_surgical"	TEXT,
  // "PH_surgical_Ex"	TEXT,
  // "PH_haemophilia"	TEXT,
  // "PH_haemophilia_Ex"	TEXT,
  // "PH_drugs"	TEXT,
  // "PH_drugs_Ex"	TEXT,
  // "PH_oralDiseases"	TEXT,
  // "PH_smoking"	TEXT,
  // "PH_pregnant"	TEXT,
  // "PH_pregnant_Ex"	INTEGER,
  // "PH_lactating"	TEXT,
  // "PH_lactating_EX"	INTEGER,
  // "PH_contraception"	TEXT,
  // "PH_contraception_Ex"	TEXT,
  int _id = 1;
  String _patientId = "mo";
  String _health = "0599453796";
  String _sensitive = "خانيونس";
  String _sensitive_Ex = "M";
  String _surgical = "خانيونس";
  String _surgical_Ex = "M";
  String _haemophilia = "خانيونس";
  String _haemophilia_Ex = "M";
  String _drugs = "خانيونس";
  String _drugs_Ex = "M";
  String _oralDiseases = "M";
  String _smoking = "M";
  String _pregnant = "خانيونس";
  String _pregnant_Ex = "M";
  String _lactating = "خانيونس";
  String _lactating_Ex = "M";
  String _contraception = "خانيونس";
  String _contraception_Ex = "M";

  int get id => _id;

  set id(int? value) {
    _id = value!;
  }

  PatienHealthtModel(dynamic obj) {
    _id = obj["PH_id"];
    _patientId = obj["PH_patientId"].toString();
    _health = obj["PH"];
    _sensitive = obj["PH_sensitive"];
    _sensitive_Ex = obj["PH_sensitive_Ex"];
    _surgical = obj["PH_surgical"];
    _surgical_Ex = obj["PH_surgical_Ex"];
    _haemophilia = obj["PH_haemophilia"];
    _haemophilia_Ex = obj["PH_haemophilia_Ex"];
    _drugs = obj["PH_drugs"];
    _drugs_Ex = obj["PH_drugs_Ex"];
    _oralDiseases = obj["PH_oralDiseases"];
    _smoking = obj["PH_smoking"];
    _pregnant = obj["PH_pregnant"];
    _pregnant_Ex = obj["PH_pregnant_Ex"];
    _lactating = obj["PH_lactating"];
    _lactating_Ex = obj["PH_lactating_Ex"];
    _contraception = obj["PH_contraception"];
    _contraception_Ex = obj["PH_contraception_Ex"];
  }

  PatienHealthtModel.full({
    required int id,
    required String patientId,
    String health = "",
    String sensitive = "",
    String sensitiveEx = "",
    String surgical = "",
    String surgicalEx = "",
    String haemophilia = "",
    String haemophiliaEx = "",
    String drugs = "",
    String drugsEx = "",
    String oralDiseases = "",
    String smoking = "",
    String pregnant = "",
    String pregnantEx = "",
    String lactating = "",
    String lactatingEx = "",
    String contraception = "",
    String contraceptionEx = "",
  }) {
    _id = id;
    _patientId = patientId;
    _health = health;
    _sensitive = sensitive;
    _sensitive_Ex = sensitiveEx;
    _surgical = surgical;
    _surgical_Ex = surgicalEx;
    _haemophilia = haemophilia;
    _haemophilia_Ex = haemophiliaEx;
    _drugs = drugs;
    _drugs_Ex = drugsEx;
    _oralDiseases = oralDiseases;
    _smoking = smoking;
    _pregnant = pregnant;
    _pregnant_Ex = pregnantEx;
    _lactating = lactating;
    _lactating_Ex = lactatingEx;
    _contraception = contraception;
    _contraception_Ex = contraceptionEx;
  }

  PatienHealthtModel.fromMap(Map<String, dynamic> obj) {
    _id = obj["PH_id"];
    _patientId = obj["PH_patientId"].toString();
    _health = obj["PH"];
    _sensitive = obj["PH_sensitive"];
    _sensitive_Ex = obj["PH_sensitive_Ex"];
    _surgical = obj["PH_surgical"];
    _surgical_Ex = obj["PH_surgical_Ex"];
    _haemophilia = obj["PH_haemophilia"];
    _haemophilia_Ex = obj["PH_haemophilia_Ex"];
    _drugs = obj["PH_drugs"];
    _drugs_Ex = obj["PH_drugs_Ex"];
    _oralDiseases = obj["PH_oralDiseases"];
    _smoking = obj["PH_smoking"];
    _pregnant = obj["PH_pregnant"];
    _pregnant_Ex = obj["PH_pregnant_Ex"];
    _lactating = obj["PH_lactating"];
    _lactating_Ex = obj["PH_lactating_Ex"];
    _contraception = obj["PH_contraception"];
    _contraception_Ex = obj["PH_contraception_Ex"] ?? '';
  }

  Map<String, dynamic> toMap() => {
        'PH_id': _id,
        "PH_patientId": _patientId,
        "PH": _health,
        "PH_sensitive": _sensitive,
        "PH_sensitive_Ex": _sensitive_Ex,
        "PH_surgical": _surgical,
        "PH_surgical_Ex": _surgical_Ex,
        "PH_haemophilia": _haemophilia,
        "PH_haemophilia_Ex": _haemophilia_Ex,
        "PH_drugs": _drugs,
        "PH_drugs_Ex": _drugs_Ex,
        "PH_oralDiseases": _oralDiseases,
        "PH_smoking": _smoking,
        "PH_pregnant": _pregnant,
        "PH_pregnant_Ex": _pregnant_Ex,
        "PH_lactating": _lactating,
        "PH_lactating_Ex": _lactating_Ex,
        "PH_contraception": _contraception,
        "PH_contraception_Ex": _contraception_Ex
      };

  String get patientId => _patientId;

  String get contraception_Ex => _contraception_Ex;

  set contraception_Ex(String value) {
    _contraception_Ex = value;
  }

  String get contraception => _contraception;

  set contraception(String value) {
    _contraception = value;
  }

  String get lactating_Ex => _lactating_Ex;

  set lactating_Ex(String value) {
    _lactating_Ex = value;
  }

  String get lactating => _lactating;

  set lactating(String value) {
    _lactating = value;
  }

  String get pregnant_Ex => _pregnant_Ex;

  set pregnant_Ex(String value) {
    _pregnant_Ex = value;
  }

  String get pregnant => _pregnant;

  set pregnant(String value) {
    _pregnant = value;
  }

  String get smoking => _smoking;

  set smoking(String value) {
    _smoking = value;
  }

  String get oralDiseases => _oralDiseases;

  set oralDiseases(String value) {
    _oralDiseases = value;
  }

  String get drugs_Ex => _drugs_Ex;

  set drugs_Ex(String value) {
    _drugs_Ex = value;
  }

  String get drugs => _drugs;

  set drugs(String value) {
    _drugs = value;
  }

  String get haemophilia_Ex => _haemophilia_Ex;

  set haemophilia_Ex(String value) {
    _haemophilia_Ex = value;
  }

  String get haemophilia => _haemophilia;

  set haemophilia(String value) {
    _haemophilia = value;
  }

  String get surgical_Ex => _surgical_Ex;

  set surgical_Ex(String value) {
    _surgical_Ex = value;
  }

  String get surgical => _surgical;

  set surgical(String value) {
    _surgical = value;
  }

  String get sensitive_Ex => _sensitive_Ex;

  set sensitive_Ex(String value) {
    _sensitive_Ex = value;
  }

  String get sensitive => _sensitive;

  set sensitive(String value) {
    _sensitive = value;
  }

  String get health => _health;

  set health(String value) {
    _health = value;
  }

  set patientId(String value) {
    _patientId = value;
  }
}
