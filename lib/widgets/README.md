# 🎨 مجلد الواجهات - Widgets Documentation

## 📖 نظرة عامة
يحتوي هذا المجلد على جميع مكونات الواجهة (Widgets) المستخدمة في النظام.

---

## 📁 محتويات المجلد

### الواجهات الأساسية

#### 1. **ClinicSwitcher.dart** - تبديل العيادات
- **الوصف:** واجهات للتنقل السريع بين العيادات
- **الملف:** [README_ClinicSwitcher.md](README_ClinicSwitcher.md)
- **المميزات:**
  - عرض أيقونة
  - عرض مفصل
  - تنقل سريع
  - تحديث تلقائي

#### 2. **AppDrawer.dart** - القائمة الجانبية
- **الوصف:** القائمة الرئيسية للتنقل
- **المميزات:**
  - عرض الملف الشخصي
  - قاائمة الخيارات
  - تبديل العيادات
  - تسجيل الخروج

#### 3. **AnimatedCard.dart** - بطاقة متحركة
- **الوصف:** بطاقة مع رسوميات متحركة
- **المميزات:**
  - دخول سلس
  - تأثيرات زمنية
  - تفاعل سلس

#### 4. **PageTransition.dart** - انتقالات الصفحات
- **الوصف:** تأثيرات الانتقال بين الصفحات
- **المميزات:**
  - انزلاق جانبي
  - تلاشي سلس
  - مدة قابلة للتخصيص

---

## 📂 الواجهات المتقدمة

### واجهات المستخدم الرئيسية

#### الصفحات (Pages)
```
lib/pages/
├─ auth/                 (المصادقة)
│  ├─ login_page.dart
│  └─ user_management_page.dart
├─ accounting/           (المحاسبة)
│  ├─ invoices/
│  ├─ journals/
│  └─ vouchers/
├─ costumer/             (المرضى)
│  ├─ PageCostumers.dart
│  ├─ PageAddCostumers.dart
│  └─ PageEditCostumers.dart
├─ employment/           (الموظفين)
│  └─ PageEmployees.dart
├─ reports/              (التقارير)
│  └─ PageItemReport.dart
└─ settings/             (الإعدادات)
   └─ DbSettingsPage.dart
```

#### مكونات مساعدة
```
lib/widgets/
├─ ClinicSwitcher.dart       ✨ جديد
├─ AppDrawer.dart
├─ AnimatedCard.dart
├─ PageTransition.dart
└─ ...
```

---

## 🎨 تصميم الواجهات

### نظام الألوان
```dart
primaryColor: Color(0xFF1D9D99)    // أخضر عميق
accentColor: Color(0xFF167774)     // أخضر متوسط
backgroundColor: Colors.white       // أبيض
errorColor: Colors.red              // أحمر
```

### محاذاة RTL
جميع الواجهات تدعم العربية من اليمين لليسار:
```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: widget,
)
```

---

## 💡 أمثلة الاستخدام

### إضافة ClinicSwitcher
```dart
ClinicSwitcher(
  showAsIcon: true,
  onClinicChanged: () {
    reloadAllData();
  },
)
```

### استخدام PageTransition
```dart
Navigator.of(context).push(
  PageTransition(child: NewPage()),
);
```

### فتح AppDrawer
```dart
Scaffold(
  drawer: const AppDrawer(),
  body: ...,
)
```

---

## 🎯 هيكل الواجهة الرئيسية

```
App
├─ LoginPage
│  └─ AuthService
├─ TimetableWidgt (الرئيسية)
│  ├─ AppDrawer
│  │  ├─ ClinicSwitcher ✨
│  │  └─ تفاصيل المستخدم
│  ├─ AppBar
│  └─ Body
│     └─ NavigationPages
└─ ErrorPages
```

---

## 📊 جدول الواجهات الأساسية

| الواجهة | الملف | الوصف |
|--------|-------|---------|
| ClinicSwitcher | ClinicSwitcher.dart | تبديل العيادات |
| AppDrawer | AppDrawer.dart | القائمة الجانبية |
| AnimatedCard | AnimatedCard.dart | بطاقة متحركة |
| PageTransition | PageTransition.dart | تأثير الانتقال |

---

## 🔄 التفاعل مع الخدمات

```
Widget (الواجهة)
    ↓
Service (الخدمة)
    ↓
Model (النموذج)
    ↓
Database (قاعدة البيانات)
```

---

## ⚙️ خصائص الواجهات المختلفة

### StatelessWidget
```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) => ...;
}
```

### StatefulWidget
```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
  
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) => ...;
}
```

---

## 🎨 تخصيص الواجهات

### تغيير الألوان
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: Colors.white,
  ),
  child: const Text('زر'),
)
```

### تغيير الخطوط
```dart
Text(
  'نص عربي',
  style: TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
)
```

---

## 🚀 أفضل الممارسات

1. **استخدم Constants** - للألوان والأحجام
2. **فصل المنطق** - ضع المنطق في ViewModel
3. **معالج الأخطاء** - استخدم try-catch
4. **حالات التحميل** - أظهر مؤشر تقدم
5. **التجاوب** - اختبر على أحجام مختلفة

---

## 📝 ملفات التوثيق الموجودة

| الملف | الموضوع |
|-------|----------|
| [README_ClinicSwitcher.md](README_ClinicSwitcher.md) | تبديل العيادات |

---

## 🔍 الأداء

| العملية | الوقت |
|--------|-------|
| بناء واجهة | < 50ms |
| الانتقال | < 300ms |
| التحديث | فوري |

---

**المجلد:** `lib/widgets/`  
**الحالة:** ✅ منظم وموثق  
**عدد الواجهات:** 10+ واجهات
