# شرح مفصل لمجلد: lib\db

هذا المجلد يحتوي على ملفات برمجية بلغة Dart لإدارة وظائف العيادة.


## ملف: `dbdate.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbDate`

**أهم الوظائف (Key Functions):**
- `alldate()`
- `lastDate()`
- `searchDatesById()`
- `deletedate()`
- `updateDate()`
- `adddate()`

---

## ملف: `dbemployee.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbEmployee`

**أهم الوظائف (Key Functions):**
- `allEmployeesModel()`
- `allEmployeesM()`
- `deleteEmployee()`
- `addEmployee()`
- `updateEmployee()`

---

## ملف: `dbhelper.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbHelper`

**أهم الوظائف (Key Functions):**
- `copyAssetsDb()`
- `print()`
- `backupDb()`
- `saveOverridePath()`
- `configuredDbPath()`
- `openDb()`
- `debugPrint()`
- `getDatabase()`
- `closeDB()`

---

## ملف: `dbrooms.dart`

**الوصف العام:** هذا ملف "قاعدة بيانات" (Database Helper) مسؤول عن عمليات الإدخال والحذف والتعديل والجلب من SQLite.

**الكلاسات المعرفة (Classes):**
- `DbRooms`

**أهم الوظائف (Key Functions):**
- `allRooms()`
- `addRoom()`
- `deleteRoom()`
- `updateRoom()`
- `updateRoomName()`
- `deleteRoomByName()`
- `tableExists()`
- `createRoomsTable()`
- `print()`
- `ensureDefaultRooms()`

---

