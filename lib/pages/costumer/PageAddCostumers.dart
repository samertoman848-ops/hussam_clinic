import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../db/patients/dbpatient.dart';
import '../../db/patients/dbpatienthealth.dart';
import '../../global_var/globals.dart';
import '../../main.dart';
import '../../model/patients/PatientHealthModel.dart';

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

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'معلومات عامة'),
    Tab(text: 'معلومات صحية'),
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
    // TODO: implement initState
    super.initState();
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
            bottom: const TabBar(
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
