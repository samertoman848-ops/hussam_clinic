# نظام انتهاء جلسة العمل في نظام إدارة عيادة حسام

## نظرة عامة
تم تطوير نظام متقدم لإدارة جلسات العمل بحيث تنتهي الجلسة تلقائياً بعد **3 ساعات** من تسجيل الدخول، ثم يتم إعادة توجيه المستخدم إلى صفحة تسجيل الدخول.

---

## المميزات الرئيسية

### 1. **انتهاء الجلسة التلقائي**
- مدة الجلسة: **180 دقيقة (3 ساعات)**
- يتم حفظ وقت بداية الجلسة عند تسجيل الدخول
- يتم التحقق من الجلسة كل دقيقة واحدة

### 2. **تنبيهات قبل انتهاء الجلسة**
- عندما يتبقى **10 دقائق** على انتهاء الجلسة:
  - يظهر إشعار تحذيري برتقالي اللون أسفل الشاشة
  - يخبر المستخدم بعدد الدقائق المتبقية

### 3. **تسجيل خروج تلقائي**
- عند انتهاء الـ 3 ساعات:
  - يتم عرض نافذة حوار تُعلم المستخدم بانتهاء الجلسة
  - يتم تسجيل الخروج تلقائياً
  - يتم إعادة توجيه المستخدم إلى صفحة تسجيل الدخول

---

## الملفات المُعدّلة

### 1. **`lib/model/UserModel.dart`**
#### التغييرات:
- **إضافة حقل جديد**: `loginTime: DateTime`
  - يسجل وقت تسجيل الدخول بدقة
  - يُشغّل تلقائياً بـ `DateTime.now()` عند إنشاء المستخدم

```dart
final DateTime loginTime;

UserModel({
  // ... other fields
  DateTime? loginTime,
}) : loginTime = loginTime ?? DateTime.now();
```

---

### 2. **`lib/services/AuthService.dart`**
#### التغييرات الرئيسية:

#### أ) ثابت مدة الجلسة:
```dart
static const int sessionTimeoutMinutes = 180; // 3 hours
```

#### ب) دوال جديدة:

**1. `_isSessionExpired()` - التحقق من انتهاء الجلسة**
```dart
bool _isSessionExpired() {
  if (_currentUser == null) return false;
  
  final now = DateTime.now();
  final sessionDuration = now.difference(_currentUser!.loginTime).inMinutes;
  
  return sessionDuration >= sessionTimeoutMinutes;
}
```

**2. `getSessionRemainingMinutes()` - الحصول على الدقائق المتبقية**
```dart
int getSessionRemainingMinutes() {
  // يُرجع عدد الدقائق المتبقية قبل انتهاء الجلسة
}
```

**3. `isSessionAboutToExpire()` - التحقق من قرب انتهاء الجلسة**
```dart
bool isSessionAboutToExpire() {
  return getSessionRemainingMinutes() <= 10; // تنبيه عندما يبقى 10 دقائق
}
```

**4. `autoLogoutIfSessionExpired()` - تسجيل خروج تلقائي**
```dart
void autoLogoutIfSessionExpired() {
  if (_isSessionExpired()) {
    logout();
  }
}
```

#### ج) تعديل `isAuthenticated`:
```dart
bool get isAuthenticated => _currentUser != null && !_isSessionExpired();
```
- الآن يتحقق من انتهاء الجلسة أيضاً

---

### 3. **`lib/data/TimetableWidgt.dart`** (الشاشة الرئيسية)
#### التغييرات:

#### أ) استيراد المكتبات الجديدة:
```dart
import 'dart:async';
import '../services/AuthService.dart';
import '../pages/auth/login_page.dart';
```

#### ب) إضافة Timer في الـ State:
```dart
late Timer _sessionCheckTimer;
```

#### ج) في `initState()`:
```dart
_sessionCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
  _checkSessionExpiry();
});

_checkSessionExpiry(); // فحص فوري
```

#### د) دالة `_checkSessionExpiry()`:
```dart
void _checkSessionExpiry() {
  final authService = AuthService();
  
  // 1. إذا انتهت الجلسة -> عرض حوار وإعادة توجيه
  if (!authService.isAuthenticated) {
    showDialog(...);
  }
  
  // 2. إذا قاربت على الانتهاء -> عرض تحذير
  else if (authService.isSessionAboutToExpire()) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}
```

#### هـ) في `dispose()`:
```dart
@override
void dispose() {
  _sessionCheckTimer.cancel(); // إيقاف المؤقت
  super.dispose();
}
```

---

