import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../db/patients/dbpatient.dart';
import '../../db/patients/dbpatienthealth.dart';
import '../../global_var/globals.dart';
import '../../main.dart';
import '../../model/patients/PatientHealthModel.dart';
import 'package:hussam_clinc/db/patients/dbpatienthealthdoctor.dart';
import 'package:hussam_clinc/db/patients/dbpicture.dart';
import 'package:hussam_clinc/model/patients/PatientHealthDoctorModel.dart';
import 'package:intl/intl.dart' as tt;
import '../../db/dbemployee.dart';
import 'package:hussam_clinc/db/dbdate.dart';
import 'package:image_picker/image_picker.dart';
import '../../db/patients/dbtreatmentplans.dart';
import '../../db/patients/dbinvoices.dart';
import '../../model/patients/TreatmentPlanModel.dart';
import '../../model/patients/InvoiceModel.dart';
import '../../model/DatesModel.dart';
import '../../widgets/dental_chart.dart';
import '../../db/accounting/vouchers/dbvouchers.dart';
import '../../model/accounting/VoucherModel.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class PageAddCostumers extends StatefulWidget {
  const PageAddCostumers({super.key});
  @override
  State<PageAddCostumers> createState() => _PageAddCostumersState();
}

DateTime projectStartDate = DateTime.now();

class _PageAddCostumersState extends State<PageAddCostumers> {
  int paint_id = 1;
  var _costumer_name, _costumer_mobile, _costumer_mobile2, _costumer_fileNo;
  var _costumer_resone;
  var _costumer_worries = "نعم";
  var _costumer_place, _costumer_sex = 'ذكر';
  String _costumer_birthDate =
      '${projectStartDate.day}/${projectStartDate.month}/${projectStartDate.year}';
  var _costumer_status = 'أعزب';
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  GlobalKey<FormState> formstate2 = GlobalKey<FormState>();
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
  var _costumer_health;
  var _costumer_sensitive = false, _costumer_sensitive_Ex = "";
  var _costumer_surgical = false, _costumer_surgical_Ex = "";
  var _costumer_haemophilia = false, _costumer_haemophilia_Ex = "";
  var _costumer_drugs = false, _costumer_drugs_Ex = "";
  var _costumer_oralDiseases, _costumer_smoking = false;
  var _costumer_pregnant = false, _costumer_pregnant_Ex = "";
  var _costumer_lactating = false, _costumer_lactating_Ex = "";
  var _costumer_contraception = false, _costumer_contraception_Ex = "";

  // New Variables for additional tabs
  List<PatienHealthtDoctorModel> allPHD = [];
  List<bool> PHD_edit = [];
  List<String> imageUrls = [];
  List<String> listDoctors = [];
  String _currentTreatmentPlan = "";
  List<TreatmentPlanModel> treatmentPlans = [];
  DbTreatmentPlans dbTreatmentPlans = DbTreatmentPlans();
  DbInvoices dbInvoices = DbInvoices();
  DbDate dbDate = DbDate();
  List<DateModel> _patientAppointments = [];
  List<InvoiceModel> _patientInvoices = [];
  List<VoucherModel> _patientVouchers = [];
  final ImagePicker picker = ImagePicker();
  XFile? imageFile;
  var numberFormat = tt.NumberFormat("00000", "en_US");

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

