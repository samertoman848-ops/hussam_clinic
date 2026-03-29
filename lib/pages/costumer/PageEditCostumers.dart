import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/db/patients/dbpatienthealthdoctor.dart';
import 'package:hussam_clinc/db/patients/dbpicture.dart';
import 'package:hussam_clinc/model/patients/PatientHealthDoctorModel.dart';
import 'package:intl/intl.dart' as tt;
import 'package:photo_view/photo_view.dart';
import '../../db/dbemployee.dart';
import '../../db/patients/dbpatient.dart';
import '../../db/patients/dbpatienthealth.dart';
import 'package:hussam_clinc/db/dbdate.dart';
import '../../db/patients/dbtreatmentplans.dart';
import '../../db/patients/dbinvoices.dart';
import '../../global_var/globals.dart';
import '../../main.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../model/patients/PatientModel.dart';
import '../../model/patients/TreatmentPlanModel.dart';
import '../../model/patients/InvoiceModel.dart';
import '../../model/DatesModel.dart';
import '../../dialog/dating_add_dialog.dart';
import '../../widgets/dental_chart.dart';
import '../accounting/invoices/SalesInvoices.dart';
import '../../View_model/ViewModelSalesInvoices.dart';
import '../../db/accounting/vouchers/dbvouchers.dart';
import '../../model/accounting/VoucherModel.dart';
import '../../db/accounting/journal/dbjournaldetails.dart';
import '../accounting/vouchers/receiptVoucher.dart';
import '../../db/accounting/invoices/dbinvoices.dart' as acc;
import '../../model/accounting/invoices/InvoicesModel.dart' as accModel;
import 'package:pluto_grid/pluto_grid.dart';
import '../../reports/reportSalesInvoicePDF.dart';
import '../../reports/reportVoucherPDF.dart';

class PageEditCostumers extends StatefulWidget {
  final PatientModel Patients;
  final int initialIndex;
  const PageEditCostumers(this.Patients, {super.key, this.initialIndex = 0});
  @override
  State<PageEditCostumers> createState() => _PageEditCostumersState();
}

DateTime projectStartDate = DateTime.now();

class _PageEditCostumersState extends State<PageEditCostumers> {
  List<PatienHealthtDoctorModel> allPHD = [];
  List<bool> PHD_edit = [];
  List<String> imageUrls = [];

  int paint_id = 1;
  var _patient_name, _patient_mobile, _patient_fileNo;
  var _patient_mobile2;
  var _patient_resone;
  var _patient_worries = "نعم";
  var _patient_place, _patient_sex = 'ذكر';
  String _patient_birthDate =
      '${projectStartDate.day}/${projectStartDate.month}/${projectStartDate.year}';

  var _patient_status = 'أعزب';
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  GlobalKey<FormState> formstate2 = GlobalKey<FormState>();
  GlobalKey<FormState> formstate3 = GlobalKey<FormState>();
  late List<GlobalObjectKey<FormState>> formstateList = List.generate(
      0, (int index) => GlobalObjectKey<FormState>(index),
      growable: true);
  final List<GlobalObjectKey<FormState>> formstateList2 = List.generate(
      5, (int index) => GlobalObjectKey<FormState>(index),
      growable: true);

  var costumer_sex_items = [
    "ذكر",
    "أنثى",
  ];
  var costumer_status_items = [
    "متزوج",
    "أعزب",
    "أرمل",
  ];
  var costumer_worries_items = [
    "نعم",
    "لا",
    "نوعا ما",
  ];
  var _patient_health;
  var _patient_sensitive = false, _patient_sensitive_Ex = "";
  var _patient_surgical = false, _patient_surgical_Ex = "";
  var _patient_haemophilia = false, _patient_haemophilia_Ex = "";
  var _patient_drugs = false, _patient_drugs_Ex = "";
  var _patient_oralDiseases, _patient_smoking = false;
  var _patient_pregnant = false, _patient_pregnant_Ex = "";
  var _patient_lactating = false, _patient_lactating_Ex = "";
  var _patient_contraception = false, _patient_contraception_Ex = "";

  List<String> listDoctors = [];
  final String _PHD_DoctorList = '';
  String _currentTreatmentPlan = "";

  // Treatment Plans Variables
  List<TreatmentPlanModel> treatmentPlans = [];
  DbTreatmentPlans dbTreatmentPlans = DbTreatmentPlans();
  DbInvoices dbInvoices = DbInvoices();
  String selectedDoctorForPlan = "حسام العايدي";

  // Invoice Variables
  int? lastInsertedTreatmentPlanId;
  List<String> paymentMethods = ['نقدي', 'بطاقة ائتمان', 'شيك', 'تحويل بنكي'];

  // New Variables for Appointments and Invoices
  List<DateModel> _patientAppointments = [];
  List<InvoiceModel> _patientInvoices = [];
  List<accModel.InvoicesModel> _patientAccountingInvoices = [];
  List<VoucherModel> _patientVouchers = [];
  DbDate dbDate = DbDate();
  List<dynamic> _unifiedFinancialRecords = [];
  double _totalInvoices = 0;
  double _totalReceipts = 0;
  double _remainingBalance = 0;

  void _rebuildUnifiedPlan() {
    Map<String, Map<String, dynamic>> unified = {};

    // Sort to process oldest first (newer records will update/overwrite status)
    List<PatienHealthtDoctorModel> sortedPHD = List.from(allPHD);
    try {
      sortedPHD.sort((a, b) => tt.DateFormat("dd/MM/yyyy")
          .parse(a.date)
          .compareTo(tt.DateFormat("dd/MM/yyyy").parse(b.date)));
    } catch (e) {
      debugPrint("Sort error in unified plan: $e");
    }

    for (var record in sortedPHD) {
      // 1. Process Plan Strings [الخطة العلاجية: ...]
      if (record.treatment.contains("[الخطة العلاجية:")) {
        RegExp planExp = RegExp(r'\[الخطة العلاجية: (.*?)\]');
        var match = planExp.firstMatch(record.treatment);
        if (match != null) {
          String content = match.group(1) ?? "";
          List<String> parts = content.split(RegExp(r'[،,] '));
          for (var part in parts) {
            List<String> sub = part.split('|');
            if (sub.length >= 2) {
              String tooth = sub[0].trim();
              String proc = sub[1].trim();
              bool completed = sub.length >= 3
                  ? sub[2].trim().toLowerCase() == 'true'
                  : false;
              String doc = sub.length >= 4 ? sub[3].trim() : record.doctorName;

              unified["$tooth|$proc"] = {
                'tooth': tooth,
                'proc': proc,
                'completed': completed,
                'doctor': doc
              };
            }
          }
        }
      }

      // 2. Extract from plain visit text "سن X: Y"
      // This ensures items added in "Treatment Details" show up in the "Treatment Plan" chart
      RegExp visitExp = RegExp(r'سن (\d+):\s*(.*?)(?=\n|$)');
      var matches = visitExp.allMatches(record.treatment);
      for (var m in matches) {
        String tooth = m.group(1)!;
        String proc = m.group(2)!.trim();
        // If it was in a plain visit record, we consider it completed
        unified["$tooth|$proc"] = {
          'tooth': tooth,
          'proc': proc,
          'completed': true,
          'doctor': record.doctorName
        };
      }
    }

    // 3. Process from Database Treatment Plans (New Table)
    // This ensures items saved via "Save Chart to List" are reflected back in the chart
    for (var plan in treatmentPlans) {
      String key = "${plan.toothNumber}|${plan.treatmentName}";
      unified[key] = {
        'tooth': plan.toothNumber,
        'proc': plan.treatmentName,
        'completed': plan.isCompleted,
        'doctor': plan.doctorName
      };
    }

    List<String> parts = [];
    for (var item in unified.values) {
      parts.add(
          "${item['tooth']}|${item['proc']}|${item['completed']}|${item['doctor']}");
    }

    if (parts.isNotEmpty) {
      setState(() {
        _currentTreatmentPlan = "[الخطة العلاجية: ${parts.join(', ')}]";
      });
    }
  }

