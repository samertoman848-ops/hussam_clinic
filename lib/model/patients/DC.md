# شرح مفصل لمجلد: lib\model\patients

هذا المجلد يحتوي على ملفات برمجية بلغة Dart لإدارة وظائف العيادة.


## ملف: `InvoiceModel.dart`

**الوصف العام:** هذا ملف "نموذج بيانات" (Model) يُستخدم لتعريف بنية البيانات التي يتعامل معها النظام (Data Structure).

**الكلاسات المعرفة (Classes):**
- `InvoiceModel`

**أهم الوظائف (Key Functions):**
- `invoiceId()`
- `treatmentPlanId()`
- `patientId()`
- `toothNumber()`
- `treatmentName()`
- `treatmentCost()`
- `doctorName()`
- `invoiceDate()`
- `isPaid()`
- `paymentMethod()`

---

## ملف: `PatientHealthDoctorModel.dart`

**الوصف العام:** هذا ملف "نموذج بيانات" (Model) يُستخدم لتعريف بنية البيانات التي يتعامل معها النظام (Data Structure).

**الكلاسات المعرفة (Classes):**
- `PatienHealthtDoctorModel`

**أهم الوظائف (Key Functions):**
- `id()`
- `patientId()`
- `doctorId()`
- `doctorName()`
- `date()`
- `treatment()`
- `diagnosis()`

---

## ملف: `PatientHealthModel.dart`

**الوصف العام:** هذا ملف "نموذج بيانات" (Model) يُستخدم لتعريف بنية البيانات التي يتعامل معها النظام (Data Structure).

**الكلاسات المعرفة (Classes):**
- `PatienHealthtModel`

**أهم الوظائف (Key Functions):**
- `id()`
- `contraception_Ex()`
- `contraception()`
- `lactating_Ex()`
- `lactating()`
- `pregnant_Ex()`
- `pregnant()`
- `smoking()`
- `oralDiseases()`
- `drugs_Ex()`

---

## ملف: `PatientModel.dart`

**الوصف العام:** هذا ملف "نموذج بيانات" (Model) يُستخدم لتعريف بنية البيانات التي يتعامل معها النظام (Data Structure).

**الكلاسات المعرفة (Classes):**
- `PatientModel`

**أهم الوظائف (Key Functions):**
- `id()`
- `birthDay()`
- `status()`
- `worries()`
- `resone()`
- `fileNo()`
- `age()`
- `sex()`
- `address()`
- `mobile()`

---

## ملف: `TreatmentPlanModel.dart`

**الوصف العام:** هذا ملف "نموذج بيانات" (Model) يُستخدم لتعريف بنية البيانات التي يتعامل معها النظام (Data Structure).

**الكلاسات المعرفة (Classes):**
- `TreatmentPlanModel`

**أهم الوظائف (Key Functions):**
- `id()`
- `patientId()`
- `toothNumber()`
- `treatmentName()`
- `treatmentDate()`
- `doctorName()`
- `isCompleted()`
- `notes()`
- `toString()`

---

