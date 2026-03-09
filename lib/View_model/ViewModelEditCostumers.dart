import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hussam_clinc/model/patients/PatientHealthDoctorModel.dart';
import 'package:intl/intl.dart' as tt;
import '../../db/patients/dbpatient.dart';
import '../../db/patients/dbpatienthealth.dart';
import '../../global_var/globals.dart';
import '../../main.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/patients/PatientModel.dart';

class ViewModelEditCostumers {
  //ViewModelEditCostumers();
  late PatientModel Patients;
  DateTime projectStartDate = DateTime.now();
  List<PatienHealthtDoctorModel> allPHD = [];
  List<bool> PHD_edit = [];
  List<String> imageUrls = [];

  int paint_id = 1;
  var _patient_name, _patient_mobile, _patient_mobile2, _patient_fileNo;
  var _patient_resone;
  final _patient_worries = "نعم";
  var _patient_place, _patient_sex = 'ذكر';
  late final String _patient_birthDate =
      '${projectStartDate.day}/${projectStartDate.month}/${projectStartDate.year}';

  final _patient_status = 'أعزب';
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

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'معلومات عامة'),
    Tab(text: 'معلومات صحية'),
    Tab(text: 'تفاصيل العلاج'),
    Tab(text: 'صور الأسنان'),
  ];

  bool editCheck = true;
  bool editCheckhealth = false;
  bool editCheckHealthDoctor = false;

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          action: SnackBarAction(
            textColor: Colors.white,
            backgroundColor: Colors.pinkAccent,
            label: 'تعديل البيانات الشخصية ',
            onPressed: () {
              DbPatient dbPatient = DbPatient();
              dbPatient.updateFileNoPatient(
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
}
