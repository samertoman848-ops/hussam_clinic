import 'package:flutter/material.dart';

import 'package:hussam_clinc/data/TimetableExample.dart';
import 'package:hussam_clinc/data/positioning_demo.dart';
import 'package:hussam_clinc/data/utils.dart';

import 'package:hussam_clinc/model/DatesModel.dart';
import '../db/dbdate.dart';
import '../db/dbhelper.dart';
import '../db/patients/dbpatient.dart';

import '../global_var/globals.dart';
import '../main.dart';
import '../widgets/app_drawer.dart';

class TimetableWidgt extends StatefulWidget {
  const TimetableWidgt({super.key, required this.title});
  final String title;
  @override
  State<StatefulWidget> createState() => TimetableWidgtState();
}

final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

class TimetableWidgtState extends State<TimetableWidgt> {
  late DbHelper helper;
  late DbDate dbDates;

  @override
  void initState() {
    super.initState();
    // // Initialize FFI
    // sqfliteFfiInit();
    // databaseFactory = databaseFactoryFfi;
    helper = DbHelper();
    dbDates = DbDate();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Create folders first
      await Future.wait([
        Future(() => creatExtFolder("db")),
        Future(() => creatExtFolder("pic")),
        Future(() => creatExtFolder("files")),
        Future(() => creatExtFolder("reports")),
      ]);

      // Copy database and wait for completion
      await copyExternalDB();

      // Give database a moment to initialize
      await Future.delayed(const Duration(milliseconds: 500));

      // Load all data after database is ready
      await AllPatientList();

      /// create list Acoounting Persons
      await AllAccountingTreeList();
      await AllAccountingTreeGroup();
      await AllSuppliersTreeList();
      await AllEmployeeTreeList();
      await AllPaitentsTreeList();

      /// create list  Indexes
      await AllAccountingIndexList();

      /// Load base dates data
      final datesList = await dbDates.GroupDates();

      /// Load invoices, etc
      await AllInvioces();
      await VMGlobal.MaxNoS();

      if (mounted) {
        setState(() {
          DatesList = datesList;
        });
      }
    } catch (e) {
      print('Error during app initialization: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    }
  }

  Future<void> AllPatientList() async {
    allPatient.clear();
    DbPatient dbPatient = DbPatient();
    final patients = await dbPatient.allPatients();
    if (mounted) {
      setState(() {
        allPatient.addAll(patients);
      });
    }
    await dbPatient.MaxFileNo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: const AppDrawer(),
      body: userWidget(),
    );
  }

  Widget userWidget() {
    DatesListUniq.clear();
    allDatesList.clear();

    return FutureBuilder(
      future: dbDates.alldate(),
      builder: (BuildContext context, AsyncSnapshot<List<DateModel>> snapshot) {
        if (snapshot.hasData) {
          // Data is now managed globally by TimetableExample's SetDateList which is more robust
          return ExampleApp(child: TimetableExample());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> refreshList() async {
    if (mounted) {
      setState(() {
        DatesListUniq.clear();
        DatesList.clear();
        allDatesList.clear();
        positioningDemoEvents.clear();
      });
    }
  }
}
