import 'package:flutter/material.dart';
import 'dart:async';
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
import '../services/AuthService.dart';
import '../pages/auth/login_page.dart';
import '../services/ClinicService.dart';
import '../widgets/ClinicSwitcher.dart';

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
  late Timer _sessionCheckTimer;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    // // Initialize FFI
    // sqfliteFfiInit();
    // databaseFactory = databaseFactoryFfi;
    helper = DbHelper();
    dbDates = DbDate();

    // Start session check timer - check every minute
    _sessionCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkSessionExpiry();
    });

    // Also check immediately
    _checkSessionExpiry();

    _initializeApp();
  }

  void _checkSessionExpiry() {
    final authService = AuthService();

    // Check if session has expired
    if (!authService.isAuthenticated) {
      _sessionCheckTimer.cancel();

      if (mounted) {
        // Show timeout dialog and redirect to login
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('انتهت جلسة العمل'),
              content:
                  const Text('لقد انتهت مدة جلستك، يرجى تسجيل الدخول مجدداً'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: const Text('تسجيل الدخول'),
                )
              ],
            );
          },
        );
      }
    } else if (authService.isSessionAboutToExpire()) {
      // Show warning if less than 10 minutes remaining
      final remainingMinutes = authService.getSessionRemainingMinutes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تحذير: سينتهي وقت جلستك خلال $remainingMinutes دقائق'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _sessionCheckTimer.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    if (mounted) setState(() => _isReloading = true);
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
      await Future.delayed(const Duration(milliseconds: 200));

      // Reload all data - this will use the current selectedDbName
      await reloadAllData();

      /// Load base dates data
      final datesList = await dbDates.GroupDates();

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
    } finally {
      if (mounted) setState(() => _isReloading = false);
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
    if (_isReloading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'جاري تحميل بيانات عيادة ${ClinicService().currentClinicName}...',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title),
            Text(
              'العيادة: ${ClinicService().currentClinicName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          QuickClinicNavigation(
            onClinicChanged: () {
              _initializeApp();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        onClinicChanged: () {
          _initializeApp();
        },
      ),
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
