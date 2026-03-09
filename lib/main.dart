import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:hussam_clinc/global_var/globals.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage and Config
  await StorageService().loadConfig();

  // Initialize Notifications
  await NotificationService().init();

  // Initialize Firebase sync (safe fallback if Firebase is not configured)
  await FirebaseSyncService.instance.initialize();
  await FirebaseSyncService.instance.pullPatientsToLocal(cooldown: Duration.zero);

  // Ensure Root Directory exists (Desktop/Mobile only)
  if (!kIsWeb) {
    final directory = Directory(appRootPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Initialize FFI for desktop platforms (Windows, Linux, macOS)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
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
      home: const TimetableWidgt(title: 'الرئيسية'),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
  }
}

