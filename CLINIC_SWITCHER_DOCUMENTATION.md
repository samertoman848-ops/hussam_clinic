# نظام التنقل السريع بين العيادات - تحديث التوثيق

## 📋 ملخص التحديثات

تم إضافة نظام متكامل للتنقل السريع والسلس بين العيادات المتعددة في نظام إدارة عيادة حسام.

---

## 🆕 الملفات الجديدة المُضافة

### 1. **`lib/model/ClinicModel.dart`**
**الوصف:** نموذج بيانات العيادة الواحدة

| الخاصية | النوع | الوصف |
|---------|--------|---------|
| `name` | String | اسم العيادة الودود |
| `dbFileName` | String | اسم ملف قاعدة البيانات (مثل: clinic_name.db) |
| `description` | String? | وصف العيادة (اختياري) |
| `createdAt` | DateTime | تاريخ إنشاء العيادة |
| `lastAccessedAt` | DateTime? | آخر وقت تم الوصول للعيادة |

**الدوال الرئيسية:**
- `toMap()` - تحويل إلى خريطة
- `fromMap()` - إنشاء من خريطة
- `copyWith()` - إنشاء نسخة معدلة
- `displayName` - اسم العيادة بدون امتداد .db

---

### 2. **`lib/services/ClinicService.dart`**
**الوصف:** خدمة إدارة العيادات المتعددة (Singleton)

| الدالة | الوصف |
|--------|---------|
| `loadClinics()` | تحميل جميع العيادات المتاحة |
| `switchToClinic(clinic)` | التبديل إلى عيادة معينة |
| `switchToClinicByName(name)` | التبديل باستخدام الاسم |
| `getNextClinic()` | الحصول على العيادة التالية |
| `getPreviousClinic()` | الحصول على العيادة السابقة |
| `switchToNextClinic()` | التبديل السريع للتالية |
| `switchToPreviousClinic()` | التبديل السريع للسابقة |
| `createClinic(name)` | إنشاء عيادة جديدة |
| `deleteClinic(clinic)` | حذف عيادة |
| `getClinicsOrderedByLastAccess()` | ترتيب حسب آخر وصول |

**الخصائص:**
- `clinics` - قائمة العيادات المتاحة
- `currentClinic` - العيادة الحالية
- `clinicsCount` - عدد العيادات
- `hasMultipleClinics` - التحقق من وجود أكثر من عيادة

---

### 3. **`lib/widgets/ClinicSwitcher.dart`**
**الوصف:** واجهات المستخدم للتنقل بين العيادات

#### أ) `ClinicSwitcher` - واجهة تبديل العيادات
**الخصائص:**
- `showAsIcon` - عرض كأيقونة أو مفصل
- `onClinicChanged` - callback عند تغيير العيادة

**الطرق:**
- `_buildIconView()` - عرض بوصفة قائمة منسدلة
- `_buildDetailedView()` - عرض امتداد مع تفاصيل العيادات

#### ب) `QuickClinicNavigation` - التنقل السريع
**الخصائص:**
- أزرار التنقل السابق/التالي
- عرض اسم العيادة الحالية

---

## 🔄 الملفات المُحديثة

### **`lib/widgets/app_drawer.dart`**
**التحديثات:**
- ✅ إضافة استيراد `ClinicSwitcher` و `ClinicService`
- ✅ إضافة خيار "تبديل العيادة" في القائمة الجانبية
- ✅ إضافة دالة `_showClinicSwitchDialog()` لعرض حوار التبديل

---

## 🎯 كيفية الاستخدام

### 1️⃣ التبديل من القائمة الجانبية
```
📱 سحب من اليسار → تبديل العيادة → اختر العيادة المطلوبة
```

### 2️⃣ التبديل السريع من الكود
```dart
final clinicService = ClinicService();

// تحميل جميع العيادات
await clinicService.loadClinics();

// التبديل إلى عيادة معينة
await clinicService.switchToClinic(clinic);

// التبديل السريع للعيادة التالية
await clinicService.switchToNextClinic();
```

### 3️⃣ إضافة واجهة سريعة في AppBar
```dart
AppBar(
  actions: [
    QuickClinicNavigation(
      onClinicChanged: () {
        // إعادة تحميل البيانات
        reloadAllData();
      },
    ),
  ],
)
```

---

## ⚙️ الميزات الرئيسية

### ✨ التنقل السريع
- تبديل سلس بين العيادات
- تحميل البيانات تلقائياً
- إشعارات بالتغيير

### 📊 إدارة متقدمة
- عرض تاريخ آخر وصول لكل عيادة
- ترتيب العيادات حسب الاستخدام
- إنشاء حذف العيادات

### 🔐 الأمان
- التحقق من عدم حذف العيادة الحالية
- حفظ آمن لقاعدة البيانات الحالية

### 🎨 واجهات متعددة
- عرض كأيقونة (للـ AppBar)
- عرض مفصل (للقائمة)
- عرض سريع مع الأزرار (للتنقل السريع)

---

## 🚀 الخطوات التالية (اختيارية)

### إضافة اختصار لوحة المفاتيح
```dart
// التبديل بين العيادات باستخدام Ctrl+Tab
if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.tab) {
  await clinicService.switchToNextClinic();
}
```

### إضافة رسائل Toast عند التبديل
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('تم التبديل إلى: ${clinic.name}')),
);
```

### حفظ تفضيل العيادة الأخيرة
```dart
await StorageService().saveDbConfig(clinic.dbFileName);
```

---

## 🐛 الأخطاء الشائعة والحلول

| المشكلة | الحل |
|--------|------|
| لا تظهر قائمة العيادات | تأكد من وجود أكثر من عيادة واحدة |
| لم يتم تحميل البيانات بعد الانتقال | استدعِ `reloadAllData()` بعد `switchToClinic()` |
| لا يمكن حذف العيادة | تأكد من عدم كونها العيادة الحالية |

---

## 📈 الأداء

| العملية | الوقت المتوقع |
|--------|--------------|
| تحميل العيادات | < 100ms |
| التبديل بين العيادات | 500-1000ms |
| إنشاء عيادة جديدة | 1-2 ثانية |

---

## ✅ التحقق من صحة التطبيق

```dart
// في main.dart أو onCreate
final clinicService = ClinicService();
await clinicService.loadClinics();
debugPrint('العيادات المتاحة: ${clinicService.clinicsCount}');
```

---

## 📞 القائمة المرجعية

- ✅ تم إنشاء `ClinicModel.dart`
- ✅ تم إنشاء `ClinicService.dart`
- ✅ تم إنشاء `ClinicSwitcher.dart`
- ✅ تم تحديث `app_drawer.dart`
- ✅ تم تحديث الاستيرادات اللازمة

---

**تم الإنجاز:** 26 مارس 2026