## سير العمل

### السيناريو 1: تسجيل دخول عادي
```
1. المستخدم يدخل البيانات
   ↓
2. يتم تسجيل الدخول (loginTime = الآن)
   ↓
3. يتم الدخول للشاشة الرئيسية
   ↓
4. يبدأ Timer يفحص الجلسة كل دقيقة
```

### السيناريو 2: مرور ساعة و 50 دقيقة
```
   ↓
يحسب النظام: 180 - 170 = 10 دقائق متبقية
   ↓
يعرض تحذير: "تحذير: سينتهي وقت جلستك خلال 10 دقائق"
```

### السيناريو 3: مرور 3 ساعات كاملة
```
   ↓
يحسب النظام: 180 - 180 = 0 دقائق متبقية (جلسة منتهية)
   ↓
يعرض حوار: "انتهت جلسة العمل"
   ↓
يتم التسجيل الخروج التلقائي
   ↓
يتم توجيه المستخدم لصفحة تسجيل الدخول
```

---

## معادلة حساب انتهاء الجلسة

```
الدقائق المنقضية = الوقت الحالي - وقت تسجيل الدخول

إذا كانت الدقائق المنقضية ≥ 180 دقيقة:
    ✓ الجلسة منتهية
    
إذا كانت الدقائق المتبقية ≤ 10 دقائق:
    ⚠ عرض تحذير
```

---

## الإعدادات القابلة للتخصيص

### تعديل مدة الجلسة
إذا أردت تغيير مدة الجلسة (مثلاً إلى 4 ساعات):

```dart
// في AuthService.dart
static const int sessionTimeoutMinutes = 240; // 4 hours
```

### تعديل حد التحذير
إذا أردت تغيير وقت عرض التحذير (بدلاً من 10 دقائق):

```dart
// في AuthService.dart
bool isSessionAboutToExpire() {
  return getSessionRemainingMinutes() <= 15; // تحذير 15 دقيقة قبل الانتهاء
}
```

### تعديل تكرار الفحص
إذا أردت فحص الجلسة أكثر من مرة في الدقيقة:

```dart
// في TimetableWidgt.dart - initState()
_sessionCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) { // كل 30 ثانية
  _checkSessionExpiry();
});
```

---

## أمثلة الاستخدام

### التحقق من حالة الجلسة في أي مكان
```dart
final authService = AuthService();

// التحقق من تسجيل الدخول
if (authService.isAuthenticated) {
  print('المستخدم مسجل دخول');
}

// الحصول على الدقائق المتبقية
int remaining = authService.getSessionRemainingMinutes();
print('وقت متبقي: $remaining دقيقة');

// التحقق من قرب الانتهاء
if (authService.isSessionAboutToExpire()) {
  print('الجلسة قاربت على الانتهاء');
}
```

---

## الرسائل المعروضة للمستخدم

### 1️⃣ رسالة التحذير (قبل 10 دقائق)
```
تحذير: سينتهي وقت جلستك خلال X دقائق
```

### 2️⃣ حوار انتهاء الجلسة
```
العنوان: "انتهت جلسة العمل"
الرسالة: "لقد انتهت مدة جلستك، يرجى تسجيل الدخول مجدداً"
الزر: "تسجيل الدخول"
```

---

## معلومات تقنية

### TimeZone
- يتم استخدام الوقت المحلي للجهاز (`DateTime.now()`)
- لا يتأثر بـ TimeZones المختلفة

### الأداء
- فحص الجلسة يحدث كل دقيقة (لا تأثير سلبي على الأداء)
- لا يوجد فحص في الخلفية عندما تكون التطبيق مغلقة

### الأمان
- المستخدم لا يستطيع تمديد الجلسة داخل الكود
- الجلسة تنتهي بالضرورة بعد 3 ساعات

---

## نصائح للمستخدمين

✅ **افضل الممارسات:**
1. لاحظ التنبيهات قبل انتهاء الجلسة
2. أحفظ عملك قبل انتهاء الجلسة
3. إذا احتجت وقت أطول، قم بإعادة تسجيل الدخول

---

## الخلاصة

| الميزة | الوصف |
|--------|---------|
| مدة الجلسة | 180 دقيقة (3 ساعات) |
| فترة الفحص | كل دقيقة واحدة |
| التنبيه | قبل 10 دقائق من الانتهاء |
| التسجيل الخروج | تلقائي بعد انتهاء الجلسة |
| إعادة التوجيه | إلى صفحة تسجيل الدخول |

---

**تم التطوير بنجاح في:** 26 مارس 2026
