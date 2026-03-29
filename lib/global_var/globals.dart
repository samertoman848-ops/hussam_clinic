library;

import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/accounting/dbindex.dart';
import 'package:hussam_clinc/db/accounting/dbtree.dart';
import 'package:hussam_clinc/db/accounting/journal/dbjournals.dart';
import 'package:hussam_clinc/db/dbemployee.dart';
import 'package:hussam_clinc/model/accounting/AccoutingTreeModel.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesModel.dart';
import '../db/accounting/invoices/dbinvoices.dart';
import '../db/patients/dbpatient.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;

String _overrideRootPath = "";
String _overrideDbName = "A-ناصر.db";

// Helper getter for config file path, moved outside appRootPath
String get _configFilePath {
  if (kIsWeb) return ''; // No config file path on web
  return p.join(
      Platform.environment['APPDATA'] ?? '.', 'hussam', 'root_path.txt');
}

String get appRootPath {
  if (kIsWeb) return 'hussam_web_data';
  if (_overrideRootPath.isNotEmpty) return _overrideRootPath;
  // Check for Windows platform only if not on web
  if (!kIsWeb && Platform.isWindows) {
    return '${Platform.environment['APPDATA']}/hussam';
  } else if (!kIsWeb) {
    // This else branch is for non-Windows, non-web platforms (e.g., Android)
    return "/storage/emulated/0/HussamClinc";
  }
  // Fallback for web if somehow reached here, though kIsWeb check should handle it
  return 'hussam_web_data';
}

set appRootPath(String newPath) {
  _overrideRootPath = newPath;
}

String get selectedDbName => _overrideDbName;
set selectedDbName(String newName) {
  _overrideDbName = newName;
}

String get extFolder => appRootPath;
String get extPicFolder => p.join(appRootPath, 'pic', p.basenameWithoutExtension(selectedDbName));
String get extDbFolder => "$appRootPath/db";
String get extFilesFolder => "$appRootPath/files";
String get extFilesReports => "$appRootPath/reports";

Future<void> savePDFFile(List<int> bytes, String fileName) async {
  final directory = Directory(extFilesReports);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final fullPath = '${directory.path}/$fileName';
  final file = File(fullPath);
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open(fullPath);
}

Future<String> saveImageFile(List<int> bytes, String fileName) async {
  final directory = Directory(extFilesReports);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final fullPath = '${directory.path}/$fileName';
  final file = File(fullPath);
  await file.writeAsBytes(bytes, flush: true);
  return fullPath;
}

final Map<int, Color> colorMapper = {
  0: Colors.green,
  1: Colors.blue,
  2: Colors.blueGrey[600]!,
  3: Colors.grey,
  4: Colors.blueGrey[50]!,
  5: Colors.blueGrey[400]!,
  6: Colors.blueGrey[500]!,
  7: Colors.blueGrey[600]!,
  8: Colors.blueGrey[700]!,
  9: Colors.green,
  10: Colors.green,
};

extension ColorUtil on Color {
  Color byLuminance() =>
      computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
}

Future<void> AllPatientList() async {
  DbPatient dbPatient = DbPatient();
  final patients = await dbPatient.allPatients();
  allPatient.clear();
  allPatient.addAll(patients);
  await dbPatient.MaxFileNo();
}

Future<void> AllAccountingTreeList() async {
  try {
    DbTree dbTree = DbTree();
    final trees = await dbTree.allAccountingTree();
    allAccountingTree.clear();
    allAccountingTree.addAll(trees);
  } catch (e) {
    print('Error loading accounting tree: $e');
  }
}

Future<void> AllAccountingTreeGroup() async {
  try {
    allAccountingTreeGroup.clear();
    DbTree dbTree = DbTree();
    final trees = await dbTree.allAccountingTreeGrouping();
    for (var tree in trees) {
      if (tree.father_no.isNotEmpty) {
        allAccountingTreeGroup.add(tree.father_no);
      }
    }
  } catch (e) {
    print('Error loading accounting tree group: $e');
  }
}

Future<void> AllAccountingIndexList() async {
  try {
    DbIndex dbIndex = DbIndex();
    final indexes = await dbIndex.allAccountingIndexes();
    allAccountingIndex.clear();
    allAccountingIndex_s.clear();
    for (var index in indexes) {
      allAccountingIndex.add(index);
      allAccountingIndex_s.add(index.name);
    }
  } catch (e) {
    print('Error loading accounting indexes: $e');
  }
}

