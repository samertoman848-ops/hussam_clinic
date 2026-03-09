class InvoiceModel {
  int _invoiceId = 0;
  int _treatmentPlanId = 0;
  int _patientId = 0;
  String _toothNumber = "";
  String _treatmentName = "";
  double _treatmentCost = 0.0;
  String _doctorName = "";
  String _invoiceDate = "";
  bool _isPaid = false;
  String _paymentMethod = ""; // cash, card, check
  String _notes = "";

  InvoiceModel();

  // Getters
  int get invoiceId => _invoiceId;
  int get treatmentPlanId => _treatmentPlanId;
  int get patientId => _patientId;
  String get toothNumber => _toothNumber;
  String get treatmentName => _treatmentName;
  double get treatmentCost => _treatmentCost;
  String get doctorName => _doctorName;
  String get invoiceDate => _invoiceDate;
  bool get isPaid => _isPaid;
  String get paymentMethod => _paymentMethod;
  String get notes => _notes;

  // Setters
  set invoiceId(int value) => _invoiceId = value;
  set treatmentPlanId(int value) => _treatmentPlanId = value;
  set patientId(int value) => _patientId = value;
  set toothNumber(String value) => _toothNumber = value;
  set treatmentName(String value) => _treatmentName = value;
  set treatmentCost(double value) => _treatmentCost = value;
  set doctorName(String value) => _doctorName = value;
  set invoiceDate(String value) => _invoiceDate = value;
  set isPaid(bool value) => _isPaid = value;
  set paymentMethod(String value) => _paymentMethod = value;
  set notes(String value) => _notes = value;

  // Constructor from map
  InvoiceModel.fromMap(Map<String, dynamic> data) {
    _invoiceId = (data["inv_id"] as int?) ?? 0;
    _treatmentPlanId = (data["inv_treatment_plan_id"] as int?) ?? 0;
    _patientId = (data["inv_patient_id"] as int?) ?? 0;
    _toothNumber = data["inv_tooth_number"] as String? ?? "";
    _treatmentName = data["inv_treatment_name"] as String? ?? "";
    _treatmentCost = (data["inv_treatment_cost"] as num?)?.toDouble() ?? 0.0;
    _doctorName = data["inv_doctor_name"] as String? ?? "";
    _invoiceDate = data["inv_invoice_date"] as String? ?? "";
    _isPaid = (data["inv_is_paid"] as int?) == 1;
    _paymentMethod = data["inv_payment_method"] as String? ?? "";
    _notes = data["inv_notes"] as String? ?? "";
  }

  // Convert to map for database
  Map<String, dynamic> toMap() => {
        "inv_id": _invoiceId,
        "inv_treatment_plan_id": _treatmentPlanId,
        "inv_patient_id": _patientId,
        "inv_tooth_number": _toothNumber,
        "inv_treatment_name": _treatmentName,
        "inv_treatment_cost": _treatmentCost,
        "inv_doctor_name": _doctorName,
        "inv_invoice_date": _invoiceDate,
        "inv_is_paid": _isPaid ? 1 : 0,
        "inv_payment_method": _paymentMethod,
        "inv_notes": _notes,
      };
}
