# 📚 مجلد الخدمات - Services Documentation

## 📖 نظرة عامة
يحتوي هذا المجلد على جميع الخدمات الأساسية للنظام بما فيها:
- إدارة العيادات
- المصادقة والجلسات
- التخزين والإعدادات
- وغيرها

---

## 📁 محتويات المجلد

### الخدمات الأساسية

#### 1. **ClinicService.dart** - إدارة العيادات
- **الوصف:** خدمة Singleton لإدارة والتنقل بين عيادات متعددة
- **الملف:** [README_ClinicService.md](README_ClinicService.md)
- **المميزات:**
  - تحميل تلقائي للعيادات
  - تبديل سلس
  - إنشاء وحذف
  - ترتيب ذكي

#### 2. **AuthService.dart** - المصادقة والعيادات الجديدة
- **الوصف:** إدارة تسجيل الدخول والخروج والمستخدمين
- **الملف:** [README_SessionTimeout.md](README_SessionTimeout.md)
- **المميزات:**
  - تسجيل دخول آمن
  - جلسات 3 ساعات
  - تنبيهات تلقائية
  - خروج آمن

#### 3. **StorageService.dart** - التخزين والإعدادات
- **الوصف:** حفظ واستعادة الإعدادات والمسارات
- **المميزات:**
  - حفظ مسار البيانات
  - حفظ اسم العيادة الحالية
  - نقل البيانات
  - استعادة الإعدادات

#### 4. **BackupService.dart** - النسخ الاحتياطية
- **الوصف:** إدارة النسخ الاحتياطية التلقائية والدليلية
- **المميزات:**
  - نسخ احتياطية تلقائية
  - نسخ دليلية
  - جدولة النسخ

#### 5. **FirebaseSyncService.dart** - مزامنة السحابة
- **الوصف:** مزامنة البيانات مع Firebase
- **المميزات:**
  - رفع البيانات
  - تحميل البيانات
  - مزامنة تلقائية

#### 6. **DbImportService.dart** - استيراد البيانات
- **الوصف:** استيراد بيانات من قواعد بيانات أخرى
- **المميزات:**
  - دمج البيانات
  - التعامل مع التكرارات
  - تقارير التقدم

#### 7. **NotificationService.dart** - الإشعارات
- **الوصف:** إدارة الإشعارات والتنبيهات
- **المميزات:**
  - إشعارات محلية
  - إشعارات Push
  - جدولة الإشعارات

---

## 🔗 التكامل بين الخدمات

```
User Authentication
    ↓ (login success)
ClinicService (load clinics)
    ↓
StorageService (save selected clinic)
    ↓
DbHelper (open clinic database)
    ↓
App loads data
    ↓ (every minute)
AuthService (check session)
    ↓ (session about to expire)
NotificationService (show warning)
    ↓ (session expired)
AuthService (force logout)
    ↓
LoginPage (redirect)
```

---

## 📋 جدول الخدمات الكامل

| الخدمة | الحالة | الوصف |
|--------|--------|---------|
| ClinicService | ✅ جديد | إدارة العيادات |
| AuthService | ✅ محدث | المصادقة + الجلسات |
| StorageService | ✅ موجود | التخزين |
| BackupService | ✅ موجود | النسخ الاحتياطية |
| FirebaseSyncService | ✅ موجود | المزامنة السحابية |
| DbImportService | ✅ موجود | استيراد البيانات |
| NotificationService | ✅ موجود | الإشعارات |

---

## 💡 أمثلة الاستخدام الشائعة

### تحميل العيادات
```dart
ClinicService clinicService = ClinicService();
await clinicService.loadClinics();
```

### التبديل بين العيادات
```dart
await clinicService.switchToClinic(clinic);
await reloadAllData();
```

### التحقق من الجلسة
```dart
if (AuthService().isAuthenticated) {
  // الجلسة سارية
} else {
  // الجلسة انتهت
}
```

### حفظ الإعدادات
```dart
await StorageService().saveDbConfig('clinic_name.db');
```

---

## 🔍 البحث عن خدمة معينة

### بواسطة الميزات:
- **التنقل بين العيادات:** ClinicService
- **المصادقة:** AuthService
- **حفظ البيانات:** StorageService
- **النسخ الاحتياطية:** BackupService
- **السحابة:** FirebaseSyncService

### بواسطة الاسم:
- **Clinic\*:** ClinicService
- **Auth\*:** AuthService
- **Storage\*:** StorageService
- **Backup\*:** BackupService
- **Firebase\*:** FirebaseSyncService

---

## ⚙️ التكوين والإعدادات

### الملف الرئيسي:
`lib/services/` - يحتوي على جميع الخدمات

### متطلبات الاستخدام:
تأكد من استيراد الخدمة المطلوبة:
```dart
import 'package:hussam_clinc/services/ClinicService.dart';
```

---

## 🚀 أفضل الممارسات

1. **استخدم Singleton** - الخدمات توفر Singleton تلقائياً
2. **استدعِ loadClinics()** - قبل استخدام أي خدمة
3. **تعامل مع الأخطاء** - استخدم try-catch
4. **احفظ الإعدادات** - بعد أي تغيير مهم
5. **أعد تحميل البيانات** - بعد التبديل بين العيادات

---

## 📝 ملفات التوثيق الموجودة

| الملف | الموضوع |
|-------|----------|
| [README_ClinicService.md](README_ClinicService.md) | إدارة العيادات |
| [README_SessionTimeout.md](README_SessionTimeout.md) | نظام الجلسات |

---

## 🔄 التحديثات الأخيرة

### آخر التحديثات:
- ✅ إضافة ClinicService
- ✅ تحديث AuthService بنظام الجلسات
- ✅ توثيق شامل

### التالي:
- [ ] إضافة خدمة البحث
- [ ] خدمة التقارير
- [ ] خدمة النسخ الاحتياطية المتقدمة

---

**المجلد:** `lib/services/`  
**الحالة:** ✅ منظم وموثق بالكامل  
**آخر تحديث:** 26 مارس 2026
