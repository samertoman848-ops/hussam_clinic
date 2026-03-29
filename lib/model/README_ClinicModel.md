# 📚 نموذج العيادة - ClinicModel

## 📖 نظرة عامة
نموذج بيانات شامل يمثل العيادة الواحدة في النظام.

## 🏢 الفئة الرئيسية

### `ClinicModel`
يحتوي على جميع معلومات العيادة الأساسية.

### الخصائص

| الخاصية | النوع | الوصف |
|---------|--------|---------|
| `name` | `String` | اسم العيادة الودود (مثل: عيادة نور، عيادة الزهراء) |
| `dbFileName` | `String` | اسم ملف قاعدة البيانات (مثل: clinic_name.db) |
| `description` | `String?` | وصف إضافي للعيادة (اختياري) |
| `createdAt` | `DateTime` | تاريخ إنشاء العيادة |
| `lastAccessedAt` | `DateTime?` | آخر وقت تم الوصول للعيادة |

## 🔧 الدوال الرئيسية

### `toMap()`
تحويل النموذج إلى خريطة (Map) لتخزين البيانات:
```dart
Map<String, dynamic> clinic = model.toMap();
```

### `fromMap()`
إنشاء نموذج من خريطة:
```dart
ClinicModel clinic = ClinicModel.fromMap(data);
```

### `displayName`
الحصول على اسم العيادة بدون امتداد .db:
```dart
String name = clinic.displayName; // "clinic_name" بدلاً من "clinic_name.db"
```

### `copyWith()`
إنشاء نسخة معدلة من النموذج:
```dart
ClinicModel updated = clinic.copyWith(name: 'اسم جديد');
```

## 💡 أمثلة الاستخدام

### إنشاء عيادة جديدة
```dart
ClinicModel clinic = ClinicModel(
  name: 'عيادة نور',
  dbFileName: 'clinic_noor.db',
  description: 'عيادة متخصصة',
);
```

### المقارنة بين عيادتين
```dart
if (clinic1 == clinic2) {
  print('نفس العيادة');
}
```

### الحصول على معلومات العيادة
```dart
print(clinic); // عرض ودود: Clinic(name: عيادة نور, db: clinic_noor.db, ...)
```

## 📌 ملاحظات مهمة

- يعتمد النموذج على `DateTime` لتتبع تواريخ الإنشاء والوصول
- يدعم النموذج المقارنة والتجزئة
- `lastAccessedAt` يُحدّث تلقائياً عند التبديل للعيادة

---

**الملف:** `lib/model/ClinicModel.dart`  
**الحالة:** ✅ جاهز للاستخدام
