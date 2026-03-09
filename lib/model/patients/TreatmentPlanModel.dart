class TreatmentPlanModel {
  int _id = 0;
  int _patientId = 0;
  String _toothNumber = "";
  String _treatmentName = "";
  String _treatmentDate = "";
  String _doctorName = "";
  bool _isCompleted = false;
  String _notes = "";

  TreatmentPlanModel();

  // Getters
  int get id => _id;
  int get patientId => _patientId;
  String get toothNumber => _toothNumber;
  String get treatmentName => _treatmentName;
  String get treatmentDate => _treatmentDate;
  String get doctorName => _doctorName;
  bool get isCompleted => _isCompleted;
  String get notes => _notes;

  // Setters
  set id(int value) => _id = value;
  set patientId(int value) => _patientId = value;
  set toothNumber(String value) => _toothNumber = value;
  set treatmentName(String value) => _treatmentName = value;
  set treatmentDate(String value) => _treatmentDate = value;
  set doctorName(String value) => _doctorName = value;
  set isCompleted(bool value) => _isCompleted = value;
  set notes(String value) => _notes = value;

  // Constructor from map
  TreatmentPlanModel.fromMap(Map<String, dynamic> data) {
    _id = (data["tp_id"] as int?) ?? 0;
    _patientId = (data["tp_patient_id"] as int?) ?? 0;
    _toothNumber = data["tp_tooth_number"] as String? ?? "";
    _treatmentName = data["tp_treatment_name"] as String? ?? "";
    _treatmentDate = data["tp_treatment_date"] as String? ?? "";
    _doctorName = data["tp_doctor_name"] as String? ?? "";
    _isCompleted = (data["tp_is_completed"] as int?) == 1;
    _notes = data["tp_notes"] as String? ?? "";
  }

  // Convert to map for database
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "tp_patient_id": _patientId,
      "tp_tooth_number": _toothNumber,
      "tp_treatment_name": _treatmentName,
      "tp_treatment_date": _treatmentDate,
      "tp_doctor_name": _doctorName,
      "tp_is_completed": _isCompleted ? 1 : 0,
      "tp_notes": _notes,
    };
    if (_id > 0) {
      map["tp_id"] = _id;
    }
    return map;
  }

  // Map for update (excludes id)
  Map<String, dynamic> toUpdateMap() => {
        "tp_patient_id": _patientId,
        "tp_tooth_number": _toothNumber,
        "tp_treatment_name": _treatmentName,
        "tp_treatment_date": _treatmentDate,
        "tp_doctor_name": _doctorName,
        "tp_is_completed": _isCompleted ? 1 : 0,
        "tp_notes": _notes,
      };

  @override
  String toString() =>
      "TreatmentPlan: $toothNumber | $treatmentName | $doctorName | ${_isCompleted ? 'مكتمل' : 'قيد التنفيذ'}";
}
