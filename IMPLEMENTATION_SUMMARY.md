# ملخص تطوير نظام انتهاء الجلسة

## 📋 المتطلبات الأصلية
- التسجيل والدخول للنظام يجب أن يكون أكثر من 3 ساعات
- ثم يتم الخروج التلقائي

---

## ✅ التعديلات المنجزة

### 1. تعديل `lib/model/UserModel.dart`
**الإضافة:** حقل `loginTime: DateTime`
- يسجل بدقة وقت تسجيل الدخول
- يُستخدم لحساب مدة الجلسة

```dart
final DateTime loginTime;

UserModel({
  // ...
  DateTime? loginTime,
}) : loginTime = loginTime ?? DateTime.now();
```

---

### 2. تعديل `lib/services/AuthService.dart`
**الإضافات:**

#### أ) ثابت مدة الجلسة
```dart
static const int sessionTimeoutMinutes = 180; // 3 ساعات
```

#### ب) دوال مساعدة جديدة
- `_isSessionExpired()` → التحقق من انتهاء الجلسة
- `getSessionRemainingMinutes()` → الحصول على الوقت المتبقي
- `isSessionAboutToExpire()` → تحذير قبل 10 دقائق
- `autoLogoutIfSessionExpired()` → تسجيل خروج تلقائي

#### ج) تحديث `isAuthenticated`
```dart
bool get isAuthenticated => _currentUser != null && !_isSessionExpired();
```

#### د) تحديث عملية الـ login
```dart
_currentUser = UserModel.fromMap(res.first); // يحتوي على loginTime الآن
```

---

### 3. تعديل `lib/data/TimetableWidgt.dart`
**الإضافات:**

#### أ) الاستيرادات الجديدة
```dart
import 'dart:async';
import '../services/AuthService.dart';
import '../pages/auth/login_page.dart';
```

#### ب) Timer لفحص الجلسة
```dart
late Timer _sessionCheckTimer;
```

#### ج) في `initState()`
```dart
// فحص كل دقيقة
_sessionCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
  _checkSessionExpiry();
});

// فحص فوري عند الدخول
_checkSessionExpiry();
```

#### د) دالة `_checkSessionExpiry()`
- تحقق من انتهاء الجلسة
- إذا انتهت → عرض حوار وإعادة توجيه
- إذا قاربت → عرض تحذير

#### هـ) في `dispose()`
```dart
_sessionCheckTimer.cancel();
```

---

## 🔄 سير العمل الكامل

```
1. تسجيل الدخول
   ├─ يدخل المستخدم البيانات
   ├─ يتم التحقق من صحتها
   └─ يتم إنشاء UserModel مع loginTime = الآن
   
2. الدخول للشاشة الرئيسية
   ├─ يبدأ Timer يفحص الجلسة كل دقيقة
   └─ يتم الفحص الفوري للجلسة
   
3. أثناء العمل (كل دقيقة)
   ├─ حساب: الدقائق المنقضية = الآن - loginTime
   ├─ إذا كانت < 180 دقيقة ✓ الجلسة سارية
   └─ إذا كانت ≥ 180 دقيقة ✗ الجلسة انتهت
   
4. قبل 10 دقائق من الانتهاء
   └─ عرض تحذير: "تحذير: سينتهي وقت جلستك خلال 10 دقائق"
   
5. بعد 3 ساعات (180 دقيقة)
   ├─ الجلسة تصبح غير صالحة (isAuthenticated = false)
   ├─ عرض حوار: "انتهت جلسة العمل"
   ├─ إلغاء Timer
   └─ إعادة التوجيه لصفحة تسجيل الدخول
```

---

## ⚙️ الإعدادات الافتراضية

| الإعداد | القيمة | الملف |
|-------|--------|---------|
| مدة الجلسة | 180 دقيقة (3 ساعات) | `AuthService.dart` |
| فترة الفحص | كل دقيقة | `TimetableWidgt.dart` |
| حد التحذير | 10 دقائق | `AuthService.dart` |

---

## 🎯 الميزات المضافة

✅ **1. حفظ وقت تسجيل الدخول**
   - يتم تسجيل الوقت بدقة عند كل دخول

✅ **2. فحص دوري للجلسة**
   - يتم الفحص كل دقيقة واحدة

✅ **3. تنبيهات قبل الانتهاء**
   - تحذير برتقالي قبل 10 دقائق

✅ **4. تسجيل خروج تلقائي**
   - يتم التسجيل الخروج بعد 3 ساعات بالضبط

✅ **5. إعادة توجيه آمنة**
   - المستخدم يُعاد لصفحة تسجيل الدخول

---

## 🧪 اختبار النظام

### اختبار سريع (تغيير مدة الجلسة مؤقتاً)
للاختبار السريع، يمكنك تغيير `sessionTimeoutMinutes` إلى قيمة صغيرة:

```dart
// في AuthService.dart - للاختبار فقط
static const int sessionTimeoutMinutes = 2; // 2 دقيقة بدلاً من 180

// أعد القيمة الأصلية بعد الانتهاء من الاختبار
static const int sessionTimeoutMinutes = 180; // 3 ساعات
```

---

## 📁 الملفات المعدلة

1. ✅ `lib/model/UserModel.dart` - تم إضافة `loginTime`
2. ✅ `lib/services/AuthService.dart` - تم إضافة نظام فحص الجلسة
3. ✅ `lib/data/TimetableWidgt.dart` - تم إضافة Timer والفحص الدوري

---

## 💡 ملاحظات مهمة

1. **لا يوجد تمديد للجلسة من المستخدم**
   - الجلسة تنتهي دائماً بعد 3 ساعات
   - المستخدم يجب أن يسجل الدخول مجدداً

2. **الجلسة تنتهي حتى لو كان المستخدم نشطاً**
   - لم نضف نظام "extend session" لأن المتطلب كان واضحاً

3. **الفحص يحدث محلياً**
   - لا علاقة بـ Server أو Database
   - كل التحقق يحدث على جهاز المستخدم

4. **Timer يتم إيقافه عند مغادرة الشاشة**
   - لا يوجد استهلاك للموارد في الخلفية

---

## 📞 الدعم والتخصيص

إذا أردت:
- **تغيير مدة الجلسة** → عدّل `sessionTimeoutMinutes` في `AuthService.dart`
- **تغيير وقت التحذير** → عدّل `isSessionAboutToExpire()` في `AuthService.dart`
- **تغيير فترة الفحص** → عدّل `Timer.periodic` في `TimetableWidgt.dart`

---

## 🎓 خلاصة تقنية

**النمط المستخدم:** Singleton Pattern
- `AuthService` يستخدم Singleton للحفاظ على جلسة واحدة فقط

**الحساب المستخدم:** DateTime Difference
- `DateTime.now().difference(loginTime).inMinutes`

**الآلية:** Observer Pattern + Timer
- Timer يلاحظ التغييرات كل دقيقة
- يُبلغ عنها للـ UI

---

**تم الإنجاز بنجاح ✨**
