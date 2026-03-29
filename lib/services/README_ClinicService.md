# 🏥 خدمات الكلينك - Clinic Services

## 📖 نظرة عامة
يحتوي هذا المجلد على خدمات إدارة العيادات المتعددة والتنقل بينها.

---

## 📦 الملفات الموجودة

### 1. `ClinicService.dart` - 🌟 خدمة إدارة العيادات الرئيسية

#### الوصف
خدمة Singleton توفر جميع وظائف إدارة والتنقل بين العيادات.

#### 🔑 الخصائص الرئيسية

| الخاصية | النوع | الوصف |
|---------|--------|---------|
| `clinics` | `List<ClinicModel>` | قائمة جميع العيادات المتاحة |
| `currentClinic` | `ClinicModel?` | العيادة المختارة حالياً |
| `currentClinicName` | `String` | اسم العيادة الحالية |
| `clinicsCount` | `int` | عدد العيادات المتاحة |
| `hasMultipleClinics` | `bool` | هل يوجد أكثر من عيادة |

#### 🚀 الدوال الرئيسية

| الدالة | الوصف |
|--------|---------|
| `loadClinics()` | تحميل جميع العيادات المتاحة من المجلد |
| `switchToClinic(clinic)` | التبديل لعيادة معينة |
| `switchToClinicByName(name)` | التبديل باستخدام اسم العيادة |
| `switchToNextClinic()` | الانتقال للعيادة التالية (سريع) |
| `switchToPreviousClinic()` | الانتقال للعيادة السابقة (سريع) |
| `createClinic(name)` | إنشاء عيادة جديدة |
| `deleteClinic(clinic)` | حذف عيادة آمن |
| `getNextClinic()` | الحصول على بيانات العيادة التالية |
| `getPreviousClinic()` | الحصول على بيانات العيادة السابقة |
| `getClinicsOrderedByLastAccess()` | ترتيب العيادات حسب آخر وصول |

#### 💡 أمثلة الاستخدام

**تحميل العيادات:**
```dart
final clinicService = ClinicService();
await clinicService.loadClinics();
```

**التبديل للعيادة التالية:**
```dart
await clinicService.switchToNextClinic();
await reloadAllData();
```

**إنشاء عيادة جديدة:**
```dart
bool success = await clinicService.createClinic('عيادة جديدة');
```

**حذف عيادة:**
```dart
bool success = await clinicService.deleteClinic(clinic);
```

#### ⚠️ نقاط مهمة

1. **Singleton Pattern** - يضمن وجود مثيل واحد فقط
2. **التحميل التلقائي** - تحميل العيادات عند الحاجة الأولى
3. **الأمان** - لا يمكن حذف العيادة الحالية
4. **إعادة التحميل** - استدعِ `reloadAllData()` بعد التبديل

---

### 2. `StorageService.dart` - 💾 خدمة التخزين (موجود سابقاً)
توفر وظائف حفظ واستعادة الإعدادات والمسارات.

---

## 🔄 التكامل مع الخدمات الأخرى

```
ClinicService
    ↓
StorageService (حفظ اسم العيادة الحالية)
    ↓
DbHelper (فتح قاعدة البيانات)
    ↓
```

---

## 📊 معلومات العيادات

### كيفية تخزين العيادات:
- كل عيادة لها ملف قاعدة بيانات منفصل
- اسم الملف = سجل العيادة الفريد
- تخزن البيانات في: `extDbFolder` (من globals.dart)

### مثال البنية:
```
extDbFolder/
├── clinic_1.db      (عيادة 1)
├── clinic_2.db      (عيادة 2)
└── clinic_3.db      (عيادة 3)
```

---

## 🎯 حالات الاستخدام الشائعة

### السيناريو 1: عرض قائمة العيادات
```dart
final clinicService = ClinicService();
for (var clinic in clinicService.clinics) {
  print('${clinic.name} - آخر وصول: ${clinic.lastAccessedAt}');
}
```

### السيناريو 2: التبديل الآمن
```dart
if (await clinicService.switchToClinic(clinic)) {
  await reloadAllData();
  print('تم التبديل بنجاح');
}
```

### السيناريو 3: التنقل السريع
```dart
// الزر التالي
await clinicService.switchToNextClinic();

// الزر السابق
await clinicService.switchToPreviousClinic();
```

---

## 🔍 استكشاف الأخطاء

| المشكلة | الحل |
|--------|------|
| لا تظهر العيادات | تأكد من وجود ملفات .db في المجلد |
| فشل التبديل | تحقق من أن العيادة غير الحالية |
| البيانات لم تُحدّث | استدعِ `reloadAllData()` بعد التبديل |

---

**المجلد:** `lib/services/`  
**الحالة:** ✅ جاهز للإنتاج