Future<void> AllEmployeeTreeList() async {
  try {
    DbTree dbTree = DbTree();
    final trees = await dbTree.allEmployeeAccounting();
    allAccountingEmployees.clear();
    allAccountingEmployees_s.clear();
    for (var tree in trees) {
      allAccountingEmployees.add(tree);
      if (tree.name.isNotEmpty) {
        allAccountingEmployees_s.add(tree.name);
      }
    }
  } catch (e) {
    print('Error loading employee tree: $e');
  }
}

Future<void> AllPaitentsTreeList() async {
  try {
    // جرب تحميل المرضى مباشرة من جدول patients
    DbPatient dbPatient = DbPatient();
    final patients = await dbPatient.allPatients();

    allAccountingCoustmers.clear();
    allAccountingCoustmers_s.clear();

    if (patients.isNotEmpty) {
      // إذا وجدنا المرضى في جدول patients، استخدمها
      for (var patient in patients) {
        AccoutingTreeModel tree = AccoutingTreeModel.Valueed(
          patient.id,
          patient.name,
          patient.fileNo, // Use fileNo as account number
          '5200', // رقم حساب المرضى في الحسابات
          patient.fileNo, // Use fileNo as original ID
        );
        allAccountingCoustmers.add(tree);
        if (patient.name.isNotEmpty) {
          allAccountingCoustmers_s.add(patient.name);
        }
      }
      print(
          'تم تحميل ${allAccountingCoustmers_s.length} اسم مريض من جدول patients');
    } else {
      // إذا لم نجد في patient، جرب جدول all_Paitents_Acounting
      DbTree dbTree = DbTree();
      final trees = await dbTree.allPaitentsAccounting();

      for (var tree in trees) {
        allAccountingCoustmers.add(tree);
        if (tree.name.isNotEmpty) {
          allAccountingCoustmers_s.add(tree.name);
        }
      }
      print(
          'تم تحميل ${allAccountingCoustmers_s.length} اسم مريض من جدول all_Paitents_Acounting');
    }
  } catch (e) {
    print('Error loading patients tree: $e');
  }
}

Future<void> AllSuppliersTreeList() async {
  try {
    DbTree dbTree = DbTree();
    final trees = await dbTree.allSuppliersAccounting();
    allAccountingSuppliers.clear();
    allAccountingSuppliers_s.clear();
    for (var tree in trees) {
      allAccountingSuppliers.add(tree);
      if (tree.name.isNotEmpty) {
        allAccountingSuppliers_s.add(tree.name);
      }
    }
  } catch (e) {
    print('Error loading suppliers tree: $e');
  }
}

Future<void> AllEmplyess() async {
  DbEmployee dbEmployee = DbEmployee();
  final employees = await dbEmployee.allEmployeesModel();
  allEmployees.clear();
  allEmployees.addAll(employees);
}

Future<void> AllInvioces() async {
  try {
    DbInvoices dbInvoices = DbInvoices();
    final invoices = await dbInvoices.allInvioces();

    // Deduplicate by ID to prevent UI glitches
    final Map<int, InvoicesModel> unique = {};
    for (var inv in invoices) {
      unique[inv.id] = inv;
    }

    allInvoices.clear();
    allInvoices.addAll(unique.values);
  } catch (e) {
    print('Error loading invoices: $e');
  }
}

Future<void> ExpenseInvioces() async {
  try {
    DbInvoices dbInvoices = DbInvoices();
    final invoices = await dbInvoices.expenseInvioces();

    final Map<int, InvoicesModel> unique = {};
    for (var inv in invoices) {
      unique[inv.id] = inv;
    }

    expenseInvoices.clear();
    expenseInvoices.addAll(unique.values);
  } catch (e) {
    print('Error loading expense invoices: $e');
  }
}

Future<void> Journals() async {
  try {
    DbJournals dbJournals = DbJournals();
    final journals = await dbJournals.allJournals();
    allJournals.clear();
    allJournals.addAll(journals);
  } catch (e) {
    print('Error loading journals: $e');
  }
}

