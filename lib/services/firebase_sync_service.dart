import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/patients/dbpatient.dart';
import 'package:hussam_clinc/db/patients/dbpatienthealth.dart';
import 'package:hussam_clinc/db/patients/dbtreatmentplans.dart';
import 'package:hussam_clinc/db/accounting/invoices/dbinvoices.dart';
import 'package:hussam_clinc/db/accounting/invoices/dbinvoicedetails.dart';
import 'package:hussam_clinc/db/dbdate.dart';
import 'package:hussam_clinc/db/dbemployee.dart';
import 'package:hussam_clinc/db/dbrooms.dart';
import 'package:hussam_clinc/model/patients/PatientModel.dart';
import 'package:hussam_clinc/model/patients/PatientHealthModel.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesModel.dart';
import 'package:hussam_clinc/model/accounting/invoices/InvoicesDetailModel.dart';
import 'package:hussam_clinc/model/patients/TreatmentPlanModel.dart';
import 'package:hussam_clinc/model/DatesModel.dart';
import 'package:hussam_clinc/model/Employment/EmployeeModel.dart';
import 'package:hussam_clinc/model/RoomModel.dart';
import 'package:hussam_clinc/firebase_options.dart';
import 'package:hussam_clinc/services/ClinicService.dart';
import 'package:hussam_clinc/db/dbhelper.dart';
import 'package:hussam_clinc/global_var/globals.dart';

class FirebaseSyncService {
  FirebaseSyncService._();

  static final FirebaseSyncService instance = FirebaseSyncService._();

  bool _initialized = false;
  bool _enabled = false;
  bool _isPulling = false;
  DateTime? _lastPullAt;