  Map<String, List<String>> getGroupedPlannedTreatments() {
    Map<String, List<String>> grouped = {};
    if (_currentTreatmentPlan.isEmpty) return grouped;

    try {
      RegExp planExp = RegExp(r'\[الخطة العلاجية: (.*?)\]');
      var match = planExp.firstMatch(_currentTreatmentPlan);
      if (match != null) {
        String content = match.group(1) ?? "";
        List<String> parts =
            content.contains('، ') ? content.split('، ') : content.split(', ');
        for (var part in parts) {
          if (part.contains('|')) {
            List<String> sub = part.split('|');
            if (sub.length >= 2) {
              String tooth = sub[0].trim();
              String proc = sub[1].trim();
              if (proc.isNotEmpty) {
                if (!grouped.containsKey(proc)) {
                  grouped[proc] = [];
                }
                if (!grouped[proc]!.contains(tooth)) {
                  grouped[proc]!.add(tooth);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing planned treatments: $e");
    }
    return grouped;
  }

  /// استخراج جميع عناصر (tooth:treatment) من الرسومات
  List<String> _getChartItems() {
    List<String> items = [];
    if (_currentTreatmentPlan.isEmpty) return items;

    try {
      RegExp planExp = RegExp(r'\[الخطة العلاجية: (.*?)\]');
      var match = planExp.firstMatch(_currentTreatmentPlan);
      if (match != null) {
        String content = match.group(1) ?? "";
        List<String> parts =
            content.contains('، ') ? content.split('، ') : content.split(', ');

        for (var part in parts) {
          if (part.contains('|')) {
            List<String> sub = part.split('|');
            if (sub.length >= 2) {
              String tooth = sub[0].trim();
              String treatment = sub[1].trim();
              if (tooth.isNotEmpty && treatment.isNotEmpty) {
                items.add('$tooth:$treatment');
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error extracting chart items: $e");
    }
    return items;
  }

  final List<String> commonTreatments = [
    "فحص دوري (Checkup)",
    "تشخيص شامل (Diagnosis)",
    "تنظيف أسنان (Scaling)",
    "تلميع أسنان (Polishing)",
    "حشوة كمبوزيت (Composite Filling)",
    "حشوة أملغم (Amalgam Filling)",
    "حشوة مؤقتة (Temporary Filling)",
    "علاج عصب - جلسة واحدة (Root Canal - Single)",
    "علاج عصب - جلسات متعددة (Root Canal - Multi)",
    "إعادة علاج عصب (Re-Root Canal)",
    "خلع بسيط (Simple Extraction)",
    "خلع جراحي (Surgical Extraction)",
    "خلع ضرس العقل (Wisdom Tooth Extraction)",
    "قص اللثة (Gingivectomy)",
    "تلبيسة زيركون (Zirconia Crown)",
    "تلبيسة بورسلين (Porcelain Crown)",
    "جسر أسنان (Dental Bridge)",
    "فينيير (Veneers)",
    "زراعة سن (Dental Implant)",
    "تطعيم عظمي (Bone Graft)",
    "تبييض أسنان (Teeth Whitening)",
    "واقي ليلي (Night Guard)",
    "تقويم أسنان (Orthodontics)",
    "حافظ مسافة (Space Maintainer)",
    "صورة أشعة صغيرة (Periapical X-Ray)",
    "صورة بانوراما (Panorama X-Ray)",
    "طقم أسنان كامل (Full Denture)",
    "طقم أسنان جزئي (Partial Denture)",
  ];

  List<Tab> get myTabs => const <Tab>[
        Tab(text: 'معلومات عامة'),
        Tab(text: 'معلومات صحية'),
        Tab(text: 'الخطة العلاجية'),
        Tab(text: 'تفاصيل العلاج'),
        Tab(text: 'صور الأسنان'),
        Tab(text: 'المواعيد'),
        Tab(text: 'كشف الحساب'),
      ];

  bool editCheck = true;
  bool editCheckhealth = false;
  bool editCheckHealthDoctor = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var numberFormat = tt.NumberFormat("00000", "en_US");
  final ImagePicker picker = ImagePicker();
  XFile? imageFile;

  ButtonStyle FirstClick = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
    textStyle: WidgetStateProperty.all(
      const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    ),
    fixedSize: WidgetStateProperty.all(const Size(280, 50)),
    side: WidgetStateProperty.all(
      const BorderSide(
        color: Colors.deepPurple,
        width: 2,
      ),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    alignment: Alignment.center,
  );
  ButtonStyle SecondClick = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(Colors.white12),
    textStyle: WidgetStateProperty.all(
      const TextStyle(
          fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    fixedSize: WidgetStateProperty.all(const Size(280, 50)),
    side: WidgetStateProperty.all(
      const BorderSide(
        color: Colors.blueGrey,
        width: 2,
      ),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    alignment: Alignment.center,
  );

  Future<void> editCostumers(context) async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      formdata.save();
      if (editCheck == true) {
        // Perform the update immediately instead of waiting for a SnackBar action
        DbPatient dbPatient = DbPatient();
        await dbPatient.updateFileNoPatient(
            _patient_name,
            _patient_mobile,
            _patient_mobile2,
            _patient_sex,
            _patient_status,
            _patient_birthDate,
            _patient_fileNo,
            _patient_place,
            _patient_resone,
            _patient_worries);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'تم تعديل بيانات المريض بنجاح',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 3),
        ));

        editCheck = false;
        AllPatientList();
      }
    }
  }

  Future<void> editeCostumerhealth(context) async {
    var formdata = formstate2.currentState;
    if (formdata!.validate()) {
      formdata.save();
      for (int i = 0; i < allPatient.length; i++) {
        var paint = allPatient[i];
        if (int.parse(paint.fileNo) == int.parse(_patient_fileNo)) {
          editCheck = false;
          paint_id = paint.id;
          i = allPatient.length - 1;
        }
      }
      if (editCheckhealth == false) {
        DbPatientHealth dbPatientHealth = DbPatientHealth();
        dbPatientHealth.addPatientHealth(
            paint_id.toString(),
            _patient_health,
            _patient_sensitive.toString(),
            _patient_sensitive_Ex,
            _patient_surgical.toString(),
            _patient_surgical_Ex,
            _patient_haemophilia.toString(),
            _patient_haemophilia_Ex,
            _patient_drugs.toString(),
            _patient_drugs_Ex,
            _patient_oralDiseases,
            _patient_smoking.toString(),
            _patient_pregnant.toString(),
            _patient_pregnant_Ex,
            _patient_lactating.toString(),
            _patient_lactating_Ex,
            _patient_contraception.toString(),
            _patient_contraception_Ex);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            ' تم إضافة  البيانات الصحية للمريض بنجاح ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 4),
        ));
        editCheckhealth = true;
        AllPatientList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          action: SnackBarAction(
            textColor: Colors.white,
            backgroundColor: Colors.pinkAccent,
            label: 'تعديل الملف ',
            onPressed: () {
              DbPatientHealth dbPatientHealth = DbPatientHealth();
              dbPatientHealth.addPatientHealth(
                  paint_id.toString(),
                  _patient_health,
                  _patient_sensitive.toString(),
                  _patient_sensitive_Ex,
                  _patient_surgical.toString(),
                  _patient_surgical_Ex,
                  _patient_haemophilia.toString(),
                  _patient_haemophilia_Ex,
                  _patient_drugs.toString(),
                  _patient_drugs_Ex,
                  _patient_oralDiseases,
                  _patient_smoking.toString(),
                  _patient_pregnant.toString(),
                  _patient_pregnant_Ex,
                  _patient_lactating.toString(),
                  _patient_lactating_Ex,
                  _patient_contraception.toString(),
                  _patient_contraception_Ex);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  ' تم تعديل بيانات المريض بنجاح ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                duration: Duration(seconds: 4),
              ));
              AllPatientList();
            },
          ),
          content: const Column(
            children: [
              Text(
                'لم يتم إضافة البيانات لأن البيانات مكررة يرجى مراجعة البيانات ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          duration: const Duration(seconds: 5),
        ));
      }
      AllPatientList();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      selecedDoctorList();
      intValues();
    });
  }

  void intValues() {
    DbPatientHealth()
        .getPatientHealth(widget.Patients.id.toString())
        .then((HP) {
      if (!mounted || HP == null) return;
      setState(() {
        _patient_health = HP.health;
        _patient_sensitive = bool.parse(HP.sensitive.toLowerCase());
        _patient_sensitive_Ex = HP.sensitive_Ex;
        _patient_surgical = bool.parse(HP.surgical.toLowerCase());
        _patient_surgical_Ex = HP.surgical_Ex;
        _patient_haemophilia = bool.parse(HP.haemophilia.toLowerCase());
        _patient_haemophilia_Ex = HP.haemophilia_Ex;
        _patient_drugs = bool.parse(HP.drugs.toLowerCase());
        _patient_drugs_Ex = HP.drugs_Ex;
        _patient_oralDiseases = HP.oralDiseases;
        _patient_smoking = bool.parse(HP.smoking.toLowerCase());
        _patient_pregnant = bool.parse(HP.pregnant.toLowerCase());
        _patient_pregnant_Ex = HP.pregnant_Ex;
        _patient_lactating = bool.parse(HP.lactating.toLowerCase());
        _patient_lactating_Ex = HP.lactating_Ex;
        _patient_contraception = bool.parse(HP.contraception.toLowerCase());
        _patient_contraception_Ex = HP.contraception_Ex;
      });
    });
    DbPatientHealthDoctor dbPatientHealthDoctor = DbPatientHealthDoctor();
    setState(() {
      dbPatientHealthDoctor.searchByPatientId(widget.Patients.id).then((value) {
        if (!mounted) return;
        setState(() {
          allPHD = value;
          PHD_edit = List.generate(allPHD.length, (index) => false);
          formstateList = List.generate(
              allPHD.length, (int index) => GlobalObjectKey<FormState>(index),
              growable: true);
        });

        // Load latest dental chart plan if it exists
        for (var record in value) {
          if (record.treatment.contains("[الخطة العلاجية:")) {
            setState(() {
              _currentTreatmentPlan = record.treatment;
            });
            break;
          }
        }
      });
      paint_id = widget.Patients.id;
      _patient_name = widget.Patients.name.toString();
      _patient_mobile = widget.Patients.mobile.toString();
      _patient_mobile2 = (widget.Patients as dynamic).mobile2?.toString() ?? '';
      _patient_fileNo = widget.Patients.fileNo.toString();
      _patient_resone = widget.Patients.resone.toString();
      _patient_worries = "لا";
      _patient_place = widget.Patients.address.toString();
      _patient_sex = widget.Patients.sex.toString() == 'M' ||
              widget.Patients.sex.toString() == ''
          ? 'ذكر'
          : widget.Patients.sex.toString();
      //(widget.Patients.birthDay.isEmpty || widget.Patients.birthDay=='')?print('widget.Patients.birthDay'):print('rrrrrrrrrrrrrrffffffrr===${widget.Patients.birthDay}   ');
      projectStartDate = (widget.Patients.birthDay.isEmpty ||
              widget.Patients.birthDay == 'null')
          ? projectStartDate
          : tt.DateFormat("dd/MM/yyyy").parse(widget.Patients.birthDay);
      _patient_birthDate = widget.Patients.birthDay.toString() == ''
          ? '${projectStartDate.day}/${projectStartDate.month}/${projectStartDate.year}'
          : widget.Patients.birthDay.toString();
      _patient_status = 'أعزب';

      /// find Max No of Picture
      DbPicture dbPicture = DbPicture();
      dbPicture.lastPicture();
      dbPicture
          .searchPictureByPatientId(widget.Patients.id.toString())
          .then((picList) {
        if (!mounted) return;
        setState(() {
          imageUrls = picList.map((pic) => pic.pictureLocation).toList();
        });
      });

      // Load Treatment Plans from Database
      _loadTreatmentPlans();
      _loadAppointments();
      _loadInvoices();
    });
  }

  Future<void> _loadAppointments() async {
    try {
      List<DateModel> all =
          await dbDate.getDatesByPatient(widget.Patients.id.toString());
      if (!mounted) return;
      setState(() {
        _patientAppointments = all;
      });
    } catch (e) {
      debugPrint("Error loading appointments: $e");
    }
  }

  Future<void> _loadInvoices() async {
    try {
      List<InvoiceModel> invoices =
          await dbInvoices.getInvoicesByPatient(widget.Patients.id);
      if (!mounted) return;
      setState(() {
        _patientInvoices = invoices;
      });
      _loadVouchers();
    } catch (e) {
      debugPrint("Error loading invoices: $e");
    }
  }

  Future<void> _loadVouchers() async {
    try {
      String patientId = widget.Patients.id.toString();
      String accountingNo = widget.Patients.fileNo.toString();

      // Load accounting customers if list is empty
      if (allAccountingCoustmers.isEmpty) {
        await AllPaitentsTreeList();
      }

      // Look up correct accounting IDs by name matching
      String searchName = widget.Patients.name.trim();
      for (var e in allAccountingCoustmers) {
        if (e.name.trim() == searchName) {
          patientId = e.id.toString(); // Actual ID in database
          accountingNo =
              e.branch_no.toString(); // Account Number (typically fileNo)
          break;
        }
      }
      debugPrint(
          "Matched Patient: $searchName -> ID: $patientId, Account: $accountingNo");

      // Fetch vouchers (try both patientId and accountingNo to be thorough)
      List<Map<String, dynamic>> rawVouchers =
          await DbVouchers().getVouchersByAccount(patientId);
      Map<int, Map<String, dynamic>> dedupVouchers = {
        for (var v in rawVouchers) v['voucher_id'] as int: v
      };

      if (accountingNo != patientId) {
        final rawVouchers2 =
            await DbVouchers().getVouchersByAccount(accountingNo);
        for (var v in rawVouchers2) {
          int vid = v['voucher_id'] as int;
          if (!dedupVouchers.containsKey(vid)) dedupVouchers[vid] = v;
        }
      }
      List<Map<String, dynamic>> res = dedupVouchers.values.toList();
      debugPrint("Found ${res.length} unique vouchers");

      // Fetch journals (try both)
      List<Map<String, dynamic>> rawJournals =
          await DbJournalDetails().searchJournalsByAccountWithDate(patientId);
      Map<int, Map<String, dynamic>> dedupJournals = {
        for (var j in rawJournals) j['JD_id'] as int: j
      };
      if (accountingNo != patientId) {
        final rawJournals2 = await DbJournalDetails()
            .searchJournalsByAccountWithDate(accountingNo);
        for (var j in rawJournals2) {
          int jid = j['JD_id'] as int;
          if (!dedupJournals.containsKey(jid)) dedupJournals[jid] = j;
        }
      }
      final journals = dedupJournals.values.toList();
      debugPrint("Found ${journals.length} unique journals");

      // Fetch accounting invoices (try both)
      final rawAccInvoices =
          await acc.DbInvoices().getInvoicesByAccount(accountingNo);
      Map<int, accModel.InvoicesModel> dedupInvoices = {
        for (var inv in rawAccInvoices) inv.id: inv
      };
      if (patientId != accountingNo) {
        final rawAccInvoices2 =
            await acc.DbInvoices().getInvoicesByAccount(patientId);
        for (var inv in rawAccInvoices2) {
          if (!dedupInvoices.containsKey(inv.id)) dedupInvoices[inv.id] = inv;
        }
      }
      final accInvoices = dedupInvoices.values.toList();
      debugPrint("Found ${accInvoices.length} unique accounting invoices");

      if (!mounted) return;
      setState(() {
        _patientVouchers = res.map((e) => VoucherModel.fromMap(e)).toList();
        _patientAccountingInvoices = accInvoices;
      });
      _calculateFinancialSummary();
    } catch (e) {
      debugPrint("Error loading vouchers: $e");
    }
  }

  void _calculateFinancialSummary() {
    Map<String, dynamic> uniqueFinancialRecords = {};

    // 1. Process Clinical Invoices
    for (var i in _patientInvoices) {
      String key =
          "CI-${i.treatmentName}-${i.invoiceDate.split(' ')[0]}-${i.treatmentCost}";
      if (!uniqueFinancialRecords.containsKey(key)) {
        uniqueFinancialRecords[key] = i;
      }
    }

    // 2. Process Accounting Invoices
    for (var i in _patientAccountingInvoices) {
      String key = "AI-${i.id}-${i.date.split(' ')[0]}-${i.amount_all}";
      if (!uniqueFinancialRecords.containsKey(key)) {
        uniqueFinancialRecords[key] = i;
      }
    }

    // 3. Process Vouchers
    for (var v in _patientVouchers) {
      String key = "V-${v.id}-${v.date.split(' ')[0]}-${v.payment}";
      if (!uniqueFinancialRecords.containsKey(key)) {
        uniqueFinancialRecords[key] = v;
      }
    }

    List<dynamic> allRecords = uniqueFinancialRecords.values.toList();

    // Sort logic
    allRecords.sort((a, b) {
      String dateA = (a is InvoiceModel)
          ? a.invoiceDate
          : (a is accModel.InvoicesModel)
              ? a.date
              : (a is VoucherModel)
                  ? a.date
                  : "";
      String dateB = (b is InvoiceModel)
          ? b.invoiceDate
          : (b is accModel.InvoicesModel)
              ? b.date
              : (b is VoucherModel)
                  ? b.date
                  : "";
      try {
        DateTime dtA = tt.DateFormat("dd/MM/yyyy").parse(dateA.split(' ')[0]);
        DateTime dtB = tt.DateFormat("dd/MM/yyyy").parse(dateB.split(' ')[0]);
        return dtA.compareTo(dtB);
      } catch (e) {
        return dateA.compareTo(dateB);
      }
    });

    double totalInvoices = 0;
    double totalReceipts = 0;

    for (var record in allRecords) {
      if (record is InvoiceModel) {
        totalInvoices += record.treatmentCost;
      } else if (record is accModel.InvoicesModel) {
        totalInvoices += (double.tryParse(record.amount_all) ?? 0.0);
      } else if (record is VoucherModel) {
        if (record.className == 'قبض') {
          totalReceipts += (double.tryParse(record.payment) ?? 0.0);
        }
      }
    }

    if (mounted) {
      setState(() {
        _unifiedFinancialRecords = allRecords;
        _totalInvoices = totalInvoices;
        _totalReceipts = totalReceipts;
        _remainingBalance = totalInvoices - totalReceipts;
      });
    }
  }

  Future<void> _loadTreatmentPlans() async {
    try {
      List<TreatmentPlanModel> plans =
          await dbTreatmentPlans.getTreatmentPlansByPatient(widget.Patients.id);
      // Update the visual chart after loading plans
      _rebuildUnifiedPlan();

      if (!mounted) return;
      setState(() {
        treatmentPlans = plans;
      });
    } catch (e) {
      debugPrint("Error loading treatment plans: $e");
    }
  }

  Future<void> _saveTreatmentPlan(String toothNumber, String treatmentName,
      String doctorName, bool isCompleted,
      {bool showInfo = true}) async {
    try {
      TreatmentPlanModel plan = TreatmentPlanModel();
      plan.patientId = widget.Patients.id;
      plan.toothNumber = toothNumber;
      plan.treatmentName = treatmentName;
      plan.doctorName = doctorName;
      plan.treatmentDate = DateTime.now().toString();
      plan.isCompleted = isCompleted;

      int id = await dbTreatmentPlans.addTreatmentPlan(plan);
      if (id > 0) {
        lastInsertedTreatmentPlanId = id;

        // Reload plans from DB
        await _loadTreatmentPlans();

        // Force UI rebuild to show new item in list immediately
        if (mounted) {
          setState(() {});
        }

        if (showInfo && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ تم وصف العلاج وإضافته للقائمة")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving treatment plan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ خطأ في حفظ الخطة: $e")),
        );
      }
    }
  }

  void _navigateToSalesInvoice(int treatmentPlanId, String toothNumber,
      String treatmentName, String doctorName) {
    // 1. Initialize for regular new invoice
    VMSalesInvoice = ViewModelSalesInvoices.impty();

    // 2. Pre-fill Patient Data
    String pName = widget.Patients.name;
    // We already have globals like allAccountingCoustmers, let's use them
    VMSalesInvoice.AccountingGroups_select = 'المرضي';
    VMSalesInvoice.AccountingPerson_select_name = pName;
    VMSalesInvoice.selecedId(pName); // Sets AccountingPerson_select_id

    // 3. Prepare Treatment Item
    // We can use a consolidated name
    String fullItemName = "سن $toothNumber: $treatmentName";

    // Lookup item details if it exists in accounting index
    String itemId = '';
    double price = 0;
    for (var e in allAccountingIndex) {
      if (e.name == treatmentName || e.name == fullItemName) {
        itemId = e.no.toString();
        price = double.tryParse(e.selling_price) ?? 0;
        break;
      }
    }

    // 4. Create and add the row
    // My change in SalesInvoices.dart check rows.isEmpty to skip reset
    VMSalesInvoice.rows.add(
      PlutoRow(
        cells: {
          'id': PlutoCell(value: '0'),
          'id_invoice': PlutoCell(value: VMSalesInvoice.MaxInvoices),
          'id_item': PlutoCell(value: itemId),
          'name': PlutoCell(value: treatmentName),
          'qty': PlutoCell(value: 1),
          'price': PlutoCell(value: price),
          'total': PlutoCell(value: price),
          'delete': PlutoCell(value: ''),
        },
      ),
    );

    // Update totals in VM for the summary section
    VMSalesInvoice.amount = price;
    VMSalesInvoice.amount_all = price;
    VMSalesInvoice.remaining = price;

    // 5. Navigate to the official Sales Invoices page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SalesInvoices()),
    ).then((_) {
      // Optional: Refresh clinical data if needed
      _loadTreatmentPlans();
    });
  }

  Future<void> _updateTreatmentPlanStatus(int planId, bool isCompleted) async {
    try {
      await dbTreatmentPlans.updateCompletionStatus(planId, isCompleted);
      await _loadTreatmentPlans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isCompleted ? "✅ تم وضع علامة كمكتملة" : "⏳ تم إرجاع للعمل"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error updating treatment plan status: $e");
    }
  }

  Future<void> _deleteTreatmentPlan(int planId) async {
    try {
      await dbTreatmentPlans.deleteTreatmentPlan(planId);
      await _loadTreatmentPlans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم حذف الخطة بنجاح")),
        );
      }
    } catch (e) {
      debugPrint("Error deleting treatment plan: $e");
    }
  }

  Set<int> selectedPlanIds = {};

  Future<void> _updateSelectedPlansStatus(bool completed) async {
    for (int id in selectedPlanIds) {
      await dbTreatmentPlans.updateCompletionStatus(id, completed);
    }
    await _loadTreatmentPlans();
    setState(() {
      selectedPlanIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(completed
              ? "✅ تم تحديد العناصر كمكتملة"
              : "✅ تم تحديد العناصر كقيد التنفيذ")),
    );
  }

  Future<void> _updateSelectedPlansDate() async {
    final DateTime? startDateTime = await showDialog<DateTime>(
      context: context,
      builder: (context) => DatingAddDialog(
        title: "إضافة موعد جديد",
        positiveBtnText: "حفظ",
        negativeBtnText: "إلغاء",
        patientName: widget.Patients.name,
      ),
    );

    if (startDateTime == null) return;

    // Update Plans in DB
    for (int id in selectedPlanIds) {
      try {
        var plan = treatmentPlans.firstWhere((p) => p.id == id);
        plan.treatmentDate = startDateTime.toString(); // Update date
        await dbTreatmentPlans.updateTreatmentPlan(plan);
      } catch (e) {
        debugPrint("Error updating plan date: $e");
      }
    }

    await _loadTreatmentPlans();
    await _loadAppointments(); // Refresh appointment list after adding a new one
    setState(() {
      selectedPlanIds.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم تحديد الموعد وإضافته للجدول")),
      );
    }
  }

  Future<void> _deleteSelectedPlans() async {
    for (int id in selectedPlanIds) {
      await dbTreatmentPlans.deleteTreatmentPlan(id);
    }
    await _loadTreatmentPlans();
    setState(() {
      selectedPlanIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم حذف العناصر المحددة")),
    );
  }

  Widget _buildTreatmentPlansList() {
    if (treatmentPlans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                "لا توجد خطط علاجية محفوظة",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group by TREATMENT NAME
    Map<String, List<TreatmentPlanModel>> groupedByTreatment = {};
    for (var plan in treatmentPlans) {
      if (!groupedByTreatment.containsKey(plan.treatmentName)) {
        groupedByTreatment[plan.treatmentName] = [];
      }
      groupedByTreatment[plan.treatmentName]!.add(plan);
    }

    return Column(
      children: [
        // Action Bar when items are selected
        if (selectedPlanIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(
                  "تحديد (${selectedPlanIds.length})",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  tooltip: "الكل مكتمل",
                  onPressed: () => _updateSelectedPlansStatus(true),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.orange),
                  tooltip: "تحديد موعد",
                  onPressed: _updateSelectedPlansDate,
                ),
                IconButton(
                  icon: const Icon(Icons.receipt_long, color: Colors.blue),
                  tooltip: "إضافة فاتورة",
                  onPressed: () {
                    if (selectedPlanIds.isNotEmpty) {
                      final planId = selectedPlanIds.first;
                      final plan =
                          treatmentPlans.firstWhere((p) => p.id == planId);
                      _navigateToSalesInvoice(plan.id, plan.toothNumber,
                          plan.treatmentName, plan.doctorName);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("يرجى اختيار عنصر واحد على الأقل")),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: "حذف المحددة",
                  onPressed: () => _deleteSelectedPlans(),
                ),
              ],
            ),
          ),

        // List
        ...groupedByTreatment.entries.map((entry) {
          String treatmentName = entry.key;
          List<TreatmentPlanModel> plans = entry.value;

          // Check if all children in this group are selected
          bool allSelected = plans.every((p) => selectedPlanIds.contains(p.id));
          bool someSelected =
              plans.any((p) => selectedPlanIds.contains(p.id)) && !allSelected;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: ExpansionTile(
              leading: Checkbox(
                value: allSelected ? true : (someSelected ? null : false),
                tristate: true,
                onChanged: (val) {
                  setState(() {
                    if (val == true || val == null) {
                      // Select all
                      for (var p in plans) {
                        selectedPlanIds.add(p.id);
                      }
                    } else {
                      // Deselect all
                      for (var p in plans) {
                        selectedPlanIds.remove(p.id);
                      }
                    }
                  });
                },
              ),
              title: Text(
                "$treatmentName (${plans.length})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              initiallyExpanded: true,
              children: plans.map((plan) {
                bool isSelected = selectedPlanIds.contains(plan.id);
                return Container(
                  color: isSelected ? Colors.blue.withOpacity(0.05) : null,
                  child: ListTile(
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedPlanIds.add(plan.id);
                          } else {
                            selectedPlanIds.remove(plan.id);
                          }
                        });
                      },
                    ),
                    title: Text("السن ${plan.toothNumber}"),
                    subtitle: Text(
                      "${plan.doctorName} | ${plan.treatmentDate.split(' ')[0]}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (plan.isCompleted)
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20)
                        else
                          const Icon(Icons.schedule,
                              color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.calendar_month,
                              color: Colors.orange, size: 20),
                          tooltip: "حجز موعد",
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            setState(() {
                              selectedPlanIds.clear();
                              selectedPlanIds.add(plan.id);
                            });
                            _updateSelectedPlansDate();
                          },
                        ),
                        // Quick Action: Invoice
                        IconButton(
                          icon: const Icon(Icons.receipt_long,
                              color: Colors.blue, size: 20),
                          tooltip: "فاتورة",
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () => _navigateToSalesInvoice(
                            plan.id,
                            plan.toothNumber,
                            plan.treatmentName,
                            plan.doctorName,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'complete') {
                              _updateTreatmentPlanStatus(
                                plan.id,
                                !plan.isCompleted,
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'complete',
                              child: Text(plan.isCompleted
                                  ? 'تحديد كغير مكتمل'
                                  : 'تحديد كمكتمل'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }

  void _showAddTreatmentDialog() {
    // استخراج الإجراءات من الرسومات
    List<String> chartItems = _getChartItems();

    // Filter out items already saved in the database
    List<String> unsavedChartItems = [];
    for (var item in chartItems) {
      final parts = item.split(':');
      if (parts.length == 2) {
        String tooth = parts[0].trim();
        String treatment = parts[1].trim();

        bool alreadySaved = treatmentPlans.any((plan) =>
            plan.toothNumber == tooth && plan.treatmentName == treatment);

        if (!alreadySaved) {
          unsavedChartItems.add(item);
        }
      }
    }

    // إذا كانت هناك إجراءات من الرسومات، نعرض حوار لاختيار الطبيب أولاً
    if (unsavedChartItems.isNotEmpty) {
      _showSelectDoctorDialog(unsavedChartItems);
    } else {
      // إذا لم تكن هناك إجراءات، نعرض رسالة إعلام
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ يرجى تحديد الأسنان من الرسومات أولاً"),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSelectDoctorDialog(List<String> unsavedChartItems) {
    String selectedDoctor =
        listDoctors.isNotEmpty ? listDoctors[0] : "حسام العايدي";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('تحديد الطبيب المعالج'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تم العثور على ${unsavedChartItems.length} إجراء في الرسومات',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الإجراءات المختارة:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: unsavedChartItems
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          size: 18, color: Colors.green[600]),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Doctor Selection Dropdown - إجباري
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange[50],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_rounded,
                                  color: Colors.orange[800], size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'اختر الطبيب المعالج',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const Text(
                                      '* إجباري',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedDoctor,
                            decoration: InputDecoration(
                              labelText: 'اختر اسم الدكتور',
                              labelStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                              prefixIcon: Icon(Icons.medical_services_rounded,
                                  color: Colors.orange[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.orange[800]!, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Colors.orange[800]!, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: listDoctors
                                .map((doc) => DropdownMenuItem(
                                    value: doc,
                                    child: Text(doc,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600))))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedDoctor = value ?? selectedDoctor;
                              });
                            },
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (selectedDoctor.isNotEmpty) {
                      int addedCount = 0;
                      for (String item in unsavedChartItems) {
                        final parts = item.split(':');
                        if (parts.length == 2) {
                          await _saveTreatmentPlan(
                              parts[0], parts[1], selectedDoctor, false,
                              showInfo: false);
                          addedCount++;
                        }
                      }

                      if (addedCount > 0 && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("✅ تم إضافة $addedCount إجراءات بنجاح"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }

                      if (mounted) Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ يرجى اختيار اسم الدكتور قبل الحفظ'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('تأكيد واضافة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddFromListDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String? selectedTooth;
        String selectedTreatment = '';
        String selectedDoctor = listDoctors.isNotEmpty ? listDoctors[0] : '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة إجراء من القائمة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value:
                          selectedTreatment.isEmpty ? null : selectedTreatment,
                      decoration: const InputDecoration(
                        labelText: 'اختر الإجراء العلاجي',
                      ),
                      items: commonTreatments
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedTreatment = v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedTooth,
                      decoration:
                          const InputDecoration(labelText: 'اختر رقم السن'),
                      items: [
                        '17',
                        '16',
                        '15',
                        '14',
                        '13',
                        '12',
                        '11',
                        '21',
                        '22',
                        '23',
                        '24',
                        '25',
                        '26',
                        '27',
                        '28',
                        '38',
                        '37',
                        '36',
                        '35',
                        '34',
                        '33',
                        '32',
                        '31',
                        '41',
                        '42',
                        '43',
                        '44',
                        '45',
                        '46',
                        '47',
                        '48'
                      ]
                          .toSet() // Fix duplicates
                          .toList()
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => selectedTooth = v),
                    ),
                    const SizedBox(height: 16),
                    // Doctor Selection Dropdown - إجباري
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.orange[50],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_rounded,
                                  color: Colors.orange[800], size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'اختيار إجباري: اسم الدكتور',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedDoctor,
                            decoration: InputDecoration(
                              labelText: 'اختر اسم الدكتور',
                              prefixIcon:
                                  const Icon(Icons.medical_services_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: listDoctors
                                .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500))))
                                .toList(),
                            onChanged: (v) => setState(
                                () => selectedDoctor = v ?? selectedDoctor),
                            isExpanded: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedTooth == null || selectedTreatment.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ يرجى اختيار السن والإجراء العلاجي'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (selectedDoctor.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ يرجى اختيار اسم الدكتور قبل الحفظ'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    await _saveTreatmentPlan(selectedTooth!, selectedTreatment,
                        selectedDoctor, false);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration inputDecoration(IconData icon, String hintText) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 35),
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(fontSize: 20),
      errorStyle: const TextStyle(
          color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 3, color: Colors.white),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 4, color: Color(0xffF02E65)),
      ),
      border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
    );
  }

  InputDecoration inputDecorationNoIcon(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      errorStyle: const TextStyle(
          color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 3, color: Colors.white),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 4, color: Color(0xffF02E65)),
      ),
      border: const OutlineInputBorder(borderSide: BorderSide(width: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: myTabs.length,
        initialIndex: widget.initialIndex,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xFF1D9D99),
          appBar: AppBar(
            title: const Text('تعديل بيانات المرضى',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF167774),
            bottom: TabBar(
              isScrollable: true,
              tabs: myTabs,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              labelColor: Colors.white,
              unselectedLabelStyle:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.black,
              indicatorColor: Colors.pink,
              indicatorWeight: 3,
            ),
          ),
          body: TabBarView(
            // controller:_tabController,
            // clipBehavior: Clip.hardEdge,
            children: [
              Container(
                child: FisrtPage(context),
              ),
              Container(
                child: SecondPage(context),
              ),
              Container(child: FivePage(context)),
              Container(child: ThirdPage(context)),
              Container(child: FourPage(context)),
              Container(child: SixPage(context)),
              Container(child: SevenPage(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget FivePage(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== Dental Chart Section =====
              const Text(
                "الخطة العلاجية المقترحة",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF167774)),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              // Enforce height constraint ensures chart renders even if it tries to be infinite
              DentalChartWidget(
                initialTreatmentText: _currentTreatmentPlan,
                doctors: listDoctors,
                initialDoctor:
                    _PHD_DoctorList.isNotEmpty ? _PHD_DoctorList : null,
                onChanged: (val) {
                  // Update state to ensure UI sync
                  setState(() {
                    _currentTreatmentPlan = val;
                  });
                },
                onSaveTreatment: (tooth, treatment, doctor) {
                  _saveTreatmentPlan(tooth, treatment, doctor, false);
                },
              ),

              // ===== Saved Treatment Plans Section =====
              const SizedBox(height: 20),
              const Text(
                "الخطط العلاجية المحفوظة في قاعدة البيانات",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF167774)),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 10),
              _buildTreatmentPlansList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget FisrtPage(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Form(
            key: formstate,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                // PaintFileNo and PaintName
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: TextFormField(
                        initialValue: widget.Patients.fileNo,
                        readOnly: true,
                        style: const TextStyle(fontSize: 20),
                        decoration:
                            inputDecoration(Icons.filter_1, "رقم الملف"),
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Flexible(
                      flex: 6,
                      child: TextFormField(
                        initialValue: widget.Patients.name,
                        onChanged: (val) {
                          setState(() {
                            editCheck = true;
                          });
                        },
                        onSaved: (val) {
                          _patient_name = val;
                        },
                        validator: (val) {
                          if (val!.length > 50) {
                            return "يجب أن يكون اسم المستخدم أقل من 50 حرف";
                          }
                          if (val.length < 3) {
                            return "يجب أن يكون اسم المستخدم أكثر من تلاث حروف";
                          }
                          return null;
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.deny(
                              RegExp(r'\d+[,.]{0,1}[0-9]*')),
                          FilteringTextInputFormatter.deny(
                              RegExp(r'[a-zA-Z0-9]')),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(fontSize: 20),
                        decoration: inputDecoration(Icons.person, "اسم المريض"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Sex and mobileNumber
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        height: 70.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton(
                          value: costumer_sex_items.contains(_patient_sex)
                              ? _patient_sex
                              : null,
                          hint: const Text('الجنس'),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_downward),
                          isExpanded: true,
                          selectedItemBuilder: (BuildContext context) {
                            //<-- SEE HERE
                            return costumer_sex_items.map((String value) {
                              return Center(
                                child: Text(
                                  _patient_sex,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList();
                          },
                          // Array list of items
                          items: costumer_sex_items.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Center(
                                child: Text(
                                  items,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Object? value) {
                            setState(() {
                              _patient_sex = value.toString();
                              editCheck = true;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      flex: 5,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: widget.Patients.mobile,
                              validator: (val) {
                                if (val == null) return null;
                                if (val.length > 10) {
                                  return "لا يكون الاسم أكثر من 10 حرفا";
                                }
                                if (val.length < 10) {
                                  return "لا يكون الاسم أقل من 10 أحرف";
                                }
                                return null;
                              },
                              onChanged: (val) {
                                setState(() {
                                  editCheck = true;
                                });
                              },
                              onSaved: (val) {
                                setState(() {
                                  _patient_mobile = val;
                                });
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: false,
                                decimal: false,
                              ),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'\d')),
                              ],
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: const TextStyle(fontSize: 18),
                              decoration: inputDecoration(
                                  Icons.mobile_friendly, "رقم الجوال "),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: _patient_mobile2,
                              onChanged: (val) {
                                setState(() {
                                  editCheck = true;
                                });
                              },
                              onSaved: (val) {
                                setState(() {
                                  _patient_mobile2 = val;
                                });
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: false,
                                decimal: false,
                              ),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'\d')),
                              ],
                              style: const TextStyle(fontSize: 18),
                              decoration: inputDecoration(
                                  Icons.mobile_friendly, "رقم جوال ثاني"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Paint Place
                TextFormField(
                  initialValue: widget.Patients.address,
                  validator: (val) {
                    if (val!.length > 50) {
                      return " يجب أن لا يكون الاسم أكثر من 50 حرفا";
                    }
                    if (val.length < 4) {
                      return " يجب أن لا يكون الاسم أقل من 4 أحرف";
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      editCheck = true;
                    });
                  },
                  onSaved: (val) {
                    _patient_place = val;
                  },
                  // keyboardType: const TextInputType.numberWithOptions()
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]'))
                  ],
                  // validate after each user interaction
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(fontSize: 20),
                  decoration: inputDecoration(Icons.place, "عنوان المريض"),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Staus  and PaintBirthDate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        height: 70.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton(
                          // Initial Value
                          value: costumer_status_items.contains(_patient_status)
                              ? _patient_status
                              : null,
                          hint: const Text('الحالة الاجتماعية'),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_downward),
                          isExpanded: true,
                          selectedItemBuilder: (BuildContext context) {
                            //<-- SEE HERE
                            return costumer_status_items.map((String value) {
                              return Center(
                                child: Text(
                                  _patient_status,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList();
                          },
                          // Array list of items
                          items: costumer_status_items.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Center(
                                child: Text(
                                  items,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Object? value) {
                            setState(() {
                              _patient_status = value.toString();
                              editCheck = true;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      flex: 5,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              width: 2,
                              color: Colors.grey,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: [
                              const Text(' تاريخ الميلاد',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const Divider(
                                thickness: 2,
                              ),
                              TextButton(
                                onPressed: () async {
                                  final date = await pickDate(context);
                                  if (date == null) return;
                                  setState(() {
                                    _patient_birthDate =
                                        '${date.day}/${date.month}/${date.year}';
                                    //projectStartDate=date;
                                    editCheck = true;
                                  });
                                  // print(date);
                                },
                                child: SizedBox(
                                  height: 30,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month,
                                        size: 30,
                                      ),
                                      Text(
                                        '   ${projectStartDate.year}/${projectStartDate.month}/${projectStartDate.day}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Paint Resone
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 5,
                      child: TextFormField(
                        initialValue: widget.Patients.resone,
                        onChanged: (val) {
                          setState(() {
                            editCheck = true;
                          });
                        },
                        onSaved: (val) {
                          _patient_resone = val;
                        },
                        // keyboardType: const TextInputType.numberWithOptions()
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]'))
                        ],
                        style: const TextStyle(fontSize: 20),
                        decoration: inputDecoration(
                            Icons.report_problem_outlined,
                            " السبب الرئيسي لزيارة المريض"),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              width: 2,
                              color: Colors.grey,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: [
                              const Text('هل تقلقك زيارة طبيب الأسنان',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const Divider(
                                thickness: 1,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                height: 60.0,
                                child: DropdownButton(
                                  // Initial Value
                                  value: costumer_worries_items
                                          .contains(_patient_worries)
                                      ? _patient_worries
                                      : null,
                                  hint: const Text('هل يقلقك زيارة الطبيب'),
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.arrow_downward),
                                  isExpanded: true,
                                  selectedItemBuilder: (BuildContext context) {
                                    //<-- SEE HERE
                                    return costumer_worries_items
                                        .map((String value) {
                                      return Center(
                                        child: Text(
                                          _patient_worries,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  // Array list of items
                                  items: costumer_worries_items
                                      .map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Center(
                                        child: Text(
                                          items,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Object? value) {
                                    setState(() {
                                      _patient_worries = value.toString();
                                      editCheck = true;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          editCostumers(context);
                        });
                      },
                      style: editCheck == false ? SecondClick : FirstClick,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تعديل بيانات المريض',
                            style: TextStyle(
                                color: Color(0xFF167774), fontSize: 20),
                          ),
                          Icon(
                            Icons.save_outlined,
                            color: Color(0xFF167774),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget SecondPage(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Form(
            key: formstate2,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                // _patient_health
                /** اذكر المشاكل الصحية **/
                TextFormField(
                  maxLines: 2,
                  initialValue: _patient_health,
                  onChanged: (val) {
                    setState(() {
                      editCheckhealth = true;
                    });
                  },
                  onSaved: (val) {
                    _patient_health = val!;
                  },
                  style: const TextStyle(fontSize: 20),
                  decoration: inputDecorationNoIcon("اذكر أي مشاكل صحية"),
                ),
                const SizedBox(
                  height: 15,
                ),
                /** الحساسية في الجسم **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: _patient_sensitive == true ? 2 : 7,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: _patient_sensitive == true
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('هل تعاني من حساسية الجسم لأي دواء',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 2,
                            ),
                            Checkbox(
                              value: _patient_sensitive,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_sensitive = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: _patient_sensitive == true ? 2 : 1,
                      child: _patient_sensitive == true
                          ? TextFormField(
                              initialValue: _patient_sensitive_Ex,
                              onChanged: (val) {
                                editCheckhealth = true;
                              },
                              onSaved: (val) {
                                _patient_sensitive_Ex = val!;
                              },
                              style: const TextStyle(fontSize: 18),
                              decoration: inputDecorationNoIcon("أذكرها.... "),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                /** عمليات جراحية **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: _patient_surgical == true ? 2 : 7,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: _patient_surgical == true
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('هل خضعت لعمليات جراحية',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 2,
                            ),
                            Checkbox(
                              value: _patient_surgical,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_surgical = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: _patient_surgical == true ? 2 : 1,
                      child: _patient_surgical == true
                          ? TextFormField(
                              initialValue: _patient_surgical_Ex,
                              onChanged: (val) {
                                editCheckhealth = true;
                              },
                              onSaved: (val) {
                                _patient_surgical_Ex = val!;
                              },
                              style: const TextStyle(fontSize: 18),
                              decoration: inputDecorationNoIcon("أذكرها.... "),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                /** مخثرات الدم أو مضادات التخثر   **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: _patient_haemophilia == true ? 3 : 7,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: _patient_haemophilia == true
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                                'هل تأخذ علاج السيولة الدم أو مضادات التخثر',
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 1,
                            ),
                            Checkbox(
                              value: _patient_haemophilia,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_haemophilia = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: _patient_haemophilia == true ? 2 : 1,
                      child: _patient_haemophilia == true
                          ? TextFormField(
                              initialValue: _patient_haemophilia_Ex,
                              onChanged: (val) {
                                editCheckhealth = true;
                              },
                              onSaved: (val) {
                                _patient_haemophilia_Ex = val!;
                              },
                              style: const TextStyle(fontSize: 18),
                              decoration: inputDecorationNoIcon("أذكرها.... "),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                /** أدوية علاجية **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: _patient_drugs == true ? 2 : 7,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: _patient_drugs == true
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('هل تتناول أدوية علاجية',
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 1,
                            ),
                            Checkbox(
                              value: _patient_drugs,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_drugs = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: _patient_drugs == true ? 2 : 1,
                      child: _patient_drugs == true
                          ? TextFormField(
                              initialValue: _patient_drugs_Ex,
                              onChanged: (val) {
                                editCheckhealth = true;
                              },
                              onSaved: (val) {
                                _patient_drugs_Ex = val!;
                              },
                              style: const TextStyle(fontSize: 18),
                              decoration: inputDecorationNoIcon("أذكرها.... "),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                /**  مدخن     اذكر المشاكل الفموية  **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: TextFormField(
                        maxLines: 2,
                        initialValue: _patient_oralDiseases,
                        onChanged: (val) {
                          editCheckhealth = true;
                        },
                        onSaved: (val) {
                          _patient_oralDiseases = val!;
                        },
                        style: const TextStyle(fontSize: 20),
                        decoration:
                            inputDecorationNoIcon("اذكر أي مشاكل فموية"),
                      ),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('هل أنت مدخن',
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 1,
                            ),
                            Checkbox(
                              value: _patient_smoking,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_smoking = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                /** حامل **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: _patient_pregnant == true ? 1 : 7,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('هل أنت حامل',
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 1,
                            ),
                            Checkbox(
                              value: _patient_pregnant,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_pregnant = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: _patient_pregnant == true ? 2 : 1,
                      child: _patient_pregnant == true
                          ? TextFormField(
                              initialValue: _patient_pregnant_Ex,
                              onChanged: (val) {
                                editCheckhealth = true;
                              },
                              onSaved: (val) {
                                _patient_pregnant_Ex = val!;
                              },
                              style: const TextStyle(fontSize: 18),
                              decoration:
                                  inputDecorationNoIcon(" في أي شهر .... "),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                /** مرضعة **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: _patient_lactating == true ? 1 : 7,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('هل أنت مرضعة',
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 1,
                            ),
                            Checkbox(
                              value: _patient_lactating,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_lactating = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: _patient_lactating == true ? 2 : 1,
                      child: _patient_lactating == true
                          ? TextFormField(
                              initialValue: _patient_lactating_Ex,
                              onChanged: (val) {
                                editCheckhealth = true;
                              },
                              onSaved: (val) {
                                _patient_lactating_Ex = val!;
                              },
                              style: const TextStyle(fontSize: 18),
                              decoration:
                                  inputDecorationNoIcon("عمر الرضيع .... "),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                /** أدوية منع حمل  **/
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: _patient_contraception == true ? 1 : 7,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 2,
                            color: Colors.grey,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('هل تأخذ أدوية منع حمل ',
                                softWrap: true,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(
                              thickness: 1,
                            ),
                            Checkbox(
                              value: _patient_contraception,
                              onChanged: (bool? value) {
                                setState(() {
                                  _patient_contraception = value!;
                                  editCheckhealth = true;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Flexible(
                      flex: _patient_contraception == true ? 2 : 1,
                      child: _patient_contraception == true
                          ? TextFormField(
                              initialValue: _patient_contraception_Ex,
                              onChanged: (val) {
                                editCheckhealth = true;
                              },
                              onSaved: (val) {
                                _patient_contraception_Ex = val!;
                              },
                              style: const TextStyle(fontSize: 18),
                              decoration:
                                  inputDecorationNoIcon("اذكريها  .... "),
                            )
                          : const Text(''),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          if (editCheck == false) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                'لم يتم إضافة البيانات الصحية يجب اضافة المعلومات الشخصية أولا  ',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              duration: Duration(seconds: 4),
                            ));
                          } else {
                            if (editCheckhealth == false) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  ' تم إضافة البيانات الصحية',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                duration: Duration(seconds: 4),
                              ));
                              editCheckhealth = true;
                            } else {
                              editeCostumerhealth(context);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'لم يتم إضافة البيانات الصحية هل تريد تعديل البينات',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                duration: Duration(seconds: 4),
                              ));
                            }
                          }
                        });
                      },
                      style: editCheckhealth == true ? FirstClick : SecondClick,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ' احفظ البيانات الصحية ',
                            style: TextStyle(
                                color: Color(0xFF167774), fontSize: 20),
                          ),
                          Icon(
                            Icons.save_outlined,
                            color: Color(0xFF167774),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget ThirdPage(BuildContext context) {
    // Sorting inside build is generally discouraged but removing setState prevents the crash.
    // Ideally this should be in initState or when data loads.
    allPHD.sort((a, b) => tt.DateFormat("dd/MM/yyyy")
        .parse(b.date)
        .compareTo(tt.DateFormat("dd/MM/yyyy").parse(a.date)));

    // Resetting edit flags on every build is also logic that should probably be elsewhere,
    // but preserving behavior without setState for now.
    for (int i = 0; i < PHD_edit.length; i++) {
      // PHD_edit[i] = false; // logic was to reset?
      // Original code: for (var element in PHD_edit) { element = false; }
      // Iterate by reference doesn't work for bool primitive in dart foreach.
      // Also resetting it here means typing might be lost if keyboard dismiss triggers rebuild?
      // Commenting out the reset as it seems destructive to UX during editing.
    }

    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            backgroundColor: Color(0xFF1D9D99),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.startFloat,
            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.white,
                elevation: 15,
                child: const Icon(
                  Icons.add_sharp,
                  color: Color(0xFF1D9D99),
                  size: 40.0,
                  semanticLabel: 'إضافة تفاصيل للعلاج',
                ),
                onPressed: () async {
                  final String nowStr =
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
                  DbPatientHealthDoctor dbPatientHealthDoctor =
                      DbPatientHealthDoctor();

                  await dbPatientHealthDoctor.addPHD(
                      widget.Patients.id.toString(),
                      '1',
                      'حسام العايدي',
                      nowStr,
                      '',
                      '');

                  // Refresh full list from DB to ensure local state matches DB
                  updatePHD();

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("تم إضافة سجل علاج جديد"),
                    duration: Duration(seconds: 2),
                  ));
                }),
            body: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 2));
                updatePHD();
              },
              child: CardView(),
            )));
  }

  void updatePHD() {
    debugPrint("updatePHD called");
    DbPatientHealthDoctor dbPatientHealthDoctor = DbPatientHealthDoctor();
    dbPatientHealthDoctor.searchByPatientId(widget.Patients.id).then((value) {
      debugPrint("Loaded ${value.length} PHD records from database");
      setState(() {
        allPHD = value;
        PHD_edit = List.generate(allPHD.length, (index) => false);
        formstateList = List.generate(
            allPHD.length, (int index) => GlobalObjectKey<FormState>(index),
            growable: true);

        // Load latest dental chart plan if it exists
        _rebuildUnifiedPlan();
        debugPrint(
            "Updated allPHD with ${allPHD.length} records and rebuilt unified plan");
      });
    }).catchError((error) {
      debugPrint("Error loading PHD records: $error");
    });
  }

  Widget CardView() {
    allPHD.sort((a, b) => tt.DateFormat("dd/MM/yyyy")
        .parse(b.date)
        .compareTo(tt.DateFormat("dd/MM/yyyy").parse(a.date)));

    return ListView.builder(
        scrollDirection: Axis.vertical,
        // shrinkWrap: true, // Removed to fix hasSize error
        itemCount: allPHD.length,
        itemBuilder: (context, i) {
          final colorPrimary = const Color(0xFF1D9D99);
          final colorSecondary = Colors.indigo.shade700;

          return Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Form(
                key: formstateList.elementAt(i),
                onChanged: () => PHD_edit[i] = true,
                child: Column(
                  children: [
                    // Header Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorPrimary, colorPrimary.withOpacity(0.8)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history_edu_rounded,
                                  color: Colors.white, size: 28),
                              const SizedBox(width: 10),
                              Text(
                                "زيارة علاجية #${allPHD.length - i}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.save_rounded,
                                    color: PHD_edit[i]
                                        ? Colors.yellowAccent
                                        : Colors.white70,
                                    size: 28),
                                tooltip: "حفظ التغييرات",
                                onPressed: () async {
                                  DbPatientHealthDoctor()
                                      .updatePHD(allPHD[i].id, allPHD[i]);
                                  setState(() => PHD_edit[i] = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("تم حفظ التعديلات"),
                                          duration: Duration(seconds: 1)));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_rounded,
                                    color: Colors.white70, size: 28),
                                tooltip: "حذف السجل",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      title: const Text('حذف تفاصيل العلاج'),
                                      content: const Text(
                                          'هل أنت متأكد من حذف هذا السجل بشكل دائم؟'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('إلغاء')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white),
                                          onPressed: () {
                                            DbPatientHealthDoctor()
                                                .deletePHD(allPHD[i].id);
                                            setState(() {
                                              allPHD.removeAt(i);
                                              PHD_edit.removeAt(i);
                                              formstateList.removeAt(i);
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Visit Basics
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final date = await pickDate(context);
                                    if (date != null) {
                                      setState(() {
                                        allPHD[i].date =
                                            '${date.day}/${date.month}/${date.year}';
                                        PHD_edit[i] = true;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded,
                                            color: colorPrimary, size: 20),
                                        const SizedBox(width: 10),
                                        Text(allPHD[i].date,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    labelText: "الطبيب المعالج",
                                    labelStyle: TextStyle(
                                        color: colorPrimary,
                                        fontWeight: FontWeight.bold),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200)),
                                    prefixIcon: Icon(
                                        Icons.medical_services_rounded,
                                        color: colorPrimary),
                                  ),
                                  initialValue:
                                      listDoctors.contains(allPHD[i].doctorName)
                                          ? allPHD[i].doctorName
                                          : (listDoctors.isNotEmpty
                                              ? listDoctors[0]
                                              : null),
                                  items: listDoctors
                                      .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e,
                                              style: const TextStyle(
                                                  fontSize: 15))))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        allPHD[i].doctorName = val;
                                        DbEmployee()
                                            .searchingEmployee(val)
                                            .then((list) {
                                          if (list != null && list.isNotEmpty) {
                                            setState(() => allPHD[i].doctorId =
                                                list[0]['employee_id']
                                                    .toString());
                                          }
                                        });
                                        PHD_edit[i] = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Treatment Plan Integration
                          Container(
                            decoration: BoxDecoration(
                              color: colorSecondary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: colorSecondary.withOpacity(0.1)),
                            ),
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                    backgroundColor:
                                        colorSecondary.withOpacity(0.1),
                                    child: Icon(Icons.account_tree_rounded,
                                        color: colorSecondary, size: 20)),
                                title: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: colorSecondary,
                                      value: getGroupedPlannedTreatments()
                                              .isNotEmpty &&
                                          getGroupedPlannedTreatments()
                                              .entries
                                              .every((g) => g.value.every((t) =>
                                                  allPHD[i].treatment.contains(
                                                      "سن $t: ${g.key}"))),
                                      tristate: getGroupedPlannedTreatments()
                                              .entries
                                              .any((g) => g.value.any((t) =>
                                                  allPHD[i].treatment.contains(
                                                      "سن $t: ${g.key}"))) &&
                                          !getGroupedPlannedTreatments()
                                              .entries
                                              .every((g) => g.value.every((t) =>
                                                  allPHD[i].treatment.contains(
                                                      "سن $t: ${g.key}"))),
                                      onChanged: (val) {
                                        setState(() {
                                          var allEntries =
                                              getGroupedPlannedTreatments()
                                                  .entries;
                                          for (var group in allEntries) {
                                            for (var tooth in group.value) {
                                              String label =
                                                  "سن $tooth: ${group.key}";
                                              bool itemChecked = allPHD[i]
                                                  .treatment
                                                  .contains(label);
                                              if (val == true && !itemChecked) {
                                                allPHD[i].treatment = allPHD[i]
                                                        .treatment
                                                        .isEmpty
                                                    ? label
                                                    : "$label\n${allPHD[i].treatment}";
                                              } else if (val == false &&
                                                  itemChecked) {
                                                allPHD[i].treatment = allPHD[i]
                                                    .treatment
                                                    .replaceFirst(
                                                        "$label\n", "")
                                                    .replaceFirst(label, "")
                                                    .trim();
                                              }
                                            }
                                          }
                                          PHD_edit[i] = true;
                                        });
                                      },
                                    ),
                                    const Text("اختيار من الخطة المجدولة",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                                children: [
                                  if (getGroupedPlannedTreatments().isEmpty)
                                    const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text("لا توجد خطة علاجية مضافة",
                                            style:
                                                TextStyle(color: Colors.grey))),
                                  ...getGroupedPlannedTreatments()
                                      .entries
                                      .map((group) {
                                    bool isGroupAllChecked = group.value.every(
                                        (tooth) => allPHD[i].treatment.contains(
                                            "سن $tooth: ${group.key}"));
                                    bool isGroupAnyChecked = group.value.any(
                                        (tooth) => allPHD[i].treatment.contains(
                                            "سن $tooth: ${group.key}"));
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: colorSecondary
                                                  .withOpacity(0.05))),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: colorSecondary
                                                    .withOpacity(0.05),
                                                borderRadius: const BorderRadius
                                                    .vertical(
                                                    top: Radius.circular(15))),
                                            child: CheckboxListTile(
                                              value: isGroupAllChecked,
                                              tristate: isGroupAnyChecked &&
                                                  !isGroupAllChecked,
                                              title: Text(group.key,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15)),
                                              onChanged: (val) {
                                                setState(() {
                                                  for (var tooth
                                                      in group.value) {
                                                    String label =
                                                        "سن $tooth: ${group.key}";
                                                    bool itemChecked = allPHD[i]
                                                        .treatment
                                                        .contains(label);
                                                    if (val == true &&
                                                        !itemChecked) {
                                                      allPHD[i]
                                                          .treatment = allPHD[i]
                                                              .treatment
                                                              .isEmpty
                                                          ? label
                                                          : "$label\n${allPHD[i].treatment}";
                                                    } else if (val == false &&
                                                        itemChecked) {
                                                      allPHD[i].treatment =
                                                          allPHD[i]
                                                              .treatment
                                                              .replaceFirst(
                                                                  "$label\n",
                                                                  "")
                                                              .replaceFirst(
                                                                  label, "")
                                                              .trim();
                                                    }
                                                  }
                                                  PHD_edit[i] = true;
                                                });
                                              },
                                            ),
                                          ),
                                          ...group.value.map((tooth) {
                                            String label =
                                                "سن $tooth: ${group.key}";
                                            
                                            // التحقق مما إذا كان هذا الإجراء قد تم اختياره في زيارة أخرى بالفعل
                                            bool isDoneInOtherVisit = false;
                                            for (int k = 0; k < allPHD.length; k++) {
                                              if (k != i && allPHD[k].treatment.contains(label)) {
                                                isDoneInOtherVisit = true;
                                                break;
                                              }
                                            }

                                            bool isCheckedInCurrentVisit = allPHD[i].treatment.contains(label);

                                            return CheckboxListTile(
                                              dense: true,
                                              activeColor: isDoneInOtherVisit ? Colors.grey : null,
                                              title: Text(label,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: isDoneInOtherVisit ? Colors.grey : (isCheckedInCurrentVisit ? Colors.green.shade700 : Colors.black),
                                                      fontWeight: isDoneInOtherVisit ? FontWeight.normal : (isCheckedInCurrentVisit ? FontWeight.bold : FontWeight.normal),
                                                      decoration: isDoneInOtherVisit ? TextDecoration.lineThrough : null,
                                                  )),
                                              // إذا تم في زيارة أخرى، يظهر كمؤشر مختار ولكن معطل
                                              value: isDoneInOtherVisit || isCheckedInCurrentVisit,
                                              onChanged: isDoneInOtherVisit ? null : (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    allPHD[i].treatment = allPHD[i]
                                                                .treatment
                                                                .isEmpty
                                                            ? label
                                                            : "$label\n${allPHD[i].treatment}";
                                                  } else {
                                                    allPHD[i].treatment =
                                                        allPHD[i]
                                                            .treatment
                                                            .replaceFirst(
                                                                "$label\n", "")
                                                            .replaceFirst(
                                                                label, "")
                                                            .trim();
                                                  }
                                                  PHD_edit[i] = true;
                                                });
                                              },
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Invoice Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  VMSalesInvoice =
                                      ViewModelSalesInvoices.impty();
                                  VMSalesInvoice.AccountingPerson_select_name =
                                      widget.Patients.name;
                                  VMSalesInvoice.selecedId(
                                      widget.Patients.name);
                                });
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const SalesInvoices()));
                              },
                              icon: const Icon(Icons.receipt_long_rounded,
                                  color: Colors.white),
                              label: const Text("إنشاء فاتورة لهذه الزيارة",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                                elevation: 4,
                                shadowColor: Colors.orange.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget FourPage(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFF1D9D99),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          elevation: 15,
          child: const Icon(
            Icons.add_sharp,
            color: Color(0xFF1D9D99),
            size: 40.0,
            semanticLabel: 'إضافة الصور ',
          ),
          onPressed: () {
            AddSelectpic();
          },
        ),
        body: imageUrls.isEmpty
            ? const Center(
                child: Text(
                'لا يوجد صور في المعرض',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ))
            : photoGallery(),
      ),
    );
  }

  Future<void> AddSelectpic() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // LayoutBuilder is required to bound the infinite-width constraints
        // that Flutter's bottom sheet passes down before the layout is measured.
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Draggable indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'اختر مصدر الصورة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      // Camera is NOT supported on Windows desktop
                      if (!Platform.isWindows) ...[
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                String picName =
                                    "${(imageUrls.length + 1).toString().padLeft(4, '0')}-${widget.Patients.id}.jpg";
                                await imageSelector(
                                    context, "camera", picName, widget.Patients.id);
                                if (context.mounted) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D9D99),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.camera_alt_rounded, size: 24),
                              label: const Text("الكاميرا",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              String picName =
                                  "${(imageUrls.length + 1).toString().padLeft(4, '0')}-${widget.Patients.id}.jpg";
                              await imageSelector(
                                  context, "gallery", picName, widget.Patients.id);
                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D9D99).withOpacity(0.1),
                              foregroundColor: const Color(0xFF1D9D99),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.photo_library_rounded, size: 24),
                            label: const Text("استعراض الصور",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget photoGallery() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        String fileName = imageUrls[index].split(RegExp(r'[\\/]')).last;
        String validPath = p.join(extPicFolder, fileName);
        File imageFileObj = File(validPath);

        // Fallback for legacy images stored in the root /pic/ directory
        if (!imageFileObj.existsSync()) {
          final legacyPath = p.join(p.dirname(extPicFolder), fileName);
          if (File(legacyPath).existsSync()) {
            imageFileObj = File(legacyPath);
          }
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PhotoView(
                          imageProvider: FileImage(imageFileObj),
                          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFileObj, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.white54, size: 40),
                          SizedBox(height: 5),
                          Text('مفقودة', style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => DeletPic(index),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void DeletPic(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف الصورة", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("هل متأكد من رغبتك في حذف هذه الصورة؟", style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              DbPicture dbPicture = DbPicture();
              dbPicture.deletePicture(imageUrls[index]);
              setState(() {
                imageUrls.removeAt(index);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  'تم حذف الصورة بنجاح',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                duration: Duration(seconds: 2),
              ));
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  bool isPermmission = false;
  Future<void> listenForPermissionStatus() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      isPermmission = true;
      //print("Permission is true");
    } else {
      isPermmission = false;
      // print("Permission is false");
      listenForPermissionStatus();
    }
  }

  Widget showPicturs() {
    listenForPermissionStatus();
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "اضغظ لفتح الصورة",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GalleryImage(
                  numOfShowImages: imageUrls.length < 9 ? imageUrls.length : 9,
                  titleGallery: 'صور الأسنان',
                  imageUrls: imageUrls),
            ),
          ],
        ),
      ),
    );
  }

//********************** IMAGE PICKER
  Future imageSelector(BuildContext context, String pickerType, String picName,
      int projectId) async {
    switch (pickerType) {
      case "gallery": // GALLERY IMAGE PICKER
        imageFile = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 100);
        break;
      case "camera": // CAMERA CAPTURE CODE
        // ignore: unnecessary_cast
        imageFile = await picker.pickImage(
            source: ImageSource.camera, imageQuality: 100);
        break;
    }
    if (imageFile != null) {
      // Ensure the pic directory exists
      final picDir = Directory(extPicFolder);
      if (!await picDir.exists()) {
        await picDir.create(recursive: true);
      }
      
      String fullPath = p.join(extPicFolder, picName);
      
      try {
        // Robust copy which avoids drive/volume boundary issues on Windows
        await File(imageFile!.path).copy(fullPath);
      } catch (e) {
        // Fallback to saveTo if copy fails
        await imageFile!.saveTo(fullPath);
      }

      /// find Max No of Picture
      DbPicture dbPicture = DbPicture();
      dbPicture.lastPicture();

      /// add pic to Data Base
      dbPicture.addPicture(fullPath, projectId.toString());

      setState(() {
        imageUrls.add(fullPath);
      });
    } else {
      // print("You have not taken image");
    }
  }

  void selecedDoctorList() {
    DbEmployee dbEmployee = DbEmployee();
    dbEmployee.allEmployeesM().then((employees) {
      for (var doctor in employees) {
        if (doctor.jop == 'دكتور') {
          setState(() {
            if (!listDoctors.contains(doctor.name.toString())) {
              listDoctors.add(doctor.name.toString());
            }
            //print('ddddddddddddddddddddddddddddd=========  ${doctor.name}');
          });
        }
      }
    });
  }

  Future<DateTime?> pickDate(context) {
    return showDatePicker(
      context: context,
      initialDate: projectStartDate,
      firstDate: DateTime(1930),
      lastDate: DateTime(2520),
    );
  }

  Widget SixPage(BuildContext context) {
    // --- Statistics ---
    final now = DateTime.now();
    final upcoming = _patientAppointments.where((a) {
      try { return DateTime.parse(a.dateStart).isAfter(now); } catch (_) { return false; }
    }).length;
    final past = _patientAppointments.length - upcoming;

    // --- Group by date ---
    Map<String, List<DateModel>> grouped = {};
    for (var appt in _patientAppointments) {
      String dateKey = '';
      try {
        final dt = DateTime.parse(appt.dateStart);
        dateKey = '${dt.year}/${dt.month.toString().padLeft(2,'0')}/${dt.day.toString().padLeft(2,'0')}';
      } catch (_) {
        dateKey = appt.dateStart;
      }
      grouped.putIfAbsent(dateKey, () => []).add(appt);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        // --- Header ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
             color: Color(0xFF167774),
             borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    "مواعيد: ${widget.Patients.name}",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await _updateSelectedPlansDate();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text("موعد جديد", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF167774),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),

        // --- Stats Row ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _simpleStat("المجموع", _patientAppointments.length, Colors.blue),
              _simpleStat("القادمة", upcoming, Colors.green),
              _simpleStat("السابقة", past, Colors.orange),
            ],
          ),
        ),

        const Divider(height: 1),

        // --- List ---
        Expanded(
          child: _patientAppointments.isEmpty
              ? const Center(child: Text("لا توجد مواعيد مسجلة"))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, gi) {
                    final dateKey = sortedKeys[gi];
                    final dayAppts = grouped[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(dateKey, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700], fontSize: 14)),
                        ),
                        // Appointment Cards
                        ...dayAppts.map((appt) {
                          String startTime = "";
                          String endTime = "";
                          try {
                            final s = DateTime.parse(appt.dateStart);
                            final e = DateTime.parse(appt.dateEnd);
                            startTime = "${s.hour.toString().padLeft(2,'0')}:${s.minute.toString().padLeft(2,'0')}";
                            endTime = "${e.hour.toString().padLeft(2,'0')}:${e.minute.toString().padLeft(2,'0')}";
                          } catch (_) {}

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Time Row
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 18, color: Color(0xFF1D9D99)),
                                          const SizedBox(width: 8),
                                          Text("$startTime - $endTime", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D9D99))),
                                        ],
                                      ),
                                      // Delete Button
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 22),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () async {
                                          bool? confirm = await showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("حذف الموعد"),
                                              content: const Text("هل أنت متأكد من حذف هذا الموعد؟"),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("حذف")),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await dbDate.deletedate(appt.id);
                                            await _loadAppointments();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  // Doctor & Room
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.person, size: 16, color: Colors.blueGrey),
                                            const SizedBox(width: 6),
                                            Text("د. ${appt.doctorName}", style: const TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.room, size: 16, color: Colors.blueGrey),
                                          const SizedBox(width: 6),
                                          Text(appt.place, style: const TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Notes
                                  if (appt.note.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.note_alt, size: 16, color: Colors.orange),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            appt.note,
                                            style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _simpleStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget SevenPage(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                    "إجمالي الفواتير", _totalInvoices, Colors.red),
                _buildSummaryItem(
                    "إجمالي الواصل", _totalReceipts, Colors.green),
                _buildSummaryItem(
                    "المبلغ المتبقي", _remainingBalance, Colors.blue),
              ],
            ),
          ),
          Expanded(
            child: _unifiedFinancialRecords.isEmpty
                ? const Center(child: Text("لا توجد سجلات مالية"))
                : ListView.builder(
                    itemCount: _unifiedFinancialRecords.length,
                    itemBuilder: (context, index) {
                      final record = _unifiedFinancialRecords[index];
                      if (record is InvoiceModel) {
                        return _buildInvoiceCard(context, record);
                      } else if (record is accModel.InvoicesModel) {
                        return _buildAccountingInvoiceCard(context, record);
                      } else if (record is VoucherModel) {
                        return _buildVoucherCard(context, record);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, InvoiceModel inv) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.receipt, color: Colors.white),
        ),
        title: Text("${inv.treatmentName} (السن ${inv.toothNumber})",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text("فاتورة علاج | التاريخ: ${inv.invoiceDate.split(' ')[0]}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${inv.treatmentCost} ₪",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue),
                ),
                if (inv.isPaid)
                  const Text("مدفوع",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold))
                else
                  const Text("غير مدفوع",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.print, color: Colors.blue),
              onPressed: () async {
                // To print a clinical invoice, we fetch the corresponding accounting invoice
                try {
                  final accInvoices = await acc.DbInvoices()
                      .getInvoicesByAccount(widget.Patients.id.toString());
                  accModel.InvoicesModel? matching;
                  for (var a in accInvoices) {
                    if (a.id == inv.invoiceId) {
                      matching = a;
                      break;
                    }
                  }
                  if (matching != null) {
                    reportSalesInvoicePDF.fromInvoice(matching).inti();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text("لم يتم العثور على فاتورة محاسبية مرتبطة")));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("خطأ في الطباعة: $e")));
                }
              },
            ),
          ],
        ),
        onTap: () async {
          VMSalesInvoice = ViewModelSalesInvoices.impty();
          VMSalesInvoice.EditeMode = true;
          VMSalesInvoice.EditeAlreadyInvoices(inv.invoiceId.toString());
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SalesInvoices()))
              .then((_) => _loadInvoices());
        },
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, VoucherModel v) {
    bool isReceipt = v.className == 'قبض';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReceiptVoucherPage(
                        type: v.className,
                        voucher: v,
                        isEdit: true,
                      ))).then((_) => _loadVouchers());
        },
        leading: CircleAvatar(
          backgroundColor: isReceipt ? Colors.green : Colors.orange,
          child: Icon(isReceipt ? Icons.add_card : Icons.payment,
              color: Colors.white),
        ),
        title: Text(isReceipt ? "إيصال قبض" : "سند صرف",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${v.discription} | التاريخ: ${v.date}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${v.payment} ${v.currency}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isReceipt ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.print),
              color: isReceipt ? Colors.green : Colors.orange,
              onPressed: () async {
                reportVoucherPDF(v).inti();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountingInvoiceCard(
      BuildContext context, accModel.InvoicesModel inv) {
    bool isSales = inv.type == 'المبيعات' || inv.type == 'مبيعات';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSales ? Colors.indigo : Colors.brown,
          child: Icon(isSales ? Icons.shopping_bag : Icons.shopping_cart,
              color: Colors.white),
        ),
        title: Text(
            isSales
                ? "فاتورة مبيعات رقم ${inv.id.toString().padLeft(6, '0')}"
                : "فاتورة مشتريات رقم ${inv.id.toString().padLeft(6, '0')}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "${inv.discription.isNotEmpty ? inv.discription : 'بدون وصف'} | التاريخ: ${inv.date}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${inv.amount_all} ${inv.currency}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSales ? Colors.indigo : Colors.brown),
                ),
                Text(
                  inv.remaining == '0'
                      ? "مدفوعة بالكامل"
                      : "متبقي: ${inv.remaining}",
                  style: TextStyle(
                      color: inv.remaining == '0' ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.print, color: Colors.indigo),
              onPressed: () async {
                reportSalesInvoicePDF.fromInvoice(inv).inti();
              },
            ),
          ],
        ),
        onTap: () async {
          VMSalesInvoice = ViewModelSalesInvoices.impty();
          VMSalesInvoice.EditeMode = true;
          await VMSalesInvoice.EditeAlreadyInvoices(inv.id.toString());
          if (!context.mounted) return;
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SalesInvoices()))
              .then((_) => _loadVouchers());
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          "${value.toStringAsFixed(2)} ₪",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
