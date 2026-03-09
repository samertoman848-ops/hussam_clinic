# تشغيل تطبيق Hussam Clinic Flutter

## الطرق المتاحة لتشغيل التطبيق

### الطريقة 1: استخدام ملف Batch (الأسهل والأسرع)
انقر مرتين على الملف: `run_app.bat`

سيقوم هذا بـ:
1. تنظيف الحزم القديمة
2. تحميل التبعيات
3. بناء التطبيق
4. تشغيل التطبيق تلقائياً

---

### الطريقة 2: استخدام PowerShell Script

اتبع هذه الخطوات:

1. افتح PowerShell (كـ Administrator)
2. انسخ والصق هذا الأمر:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

3. ثم شغّل السكريبت:

```powershell
D:\programms\hussam\run_app.ps1
```

---

### الطريقة 3: تشغيل يدوي عبر Terminal

افتح PowerShell أو Command Prompt واكتب:

```powershell
cd D:\programms\hussam
flutter clean
flutter pub get
flutter build windows --release
.\build\windows\x64\runner\Release\hussam_clinc.exe
```

---

### الطريقة 4: تشغيل التطبيق مباشرة (إذا تم بناؤه سابقاً)

```powershell
D:\programms\hussam\build\windows\x64\runner\Release\hussam_clinc.exe
```

---

## معالجة المشاكل الشائعة

### المشكلة: التطبيق لا يعمل
**الحل:** شغّل `run_app.bat` أو اتبع الطريقة 3 أعلاه

### المشكلة: Cannot find flutter
**الحل:** تأكد من تثبيت Flutter صحيح واضافته إلى PATH

### المشكلة: Permission denied on PowerShell script
**الحل:** اتبع الخطوة الأولى من الطريقة 2 (Set-ExecutionPolicy)

---

## المتطلبات
- Flutter SDK مثبت
- Visual Studio C++ Build Tools (للبناء على Windows)
- 500MB من مساحة التخزين الحرة تقريباً

---

## ملاحظات إضافية
- التطبيق يتطلب Dart 3.0 أو أحدث
- أول تشغيل قد يستغرق 2-5 دقائق
- تأكد من وجود اتصال إنترنت لتحميل التبعيات