  bool repeatCheck = false;
  bool repeatCheckhealth = false; //new record in health file
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  Future<void> addCostumers(context) async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      formdata.save();
      repeatCheck = false;
      for (int i = 0; i < allPatient.length; i++) {
        var paint = allPatient[i];
        if (int.parse(paint.fileNo) == int.parse(_costumer_fileNo)) {
          repeatCheck = true;
          i = allPatient.length - 1;
        }
      }
      if (repeatCheck == false) {
        DbPatient dbPatient = DbPatient();
        await dbPatient.addPatient(
            _costumer_name,
            _costumer_mobile,
            _costumer_mobile2,
            _costumer_sex,
            _costumer_status,
            _costumer_birthDate,
            _costumer_fileNo,
            _costumer_place,
            _costumer_resone,
            _costumer_worries);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            ' تم إضافة المريض بنجاح ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 4),
        ));
        repeatCheck = true;
        AllPatientList();
        if (allPatient.isNotEmpty) {
          paint_id = allPatient.last.id;
        }
        _loadPatientData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          action: SnackBarAction(
            textColor: Colors.white,
            backgroundColor: Colors.pinkAccent,
            label: 'تعديل الملف ',
            onPressed: () async {
              DbPatient dbPatient = DbPatient();
              await dbPatient.updateFileNoPatient(
                  _costumer_name,
                  _costumer_mobile,
                  _costumer_mobile2,
                  _costumer_sex,
                  _costumer_status,
                  _costumer_birthDate,
                  _costumer_fileNo,
                  _costumer_place,
                  _costumer_resone,
                  _costumer_worries);
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

  Future<void> addCostumerhealth(context) async {
    var formdata = formstate2.currentState;
    if (formdata!.validate()) {
      formdata.save();
      repeatCheck = false;
      repeatCheckhealth = false;

      /// check if the record if excesse or not
      for (int i = 0; i < allPatient.length; i++) {
        var paint = allPatient[i];
        if (int.parse(paint.fileNo) == int.parse(_costumer_fileNo)) {
          repeatCheck = true;
          paint_id = paint.id;
          i = allPatient.length - 1;
          break;
        }
      }

      if (repeatCheckhealth == false) {
        /// the record is not  execces you must add new record
        DbPatientHealth dbPatientHealth = DbPatientHealth();
        await dbPatientHealth.addPatientHealth(
            paint_id.toString(),
            _costumer_health,
            _costumer_sensitive.toString(),
            _costumer_sensitive_Ex,
            _costumer_surgical.toString(),
            _costumer_surgical_Ex,
            _costumer_haemophilia.toString(),
            _costumer_haemophilia_Ex,
            _costumer_drugs.toString(),
            _costumer_drugs_Ex,
            _costumer_oralDiseases,
            _costumer_smoking.toString(),
            _costumer_pregnant.toString(),
            _costumer_pregnant_Ex,
            _costumer_lactating.toString(),
            _costumer_lactating_Ex,
            _costumer_contraception.toString(),
            _costumer_contraception_Ex);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            ' تم إضافة  البيانات الصحية للمريض بنجاح ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 4),
        ));
        repeatCheckhealth = true;
        AllPatientList();
        copyExternalDB();
      } else {
        /// the record is execces you must update record
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          action: SnackBarAction(
            textColor: Colors.white,
            backgroundColor: Colors.pinkAccent,
            label: 'تعديل الملف ',
            onPressed: () async {
              DbPatientHealth dbPatientHealth = DbPatientHealth();
              PatienHealthtModel patienHealthtModel =
                  _PatienHealthtModel.empty();
              patienHealthtModel.patientId = paint_id.toString();
              patienHealthtModel.health = _costumer_health;
              patienHealthtModel.sensitive = _costumer_sensitive.toString();
              patienHealthtModel.sensitive_Ex = _costumer_sensitive_Ex;
              patienHealthtModel.surgical = _costumer_surgical.toString();
              patienHealthtModel.surgical_Ex = _costumer_surgical_Ex;
              patienHealthtModel.haemophilia = _costumer_haemophilia.toString();
              patienHealthtModel.haemophilia_Ex = _costumer_haemophilia_Ex;
              patienHealthtModel.drugs = _costumer_drugs.toString();
              patienHealthtModel.drugs_Ex = _costumer_drugs_Ex;
              patienHealthtModel.oralDiseases = _costumer_oralDiseases;
              patienHealthtModel.smoking = _costumer_smoking.toString();
              patienHealthtModel.pregnant = _costumer_pregnant.toString();
              patienHealthtModel.pregnant_Ex = _costumer_pregnant_Ex;
              patienHealthtModel.lactating = _costumer_lactating.toString();
              patienHealthtModel.lactating_Ex = _costumer_lactating_Ex;
              patienHealthtModel.contraception =
                  _costumer_contraception.toString();
              patienHealthtModel.contraception_Ex = _costumer_contraception_Ex;

              await dbPatientHealth.updatePatientHealth(
                  int.parse(paint_id.toString()), patienHealthtModel);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  ' تم تعديل بيانات المريض بنجاح ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                duration: Duration(seconds: 4),
              ));
              AllPatientList();
              copyExternalDB();
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
      copyExternalDB();
    }
  }

  @override
  void initState() {
    super.initState();
    selecedDoctorList();
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
          });
        }
      }
    });
  }

  Map<String, List<int>> getGroupedPlannedTreatments() {
    Map<String, List<int>> grouped = {};
    for (var plan in treatmentPlans) {
      if (!plan.isCompleted) {
        if (!grouped.containsKey(plan.treatmentName)) {
          grouped[plan.treatmentName] = [];
        }
        grouped[plan.treatmentName]!.add(int.parse(plan.toothNumber));
      }
    }
    return grouped;
  }

  Future<void> _loadPatientData() async {
    if (paint_id == 0) return;

    // Load treatments
    DbPatientHealthDoctor dbPHD = DbPatientHealthDoctor();
    dbPHD.searchByPatientId(paint_id).then((value) {
      setState(() {
        allPHD = value;
        PHD_edit = List.generate(allPHD.length, (index) => false);
        for (var record in value) {
          if (record.treatment.contains("[الخطة العلاجية:")) {
            _currentTreatmentPlan = record.treatment;
            break;
          }
        }
      });
    });

    // Load images
    DbPicture dbPicture = DbPicture();
    dbPicture.searchPictureByPatientId(paint_id.toString()).then((picList) {
      setState(() {
        imageUrls = picList.map((pic) => pic.pictureLocation).toList();
      });
    });

    // Load appointments
    List<DateModel> allAppts = await dbDate.alldate();
    setState(() {
      _patientAppointments = allAppts
          .where((d) => d.costumerId == paint_id.toString())
          .toList();
    });

    // Load invoices
    List<InvoiceModel> invoices = await dbInvoices.getInvoicesByPatient(paint_id);
    setState(() {
      _patientInvoices = invoices;
    });

    // Load vouchers
    String accId = paint_id.toString();
    try {
      final p = allPatient.firstWhere((p) => p.id == paint_id);
      accId = p.fileNo;
    } catch (_) {}

    final res = await DbVouchers().getVouchersByAccount(accId);
    final List<Map<String, dynamic>> finalRes = List.from(res);
    // Add old format if exists (by ID)
    if (accId != paint_id.toString()) {
      final oldRes = await DbVouchers().getVouchersByAccount(paint_id.toString());
      for (var v in oldRes) {
        if (!finalRes.any((element) => element['voucher_id'] == v['voucher_id'])) {
          finalRes.add(v);
        }
      }
    }
    setState(() {
      _patientVouchers = finalRes.map((e) => VoucherModel.fromMap(e)).toList();
    });

    // Load Treatment Plans
    _loadTreatmentPlans();
  }

  Future<void> _loadTreatmentPlans() async {
    try {
      List<TreatmentPlanModel> plans =
          await dbTreatmentPlans.getTreatmentPlansByPatient(paint_id);
      setState(() {
        treatmentPlans = plans;
      });
    } catch (e) {
      debugPrint("Error loading treatment plans: $e");
    }
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
    //late final TabController controllerForMyStful1 = TabController( length: 3, vsync: this,initialIndex: 0 );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: myTabs.length,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xFF1D9D99),
          appBar: AppBar(
            title: const Text('إضافة المرضى',
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

  Widget FisrtPage(BuildContext context) {
    // _tabController.index=1;
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
                        initialValue: MaxFiledNo,
                        onSaved: (val) {
                          _costumer_fileNo = val!;
                        },
                        validator: (val) {
                          if (val!.length > 9) {
                            return " يجب أن لا يكون الاسم أقل من 9 أرقام";
                          }
                          if (val.length < 2) {
                            return "يجب أن يكون رقم الملف أكثر من رقمين";
                          }
                          return null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'\d')),
                        ],
                        // validate after each user interaction
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        onSaved: (val) {
                          _costumer_name = val;
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
                          // Initial Value
                          value: _costumer_sex,
                          hint: const Text('الجنس'),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_downward),
                          isExpanded: true,
                          selectedItemBuilder: (BuildContext context) {
                            //<-- SEE HERE
                            return costumer_sex_items.map((String value) {
                              return Center(
                                child: Text(
                                  _costumer_sex,
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
                              _costumer_sex = value.toString();
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
                              validator: (val) {
                                if (val!.length > 10) {
                                  return "لا يكون الاسم أكثر من 10 حرفا";
                                }
                                if (val.length < 10) {
                                  return "لا يكون الاسم أقل من 10 أحرف";
                                }
                                return null;
                              },
                              onSaved: (val) {
                                _costumer_mobile = val;
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
                              // validate after each user interaction
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
                              onSaved: (val) {
                                _costumer_mobile2 = val;
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
                  validator: (val) {
                    if (val!.length > 50) {
                      return " يجب أن لا يكون الاسم أكثر من 50 حرفا";
                    }
                    if (val.length < 4) {
                      return " يجب أن لا يكون الاسم أقل من 4 أحرف";
                    }
                    return null;
                  },
                  onSaved: (val) {
                    _costumer_place = val;
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
                          value: _costumer_status,
                          hint: const Text('الحالة الاجتماعية'),
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_downward),
                          isExpanded: true,
                          selectedItemBuilder: (BuildContext context) {
                            //<-- SEE HERE
                            return costumer_status_items.map((String value) {
                              return Center(
                                child: Text(
                                  _costumer_status,
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
                              _costumer_status = value.toString();
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
                                  // projectStartDate = date;
                                  setState(() {
                                    _costumer_birthDate =
                                        '${date.day}/${date.month}/${date.year}';
                                    projectStartDate = date;
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
                        onSaved: (val) {
                          _costumer_resone = val;
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
                                  value: _costumer_worries,
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
                                          _costumer_worries,
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
                                      _costumer_worries = value.toString();
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
                          addCostumers(context);
                        });
                      },
                      style: repeatCheck == false ? FirstClick : SecondClick,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'احفظ البيانات ',
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

  //  _costumer_oralDiseases,_costumer_smoking;
  //  _costumer_pregnant,_costumer_pregnant_Ex;
  //  _costumer_lactating,_costumer_lactating_Ex;
  //  _costumer_contraception,_costumer_contraception_Ex;

  Widget SecondPage(BuildContext context) {
    // _tabController.index=1;
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
                // _costumer_health
                /** اذكر المشاكل الصحية **/
                TextFormField(
                  maxLines: 2,
                  initialValue: _costumer_health,
                  onSaved: (val) {
                    _costumer_health = val!;
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
                      flex: _costumer_sensitive == true ? 2 : 7,
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
                          mainAxisAlignment: _costumer_sensitive == true
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
                              value: _costumer_sensitive,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_sensitive = value!;
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
                      flex: _costumer_sensitive == true ? 2 : 1,
                      child: _costumer_sensitive == true
                          ? TextFormField(
                              onSaved: (val) {
                                _costumer_sensitive_Ex = val!;
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
                      flex: _costumer_surgical == true ? 2 : 7,
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
                          mainAxisAlignment: _costumer_surgical == true
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
                              value: _costumer_surgical,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_surgical = value!;
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
                      flex: _costumer_surgical == true ? 2 : 1,
                      child: _costumer_surgical == true
                          ? TextFormField(
                              onSaved: (val) {
                                _costumer_surgical_Ex = val!;
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
                      flex: _costumer_haemophilia == true ? 3 : 7,
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
                          mainAxisAlignment: _costumer_haemophilia == true
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
                              value: _costumer_haemophilia,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_haemophilia = value!;
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
                      flex: _costumer_haemophilia == true ? 2 : 1,
                      child: _costumer_haemophilia == true
                          ? TextFormField(
                              onSaved: (val) {
                                _costumer_haemophilia_Ex = val!;
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
                      flex: _costumer_drugs == true ? 2 : 7,
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
                          mainAxisAlignment: _costumer_drugs == true
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
                              value: _costumer_drugs,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_drugs = value!;
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
                      flex: _costumer_drugs == true ? 2 : 1,
                      child: _costumer_drugs == true
                          ? TextFormField(
                              onSaved: (val) {
                                _costumer_drugs_Ex = val!;
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
                        initialValue: _costumer_oralDiseases,
                        onSaved: (val) {
                          _costumer_oralDiseases = val!;
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
                              value: _costumer_smoking,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_smoking = value!;
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
                      flex: _costumer_pregnant == true ? 1 : 7,
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
                              value: _costumer_pregnant,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_pregnant = value!;
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
                      flex: _costumer_pregnant == true ? 2 : 1,
                      child: _costumer_pregnant == true
                          ? TextFormField(
                              onSaved: (val) {
                                _costumer_pregnant_Ex = val!;
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
                      flex: _costumer_lactating == true ? 1 : 7,
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
                              value: _costumer_lactating,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_lactating = value!;
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
                      flex: _costumer_lactating == true ? 2 : 1,
                      child: _costumer_lactating == true
                          ? TextFormField(
                              onSaved: (val) {
                                _costumer_lactating_Ex = val!;
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
                      flex: _costumer_contraception == true ? 1 : 7,
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
                              value: _costumer_contraception,
                              onChanged: (bool? value) {
                                setState(() {
                                  _costumer_contraception = value!;
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
                      flex: _costumer_contraception == true ? 2 : 1,
                      child: _costumer_contraception == true
                          ? TextFormField(
                              onSaved: (val) {
                                _costumer_contraception_Ex = val!;
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
                          if (repeatCheck == false) {
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
                            if (repeatCheckhealth == false) {
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
                              repeatCheckhealth = true;
                            } else {
                              addCostumerhealth(context);

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                  'لم يتم إضافة البيانات الصحية هل تريد تعديل البيانات؟',
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
                      style:
                          repeatCheckhealth == false ? FirstClick : SecondClick,
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

  Future<DateTime?> pickDate(context) {
    return showDatePicker(
      context: context,
      initialDate: projectStartDate,
      firstDate: DateTime(1930),
      lastDate: DateTime(2520),
    );
  }

  Widget _buildNotSavedMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 80, color: Colors.amber),
          SizedBox(height: 20),
          Text(
            "يرجى حفظ البيانات الشخصية للمريض أولاً",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text("لتتمكن من الوصول لهذه التبويبات"),
        ],
      ),
    );
  }

  Widget FivePage(BuildContext context) {
    if (paint_id == 1 && repeatCheck == false) return _buildNotSavedMessage();
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("الخطة العلاجية المقترحة",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF167774))),
              const Divider(thickness: 2),
              DentalChartWidget(
                initialTreatmentText: _currentTreatmentPlan,
                doctors: listDoctors,
                onChanged: (val) => setState(() => _currentTreatmentPlan = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Save logic would go here, similar to PageEditCostumers
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم تحديث الرسم البياني")));
                },
                child: const Text("حفظ التغييرات في الرسم"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ThirdPage(BuildContext context) {
    if (paint_id == 1 && repeatCheck == false) return _buildNotSavedMessage();
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF167774),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("سجل الزيارات والعمليات",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Logic to add a new visit record
                    DbPatientHealthDoctor dbPHD = DbPatientHealthDoctor();
                    PatienHealthtDoctorModel newRecord = PatienHealthtDoctorModel({
                      "PHD_id": 0,
                      "PHD_patientId": paint_id.toString(),
                      "PHD_doctorId": "1",
                      "PHD_doctorName": listDoctors.isNotEmpty ? listDoctors[0] : "طبيب",
                      "PHD_treatment": "",
                      "PHD_date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                    });
                    await dbPHD.addPHD(
                      newRecord.patientId,
                      newRecord.doctorId,
                      newRecord.doctorName,
                      newRecord.date,
                      newRecord.treatment,
                      "", // Diagnosis
                    );
                    _loadPatientData();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("إضافة زيارة"),
                ),
              ],
            ),
          ),
          Expanded(
            child: allPHD.isEmpty
                ? const Center(child: Text("لا توجد زيارات مسجلة لهذا المريض"))
                : ListView.builder(
                    itemCount: allPHD.length,
                    itemBuilder: (context, i) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          title: Text("زيارة بتاريخ: ${allPHD[i].date}"),
                          subtitle: Text("الطبيب: ${allPHD[i].doctorName}"),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    initialValue: allPHD[i].treatment,
                                    maxLines: 3,
                                    decoration: const InputDecoration(labelText: "تفاصيل العلاج"),
                                    onChanged: (val) => allPHD[i].treatment = val,
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await DbPatientHealthDoctor().updatePHD(allPHD[i].id, allPHD[i]);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم الحفظ")));
                                    },
                                    child: const Text("حفظ التعديلات"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget FourPage(BuildContext context) {
    if (paint_id == 1 && repeatCheck == false) return _buildNotSavedMessage();
    return Scaffold(
      backgroundColor: const Color(0xFF1D9D99),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => _showImageSourceActionSheet(context),
        child: const Icon(Icons.add_a_photo, color: Color(0xFF1D9D99)),
      ),
      body: imageUrls.isEmpty
          ? const Center(child: Text("لا توجد صور ملفقة بعد", style: TextStyle(color: Colors.white)))
          : GridView.builder(
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(imageFileObj, fit: BoxFit.cover),
                        ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            imageUrls.removeAt(index);
                          });
                        },
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
            ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('الكاميرا'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      // Ensure the pic directory exists
      final picDir = Directory(extPicFolder);
      if (!await picDir.exists()) {
        await picDir.create(recursive: true);
      }

      String picName = "${(imageUrls.length + 1).toString().padLeft(4, '0')}-${paint_id}.jpg";
      String fullPath = p.join(extPicFolder, picName);
      
      try {
        await File(pickedFile.path).copy(fullPath);
      } catch (e) {
        await pickedFile.saveTo(fullPath);
      }

      DbPicture dbPicture = DbPicture();
      await dbPicture.addPicture(fullPath, paint_id.toString());
      
      setState(() {
        imageUrls.add(fullPath);
      });
    }
  }

  Widget SixPage(BuildContext context) {
    if (paint_id == 1 && repeatCheck == false) return _buildNotSavedMessage();
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF167774),
            child: const Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "سجل المواعيد",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _patientAppointments.isEmpty
                ? const Center(child: Text("لا توجد مواعيد مسجلة"))
                : ListView.builder(
                    itemCount: _patientAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = _patientAppointments[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1D9D99),
                            child: Text((index + 1).toString(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text("${appt.dateStart}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("الدكتور: ${appt.doctorName}"),
                              if (appt.note.isNotEmpty)
                                Text("ملاحظات: ${appt.note}",
                                    style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirm = await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("حذف الموعد"),
                                  content: const Text("هل أنت متأكد؟"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("إلغاء")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text("حذف")),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await dbDate.deletedate(appt.id);
                                _loadPatientData();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget SevenPage(BuildContext context) {
    if (paint_id == 1 && repeatCheck == false) return _buildNotSavedMessage();
    
    // Combine and sort all financial records
    List<dynamic> allRecords = [..._patientInvoices, ..._patientVouchers];

    // Sort logic (dd/MM/yyyy format)
    allRecords.sort((a, b) {
      String dateA = a is InvoiceModel ? a.invoiceDate : (a as VoucherModel).date;
      String dateB = b is InvoiceModel ? b.invoiceDate : (b as VoucherModel).date;

      try {
        DateTime dtA = tt.DateFormat("dd/MM/yyyy").parse(dateA.split(' ')[0]);
        DateTime dtB = tt.DateFormat("dd/MM/yyyy").parse(dateB.split(' ')[0]);
        return dtA.compareTo(dtB);
      } catch (e) {
        return dateA.compareTo(dateB);
      }
    });

    double totalInvoices = _patientInvoices.fold(0.0, (sum, item) => sum + item.treatmentCost);

    double totalReceipts = _patientVouchers
        .where((v) => v.className == 'قبض')
        .fold(0.0, (sum, v) => sum + (double.tryParse(v.payment) ?? 0.0));

    double totalPayments = _patientVouchers
        .where((v) => v.className == 'صرف')
        .fold(0.0, (sum, v) => sum + (double.tryParse(v.payment) ?? 0.0));

    double remainingBalance = totalInvoices + totalPayments - totalReceipts;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              border: const Border(bottom: BorderSide(color: Color(0xFFD6D6D6))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("إجمالي الفواتير", totalInvoices, Colors.blue),
                _buildSummaryItem("إجمالي المدفوعات", totalReceipts, Colors.green),
                _buildSummaryItem("الرصيد المتبقي", remainingBalance, Colors.red),
              ],
            ),
          ),

          Expanded(
            child: allRecords.isEmpty
                ? const Center(child: Text("لا توجد سجلات مالية مسجلة"))
                : ListView.builder(
                    itemCount: allRecords.length,
                    itemBuilder: (context, index) {
                      final record = allRecords[index];
                      if (record is InvoiceModel) {
                        return _buildInvoiceCard(record);
                      } else {
                        return _buildVoucherCard(record as VoucherModel);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel inv) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.receipt, color: Colors.white),
        ),
        title: Text("${inv.treatmentName} (السن ${inv.toothNumber})", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("فاتورة علاج | التاريخ: ${inv.invoiceDate.split(' ')[0]}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${inv.treatmentCost} ج.م",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
            ),
            if (inv.isPaid)
              const Text("مدفوع", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))
            else
              const Text("غير مدفوع", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(VoucherModel v) {
    bool isReceipt = v.className == 'قبض';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isReceipt ? Colors.green : Colors.orange,
          child: Icon(isReceipt ? Icons.add_card : Icons.payment, color: Colors.white),
        ),
        title: Text(isReceipt ? "إيصال قبض" : "سند صرف", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${v.discription} | التاريخ: ${v.date}"),
        trailing: Text(
          "${v.payment} ج.م",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isReceipt ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

/// classes
class _PatienHealthtModel extends PatienHealthtModel {
  _PatienHealthtModel.empty()
      : super({
          'PH_id': '',
          "PH_patientId": '',
          "PH": '',
          "PH_sensitive": '',
          "PH_sensitive_Ex": '',
          "PH_surgical": '',
          "PH_surgical_Ex": '',
          "PH_haemophilia": '',
          "PH_haemophilia_Ex": '',
          "PH_drugs": '',
          "PH_drugs_Ex": '',
          "PH_oralDiseases": '',
          "PH_smoking": '',
          "PH_pregnant": '',
          "PH_pregnant_Ex": '',
          "PH_lactating": '',
          "PH_lactating_Ex": '',
          "PH_contraception": '',
          "PH_contraception_Ex": ''
        });
}