Future<void> reloadAllData() async {
  await AllPatientList();
  await AllAccountingTreeList();
  await AllAccountingTreeGroup();
  await AllAccountingIndexList();
  await AllEmployeeTreeList();
  await AllPaitentsTreeList();
  await AllSuppliersTreeList();
  await AllEmplyess();
  await AllInvioces();
  await ExpenseInvioces();
  await Journals();
}

// These are now handled by getters above
// const extFolder = "/storage/emulated/0/HussamClinc";
// const extDbFolder = "/storage/emulated/0/HussamClinc/db";
// const extPicFolder = "/storage/emulated/0/HussamClinc/pic";
// const extFilesFolder = "/storage/emulated/0/HussamClinc/files";
// const extFilesReports = "/storage/emulated/0/HussamClinc/reports";

Future<void> copyExternalDB() async {
  String FileName = 'db';
  DateTime TodayNow = DateTime.now();

  // Only attempt Android-style external DB copy on Android.
  // On desktop platforms the packaged assets are used directly.
  if (!Platform.isAndroid) {
    print('Not Android platform, skipping copyExternalDB');
    return;
  }

  try {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "db.db");

    bool exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "db.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
      print('Database copied successfully');
    }

    // Only proceed with external storage backup on Android
    if (TodayNow.day % 8 == 0) {
      FileName = 'Remain_00';
    } else if (TodayNow.day % 8 == 1) {
      FileName = 'Remain_01';
    } else if (TodayNow.day % 8 == 2) {
      FileName = 'Remain_02';
    } else if (TodayNow.day % 8 == 3) {
      FileName = 'Remain_03';
    } else if (TodayNow.day % 8 == 4) {
      FileName = 'Remain_04';
    } else if (TodayNow.day % 8 == 5) {
      FileName = 'Remain_05';
    } else if (TodayNow.day % 8 == 6) {
      FileName = 'Remain_06';
    } else if (TodayNow.day % 8 == 7) {
      FileName = 'Remain_07';
    } else {
      FileName = 'Remain_08';
    }

    if (TodayNow.hour >= 9 && TodayNow.hour < 10) {
      FileName = '${FileName}_Time01';
    } else if (TodayNow.hour <= 10) {
      FileName = '${FileName}_Time02';
    } else if (TodayNow.hour <= 11) {
      FileName = '${FileName}_Time03';
    } else if (TodayNow.hour <= 13) {
      FileName = '${FileName}_Time04';
    } else if (TodayNow.hour <= 15) {
      FileName = '${FileName}Time05';
    } else if (TodayNow.hour <= 17) {
      FileName = '${FileName}_Time06';
    } else if (TodayNow.hour <= 18) {
      FileName = '${FileName}_Time07';
    } else if (TodayNow.hour <= 19) {
      FileName = '${FileName}_Time08';
    } else if (TodayNow.hour <= 20) {
      FileName = '${FileName}_Time09';
    } else if (TodayNow.hour <= 21) {
      FileName = '${FileName}_Time10';
    } else {
      FileName = '${FileName}_Time11';
    }

    // Backup DB to external storage if permissions granted
    try {
      File sourceDb = File(path);
      File copyTo = File('/storage/emulated/0/HussamClinc/db/$FileName.db');

      PermissionStatus status =
          await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        List<int> content = await sourceDb.readAsBytes();
        // Create parent directory if it doesn't exist
        Directory parentDir = Directory(copyTo.parent.path);
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }
        await copyTo.writeAsBytes(content, flush: true);
        print('Database backed up to external storage');
      }
    } catch (e) {
      print('Error backing up to external storage: $e');
    }
  } catch (e) {
    print('copyExternalDB error: $e');
  }
}

void creatExtFolder(String folderName) async {
  creatExtMainFolder();
  Directory path = Directory("$extFolder/$folderName");
  if ((await path.exists())) {
    print("exists file ");
  } else {
    PermissionStatus status2 = await Permission.manageExternalStorage.request();
    if (status2.isGranted) {
      path.createSync();
    }
  }
}

void creatExtMainFolder() async {
  Directory path = Directory(extFolder);
  if ((await path.exists())) {
    print("exists file ");
  } else {
    PermissionStatus status2 = await Permission.manageExternalStorage.request();
    if (status2.isGranted) {
      path.createSync();
    }
  }
}
