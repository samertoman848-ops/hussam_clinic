import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/View_model/ViewModelGlobal.dart';
import 'package:hussam_clinc/data/TimetableWidgt.dart';
import 'package:hussam_clinc/model/Employment/EmployeeModel.dart';
import 'package:hussam_clinc/model/accounting/AccoutingTreeModel.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesModel.dart';
import 'package:hussam_clinc/model/accounting/journals/IndexModel.dart';
import 'package:hussam_clinc/model/accounting/journals/journalsModel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'model/DatesModel.dart';
import 'model/patients/PatientModel.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import 'package:hussam_clinc/services/notification_service.dart';
import 'package:hussam_clinc/services/StorageService.dart';
import 'package:hussam_clinc/services/firebase_sync_service.dart';
import 'package:hussam_clinc/services/BackupService.dart';
import 'package:hussam_clinc/global_var/globals.dart';
import 'package:hussam_clinc/pages/auth/login_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

List<DateTime> DatesListUniq = [];
List<DateModel> DatesList = [];
List<DateModel> allDatesList = [];

/// Accounting Data
List<AccoutingTreeModel> allAccountingTree = [];
List<String> allAccountingTreeGroup = [];
List<IndexModel> allAccountingIndex = [];
List<String> allAccountingIndex_s = [];

List<AccoutingTreeModel> allAccountingCoustmers = [];
List<String> allAccountingCoustmers_s = [];

List<AccoutingTreeModel> allAccountingSuppliers = [];
List<String> allAccountingSuppliers_s = [];

List<AccoutingTreeModel> allAccountingEmployees = [];
List<String> allAccountingEmployees_s = [];

List<String> allAccountingContens = [];
String AccountingIndx_select_id = 'o';
IndexModel AccountingIndexModel = IndexModel.name();

List<PatientModel> allPatient = [];
List<EmployeeModel> allEmployees = [];
List<InvoicesModel> allInvoices = [];
List<InvoicesModel> expenseInvoices = [];
List<JournalsModel> allJournals = [];

String maxNoPic = '1';
String MaxFiledNo = '1';

String selected_event_id = '';
DateModel selected_event_Model = _DateModel.empty();
var VMGlobal = ViewModelGlobal();

class _DateModel extends DateModel {
  _DateModel.empty()
      : super({
          "date_id": 0,
          "date_kind": 'مواعيد المرضى',
          "date_place": "غرفة 1",
          "date_dateStart": DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).toString(),
          "date_dateEnd": DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).toString(),
          "date_note": '',
          "date_doctorId": '',
          "date_doctorName": '',
          "date_costumerId": '',
          "date_costumerName": '',
        });
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Suppress MissingPluginException for sensors on Windows
    if (!kIsWeb && Platform.isWindows) {
      // Catch synchronous errors (like build methods)
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        final exceptionStr = details.exception.toString();
        if (exceptionStr.contains('MissingPluginException') &&
            (exceptionStr.contains('sensors') ||
                exceptionStr.contains('accelerometer'))) {
          debugPrint(
              'Suppressed expected MissingPluginException for sensors on Windows');
          return;
        }
        originalOnError?.call(details);
      };

      // Catch asynchronous/platform errors
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        final errorStr = error.toString();
        if (errorStr.contains('MissingPluginException') &&
            (errorStr.contains('sensors') ||
                errorStr.contains('accelerometer'))) {
          debugPrint('Suppressed unhandled sensors exception on Windows');
          return true; // Error is handled
        }
        return false; // Let the error fall through
      };
    }

    // Initialize FFI for desktop platforms (Windows, Linux, macOS) as early as possible
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }

    // Initialize Storage and Config (loads appRootPath)
    await StorageService().loadConfig();
    
    // Initialize Backup Config
    await BackupService().loadConfig();
    await BackupService().checkAutoBackup();

    // Ensure Root Directory exists (Desktop/Mobile only)
    if (!kIsWeb) {
      final directory = Directory(appRootPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
    }

    // Initialize Notifications in background (Non-blocking)
    NotificationService().init().catchError((e) {
      debugPrint('Notification background init error: $e');
    });

    // Initialize Firebase sync in the background (Non-blocking)
    FirebaseSyncService.instance.initialize().then((_) {
      FirebaseSyncService.instance
          .pullPatientsToLocal(cooldown: Duration.zero)
          .catchError((e) {
        debugPrint('Post-init pull error: $e');
      });
    }).catchError((e) {
      debugPrint('Firebase background init error: $e');
    });
  } catch (e) {
    debugPrint('Critical initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),
      home: const LoginPage(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}
