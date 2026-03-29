# شرح مفصل لمجلد: lib\db\patients

هذا المجلد يحتوي على ملفات برمجية بلغة Dart لإدارة وظائف العيادة.


## ملف: `dbinvoices.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbInvoices`

**أهم الوظائف (Key Functions):**
- `createTable()`
- `insertInvoice()`
- `print()`
- `getAllInvoices()`
- `getInvoicesByPatient()`
- `getInvoicesByDoctor()`
- `getUnpaidInvoices()`
- `updateInvoice()`
- `markAsPaid()`
- `deleteInvoice()`

---

## ملف: `dbpatient.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbPatient`

**أهم الوظائف (Key Functions):**
- `allPatients()`
- `deletePatient()`
- `updatePatient()`
- `updateFileNoPatient()`
- `getPatientByFileNo()`
- `updatePatientFileNoById()`
- `getPatientById()`
- `upsertPatientFromCloud()`
- `addPatient()`

---

## ملف: `dbpatienthealth.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbPatientHealth`

**أهم الوظائف (Key Functions):**
- `allPHs()`
- `deletePatient()`
- `updatePatientHealth()`
- `addPatientHealth()`

---

## ملف: `dbpatienthealthdoctor.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbPatientHealthDoctor`

**أهم الوظائف (Key Functions):**
- `allPHDs()`
- `searchByPatientId()`
- `deletePHD()`
- `updatePHD()`
- `addPHD()`

---

## ملف: `dbpicture.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbPicture`

**أهم الوظائف (Key Functions):**
- `allPictures()`
- `lastPicture()`
- `print()`
- `deletePicture()`
- `searchPictureByPatientId()`
- `addPicture()`

---

## ملف: `dbtreatmentplans.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbTreatmentPlans`

**أهم الوظائف (Key Functions):**
- `addTreatmentPlan()`
- `print()`
- `getTreatmentPlansByPatient()`
- `getAllTreatmentPlans()`
- `getIncompleteTreatmentPlans()`
- `getCompletedTreatmentPlans()`
- `updateTreatmentPlan()`
- `updateCompletionStatus()`
- `deleteTreatmentPlan()`
- `deleteTreatmentPlansByPatient()`

---