  bool get isEnabled => _enabled;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!kIsWeb) {
      // For mobile/desktop, we check Platform
      if (!Platform.isWindows && !Platform.isAndroid && !Platform.isIOS) {
        _enabled = false;
        debugPrint('Firebase sync disabled for this platform.');
        return;
      }
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _enabled = true;
      debugPrint('Firebase initialized successfully (${kIsWeb ? "Web" : "Native"}).');
    } catch (e) {
      _enabled = false;
      debugPrint('Firebase init failed: $e');
    }
  }

  /// Generic sync method for any collection
  Future<void> syncData(String collection, String id, Map<String, dynamic> data, {String? clinicId}) async {
    if (!_enabled) return;

    try {
      // Adding common timestamp metadata
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['updatedAtMs'] = DateTime.now().millisecondsSinceEpoch;

      DocumentReference docRef;
      if (clinicId != null) {
        docRef = FirebaseFirestore.instance
            .collection('clinics')
            .doc(clinicId)
            .collection(collection)
            .doc(id);
      } else {
        docRef = FirebaseFirestore.instance
            .collection(collection)
            .doc(id);
      }

      await docRef.set(data, SetOptions(merge: true));
      // debugPrint('Data synced to Firestore: ${docRef.path}');
    } catch (e) {
      debugPrint('syncData error ($collection): $e');
    }
  }

  /// Handles the user's request for patients:
  /// Web -> Direct Firestore
  /// Desktop -> Push to Firestore (after local save)
  Future<void> syncPatient(PatientModel patient, {String? clinicId}) async {
    await syncData('patients', patient.id.toString(), _toFirestoreMap(patient), clinicId: clinicId);
  }

  Future<void> pushPatient(PatientModel patient, {String? clinicId}) async {
    await syncPatient(patient, clinicId: clinicId);
  }

  Future<void> syncPatientHealth(PatienHealthtModel health, {String? clinicId}) async {
    await syncData('patient_health', health.patientId, health.toMap(), clinicId: clinicId);
  }

  Future<void> pushPatientHealth(PatienHealthtModel health, {String? clinicId}) async {
    await syncPatientHealth(health, clinicId: clinicId);
  }

  Future<void> syncInvoice(InvoicesModel invoice, {String? clinicId}) async {
    await syncData('invoices', invoice.id.toString(), invoice.toMap(), clinicId: clinicId);
  }

  Future<void> pushInvoice(InvoicesModel invoice, {String? clinicId}) async {
    await syncInvoice(invoice, clinicId: clinicId);
  }

  Future<void> syncInvoiceDetail(InvoicesDetailModel detail, {String? clinicId}) async {
    // Nested collection for invoice details
    final path = 'invoices/${detail.invoices_id}/details';
    await syncData(path, detail.id.toString(), detail.toMap(), clinicId: clinicId);
  }

  Future<void> pushInvoiceDetail(InvoicesDetailModel detail, {String? clinicId}) async {
    await syncInvoiceDetail(detail, clinicId: clinicId);
  }

  Future<void> syncTreatmentPlan(TreatmentPlanModel plan, {String? clinicId}) async {
    await syncData('treatment_plans', plan.id.toString(), plan.toMap(), clinicId: clinicId);
  }

  Future<void> pushTreatmentPlan(TreatmentPlanModel plan, {String? clinicId}) async {
    await syncTreatmentPlan(plan, clinicId: clinicId);
  }

  Future<void> syncDate(DateModel date, {String? clinicId}) async {
    await syncData('dates', date.id.toString(), date.toMap(), clinicId: clinicId);
  }

  Future<void> pushDate(DateModel date, {String? clinicId}) async {
    await syncDate(date, clinicId: clinicId);
  }

  Future<void> syncEmployee(EmployeeModel emp, {String? clinicId}) async {
    await syncData('employees', emp.id.toString(), emp.toMap(), clinicId: clinicId);
  }

  Future<void> pushEmployee(EmployeeModel emp, {String? clinicId}) async {
    await syncEmployee(emp, clinicId: clinicId);
  }

  Future<void> syncRoom(RoomModel room, {String? clinicId}) async {
    await syncData('rooms', room.id.toString(), room.toMap(), clinicId: clinicId);
  }

  Future<void> pushRoom(RoomModel room, {String? clinicId}) async {
    await syncRoom(room, clinicId: clinicId);
  }

  /// Migrates all data from all clinics to Firebase.
  Future<void> syncAllClinicsToFirebase() async {
    if (!_enabled) {
      await initialize();
      if (!_enabled) return;
    }

    final originalDbName = selectedDbName;
    debugPrint('Starting MULTI-CLINIC sync to Firebase...');

    try {
      final clinicService = ClinicService();
      await clinicService.loadClinics();
      final allClinics = clinicService.clinics;

      for (final clinic in allClinics) {
        final clinicId = clinic.name.toLowerCase().replaceAll(' ', '_');
        debugPrint('--- Syncing Clinic: ${clinic.name} ($clinicId) ---');

        // 1. Switch to this clinic via DbHelper (without affecting StorageService if possible, 
        // but here we use the safe way by closing and reopening)
        await DbHelper().closeDB();
        selectedDbName = clinic.dbFileName;
        await DbHelper().openDb();

        // 2. Upload Metadata for this clinic
        await FirebaseFirestore.instance.collection('clinics').doc(clinicId).set({
          'name': clinic.name,
          'dbFileName': clinic.dbFileName,
          'lastSyncAt': FieldValue.serverTimestamp(),
          'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));

        // 3. Upload all tables for THIS clinic
        await _uploadCurrentDatabaseToFirebase(clinicId);
      }

      debugPrint('✅ Multi-clinic sync completed successfully!');
    } catch (e) {
      debugPrint('❌ Multi-clinic sync error: $e');
    } finally {
      // Revert to original database
      if (selectedDbName != originalDbName) {
        await DbHelper().closeDB();
        selectedDbName = originalDbName;
        await DbHelper().openDb();
      }
    }
  }

  Future<void> _uploadCurrentDatabaseToFirebase(String clinicId) async {
    try {
      // 1. Patients
      final patients = await DbPatient().allPatients();
      for (final p in patients) {
        await pushPatient(p, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${patients.length} patients.');

      // 2. Patient Health
      final healthRecords = await DbPatientHealth().allPHs();
      for (final h in healthRecords) {
        await pushPatientHealth(h, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${healthRecords.length} health records.');

      // 3. Invoices
      final invoices = await DbInvoices().getAllInvoices();
      for (final inv in invoices) {
        await pushInvoice(inv, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${invoices.length} invoices.');

      // 4. Invoice Details
      final details = await DbInvoicesDetails().getAllInvoicesDetails();
      for (final d in details) {
        await pushInvoiceDetail(d, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${details.length} invoice details.');

      // 5. Treatment Plans
      final plans = await DbTreatmentPlans().getAllTreatmentPlans();
      for (final plan in plans) {
        await pushTreatmentPlan(plan, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${plans.length} treatment plans.');

      // 6. Dates (Appointments)
      final dates = await DbDate().alldate();
      for (final date in dates) {
        await pushDate(date, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${dates.length} appointments.');

      // 7. Employees
      final emps = await DbEmployee().allEmployeesModel();
      for (final emp in emps) {
        await pushEmployee(emp, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${emps.length} employees.');

      // 8. Rooms
      final rooms = await DbRooms().allRooms();
      for (final room in rooms) {
        await pushRoom(room, clinicId: clinicId);
      }
      debugPrint('[$clinicId] Synced ${rooms.length} rooms.');
    } catch (e) {
      debugPrint('Error syncing database $clinicId: $e');
    }
  }

  /// Migrates all local data to Firebase Cloud.
  /// (Deprecated/Legacy: Use syncAllClinicsToFirebase instead)
  Future<void> uploadAllDataToFirebase() async {
    await syncAllClinicsToFirebase();
  }

  Future<void> pullPatientsToLocal({Duration cooldown = const Duration(seconds: 45)}) async {
    if (!_enabled || _isPulling) return;

    final now = DateTime.now();
    if (_lastPullAt != null && now.difference(_lastPullAt!) < cooldown) {
      return;
    }

    _isPulling = true;
    _lastPullAt = now;

    try {
      final snap = await FirebaseFirestore.instance.collection('patients').get();
      if (snap.docs.isEmpty) return;

      final dbPatient = DbPatient();
      for (final doc in snap.docs) {
        final mapped = fromFirestoreMap(doc.id, doc.data());
        await dbPatient.upsertPatientFromCloud(mapped);
      }
    } catch (e) {
      debugPrint('pullPatientsToLocal error: $e');
    } finally {
      _isPulling = false;
    }
  }

  Map<String, dynamic> _toFirestoreMap(PatientModel p) {
    return <String, dynamic>{
      'patient_id': p.id,
      'patient_Name': p.name,
      'patient_mobile': p.mobile,
      'patient_mobile2': p.mobile2,
      'patient_sex': p.sex,
      'patient_status': p.status,
      'patient_birthDay': p.birthDay,
      'patient_age': p.age,
      'patient_fileNo': p.fileNo,
      'patient_Address': p.address,
      'patient_resone': p.resone,
      'patient_worries': p.worries,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
  }

  PatientModel fromFirestoreMap(String docId, Map<String, dynamic> data) {
    int parsedId = int.tryParse((data['patient_id'] ?? docId).toString()) ?? 0;
    if (parsedId == 0) {
      parsedId = int.tryParse(docId) ?? DateTime.now().millisecondsSinceEpoch;
    }

    final row = <String, dynamic>{
      'patient_id': parsedId,
      'patient_Name': (data['patient_Name'] ?? '').toString(),
      'patient_mobile': (data['patient_mobile'] ?? '').toString(),
      'patient_mobile2': (data['patient_mobile2'] ?? '').toString(),
      'patient_Address': (data['patient_Address'] ?? '').toString(),
      'patient_sex': (data['patient_sex'] ?? '').toString(),
      'patient_age': (data['patient_age'] ?? '').toString(),
      'patient_fileNo': (data['patient_fileNo'] ?? '').toString(),
      'patient_resone': (data['patient_resone'] ?? '').toString(),
      'patient_worries': (data['patient_worries'] ?? '').toString(),
      'patient_status': (data['patient_status'] ?? '').toString(),
      'patient_birthDay': (data['patient_birthDay'] ?? '').toString(),
    };

    return PatientModel.fromMap(row);
  }
}
