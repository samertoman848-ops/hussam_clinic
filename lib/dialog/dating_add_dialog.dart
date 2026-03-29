import 'dart:math';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/dbdate.dart';
import 'package:hussam_clinc/db/dbrooms.dart';
import 'package:hussam_clinc/db/patients/dbpatient.dart';
import 'package:hussam_clinc/model/Employment/EmployeeModel.dart';
import 'package:hussam_clinc/themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart' as picked;
import 'package:timetable/timetable.dart';
import '../data/positioning_demo.dart';
import '../db/dbemployee.dart';
import '../main.dart';
import '../model/patients/PatientModel.dart';
import '../widgets/TimePickerWithBookedHours.dart';

class DatingAddDialog extends StatefulWidget {
  final String title, positiveBtnText, negativeBtnText;
  final String? patientName;
  const DatingAddDialog({
    super.key,
    required this.title,
    required this.positiveBtnText,
    required this.negativeBtnText,
    this.patientName,
  });
  @override
  State<StatefulWidget> createState() => _DatingAddDialogState();
}

class _DatingAddDialogState extends State<DatingAddDialog> {
  List<String> listPersons = [];
  List<String> listDoctors = [];
  List<String> listChecks = [];
  List<String> datePlaceList = []; // الآن قائمة ديناميكية
  List<picked.TimeRange>? disabledListedTime = [];
  List<Color>? disabledListedColor = [];
  List checks_list = [];
  final String positiveBtnText = "حفظ";
  final String negativeBtnText = "إلفاء الأمر";
  final String title = "إضافة موعد جديد";
  final _datePlace = GlobalKey<FormState>();

  List<String> get uniqueDoctors => listDoctors.toSet().toList();
  List<String> get uniquePersons => listPersons.toSet().toList();
  final TextEditingController _dateNote = TextEditingController();

  String datePlace = "";
  String selectPatintList = "";
  String selectDoctorList = "";
  String selectPatintID = "";
  String selectDoctorID = "";
  DateTime dateDate = DateTime.now();
  TimeOfDay StartTime = TimeOfDay.now();
  TimeOfDay EndTime = TimeOfDay(
    hour: TimeOfDay.now().hour,
    minute: TimeOfDay.now().minute + 10,
  );
  TimeOfDay ChangeTime = TimeOfDay.now();
  DateTime Start = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime End = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  String dateNote = "";

  void selecedtdatePlaceList() {
    datePlace = datePlaceList.contains(datePlace)
        ? datePlace
        : datePlaceList.isNotEmpty
            ? datePlaceList[0]
            : "";
  }

  Future<void> _loadRooms() async {
    DbRooms dbRooms = DbRooms();
    await dbRooms.ensureDefaultRooms();
    final rooms = await dbRooms.allRooms();
    setState(() {
      datePlaceList = rooms.map((room) => room.name).toList();
      selecedtdatePlaceList();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.patientName != null && widget.patientName!.isNotEmpty) {
      selectPatintList = widget.patientName!;
    }
    for (int i = 0; i < 50; i++) {
      disabledListedColor!.add(
        Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
      );
    }
    _loadRooms().then((_) {
      CheckDated(dateDate, datePlace, selectDoctorList);
    });
    selecedPatientList().then((_) {
      // After loading patients, lookup selected patient ID
      if (selectPatintList.isNotEmpty) {
        selecedPatientId(selectPatintList);
      }
    });
    selecedDoctorList().then((_) {
      // After loading doctors, lookup selected doctor ID
      if (selectDoctorList.isNotEmpty) {
        selecedDoctorId(selectDoctorList);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine active values locally for this build frame
    // without modifying the state fields directly during build.
    
    String activePatient = selectPatintList;
    if (uniquePersons.isNotEmpty && !uniquePersons.contains(activePatient)) {
      activePatient = uniquePersons.first;
    }

    String activeDoctor = selectDoctorList;
    if (uniqueDoctors.isNotEmpty && !uniqueDoctors.contains(activeDoctor)) {
      activeDoctor = uniqueDoctors.first;
    }

    if (uniquePersons.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context, activePatient, activeDoctor),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context, String activePatient, String activeDoctor) {
    // Determine active datePlace locally
    String activeDatePlace = datePlace;
    if (datePlaceList.isNotEmpty && !datePlaceList.contains(activeDatePlace)) {
      activeDatePlace = datePlaceList.first;
    }

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                // Bottom rectangular box
                margin: const EdgeInsets.only(
                  top: 40,
                ), // to push the box half way below circle
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 8,
                  right: 8,
                ), // spacing inside the box
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: CustomTheme.lightTheme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 400,
                      child: GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: textEditFisrtPage(context, activePatient, activeDoctor, activeDatePlace),
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                // Top Circle with icon
                maxRadius: 40.0,
                child: Icon(Icons.add_alert_rounded, size: 50),
              ),
            ],
          ),
        ),
      );
  }

  Widget textEditFisrtPage(BuildContext context, String activePatient, String activeDoctor, String activeDatePlace) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            const SizedBox(height: 15),
            // Date
            TextButton(
              onPressed: () async {
                final date = await pickDate(context);
                if (date == null) return;
                setState(() {
                  dateDate = date;
                  CheckDated(dateDate, datePlace, selectDoctorList);
                  Start = date;
                  End = date;
                });
              },
              child: SizedBox(
                height: 30,
                child: Row(
                  children: [
                    const Text(
                      'التاريخ  :  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${dateDate.year}/${dateDate.month}/${dateDate.day}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            //  "اسم الدكتور"
            DropdownButtonFormField(
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 18,
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.blue,
                size: 30,
              ),
              alignment: AlignmentDirectional.centerEnd,
              decoration: const InputDecoration(
                labelText: " اسم الدكتور ",
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 18,
                ),
                prefixIcon: Icon(Icons.person, color: Colors.blue, size: 35),
              ),
              initialValue: activeDoctor,
              items: uniqueDoctors.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(minHeight: 48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(e, style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onTap: () {},
              onChanged: (val) {
                selectDoctorList = val as String;
                CheckDated(dateDate, datePlace, selectDoctorList);
                selecedDoctorId(selectDoctorList);
              },
            ),
            const SizedBox(height: 5),
            //  " المكان "
            DropdownButtonFormField(
              key: _datePlace,
              alignment: AlignmentDirectional.center,
              initialValue: activeDatePlace,
              items: datePlaceList.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Text(e, style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  datePlace = val as String;
                  CheckDated(dateDate, datePlace, selectDoctorList);
                });
              },
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.blue,
                size: 35,
              ),
              decoration: InputDecoration(
                labelText: "رقم الغرفة",
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 18,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 2.0, end: 3),
                  child: Image.asset(
                    "assets/icon/dentist_chair.png",
                    width: 40,
                    height: 40,
                    color: Colors.blue,
                  ), // _myIcon is a 48px-wide widget.
                ),
              ),
            ),
            const SizedBox(height: 5),
            // استخدام الـ widget المخصص لعرض منتقي الوقت مع الأوقات المحجوزة
            TimePickerWithBookedHours(
              context: context,
              startTime: StartTime,
              endTime: EndTime,
              disabledTimes: disabledListedTime,
              disabledColors: disabledListedColor,
              onStartChange: (start) {
                setState(() => StartTime = start);
              },
              onEndChange: (end) {
                setState(() => EndTime = end);
              },
            ),
            const SizedBox(height: 5),
            DropdownSearch<String>(
              items: (filter, loadProps) => uniquePersons,
              decoratorProps: DropDownDecoratorProps(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person, color: Colors.blue, size: 35),
                  labelText: "اسم المريض",
                  hintText: "اختار اسم المريض",
                ),
                baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 18,
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                fit: FlexFit.loose,
                searchFieldProps: TextFieldProps(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'ابحث باسم المريض',
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectPatintList = value ?? '';
                  selecedPatientId(selectPatintList);
                });
              },
              selectedItem: activePatient,
            ),

            const SizedBox(height: 2),
            TextFormField(
              controller: _dateNote,
              maxLines: 3,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  dateNote = value;
                }
              },
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                icon: Icon(
                  Icons.note_alt_rounded,
                  size: 35,
                  color: Colors.blue,
                ),
                labelText: ' الملاحظات',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                errorStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'يجب أن لا يكون فارغاً';
                }
                if (text.isEmpty) {
                  return 'الرقم صغير يجب أن لا يقل عن 1';
                }
                return null;
              },
            ),
            Divider(),
            const SizedBox(height: 5),
            TextButton(
              onPressed: () {
                setState(() {
                  if ((StartTime.hour == EndTime.hour &&
                          StartTime.minute > EndTime.minute) ||
                      StartTime.hour > EndTime.hour) {
                    ChangeTime = EndTime;
                    EndTime = StartTime;
                    StartTime = ChangeTime;
                  }
                  Start =
                      DateTime(dateDate.year, dateDate.month, dateDate.day).add(
                    Duration(
                      hours: StartTime.hour,
                      minutes: StartTime.minute,
                    ),
                  );
                  End = DateTime(
                    dateDate.year,
                    dateDate.month,
                    dateDate.day,
                  ).add(Duration(hours: EndTime.hour, minutes: EndTime.minute));
                });
                if (StartTime.hour == EndTime.hour &&
                    (StartTime.minute == EndTime.minute ||
                        (EndTime.minute - StartTime.minute).abs() < 9)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        ' لم يتم إضافة الموعد لأن موعد البداية أكثر بعشر دقائق  ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم إضافة الموعد',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );
                  DbDate dbDate = DbDate();
                  dbDate.adddate(
                    'مواعيد المرضى',
                    datePlace,
                    Start.toString(),
                    End.toString(),
                    dateNote,
                    selectDoctorID,
                    selectDoctorList,
                    selectPatintID,
                    selectPatintList,
                  );
                  Navigator.of(context).pop(Start);
                  //refreshList();
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'احفظ الموعد',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Icon(Icons.save_outlined, size: 30),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<DateTime?> pickDate(context) {
    return showDatePicker(
      context: context,
      initialDate: dateDate,
      firstDate: DateTime(2019),
      lastDate: DateTime(2620),
      locale: const Locale('ar'),
    );
  }

  void CheckDated(DateTime date, String room, String DoctorName) {
    disabledListedTime!.clear();
    // Add night time (21:00 - 08:00)
    disabledListedTime!.add(
      picked.TimeRange(
        startTime: const TimeOfDay(hour: 21, minute: 0),
        endTime: const TimeOfDay(hour: 8, minute: 0),
      ),
    );
    // Add default disabled time (8 AM - 9 AM)
    disabledListedTime!.add(
      picked.TimeRange(
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 9, minute: 0),
      ),
    );

    for (var dating in allDatesList) {
      DateTime timeStart = DateTime.parse(dating.dateStart);
      DateTime timeEnd = DateTime.parse(dating.dateEnd);

      if (timeStart.year == date.year &&
          timeStart.month == date.month &&
          timeStart.day == date.day) {
        if (dating.doctorName == DoctorName || dating.place == room) {
          disabledListedTime!.add(
            picked.TimeRange(
              startTime: TimeOfDay(
                hour: timeStart.hour,
                minute: timeStart.minute,
              ),
              endTime: TimeOfDay(hour: timeEnd.hour, minute: timeEnd.minute),
            ),
          );
        }
      }
    }
  }

  Future<void> selecedPatientList() async {
    DbPatient dbPatient = DbPatient();
    final patients = await dbPatient.allPatients();
    if (mounted) {
      setState(() {
        listPersons.clear();
        for (var patient in patients) {
          if (patient.name.isNotEmpty) {
            listPersons.add(patient.name.toString());
          }
        }
      });
    }
  }

  Future<void> selecedPatientId(String name) async {
    DbPatient dbPatient = DbPatient();
    final patientList = await dbPatient.searchingPatient(name);
    for (var item in patientList) {
      if (mounted) {
        setState(() {
          PatientModel Patien = PatientModel.fromMap(item);
          selectPatintID = Patien.id.toString();
        });
      }
    }
  }

  Future<void> selecedDoctorId(String name) async {
    DbEmployee dbEmployee = DbEmployee();
    final employeeList = await dbEmployee.searchingEmployee(name);
    for (var item in employeeList) {
      if (mounted) {
        setState(() {
          EmployeeModel doctor = EmployeeModel.fromMap(item);
          selectDoctorID = doctor.id.toString();
        });
      }
    }
  }

  Future<void> selecedDoctorList() async {
    DbEmployee dbEmployee = DbEmployee();
    final employees = await dbEmployee.allEmployees();
    if (mounted) {
      setState(() {
        listDoctors.clear();
        for (var item in employees) {
          EmployeeModel employee = EmployeeModel.fromMap(item);
          if (employee.jop == 'دكتور') {
            listDoctors.add(employee.name.toString());
          }
        }
      });
    }
  }

  void addNewDate(String title, DateTime Start, DateTime End, String place) {
    DbDate dbDate = DbDate();
    int id = 1;
    dbDate.lastDate().then((value) {
      setState(() {
        id = value.id;
      });
    });
    Future.delayed(const Duration(seconds: 1), () {
      int noOfclass = 1;
      if (place == 'غرفة 1') {
        noOfclass = 2;
      } else if (place == 'غرفة 2') {
        noOfclass = 3;
      } else if (place == 'غرفة 3') {
        noOfclass = 4;
      }
      positioningDemoEvents.add(_DemoEvent(id, title, noOfclass, Start, End));
    });
  }
}

class _DemoEvent extends BasicEvent {
  _DemoEvent(
    int demoId,
    String title,
    int classification,
    DateTime start,
    DateTime end,
  ) : super(
          id: '$demoId',
          title: title,
          backgroundColor: _getColor(classification),
          start: start,
          end: end,
        );

  static Color _getColor(int classfication) {
    if (classfication == 1) {
      return Colors.white60;
    } else if (classfication == 2) {
      // romm 1
      return Color(0xFF87cc52);
    } else if (classfication == 3) {
      // romm 2
      return Colors.pinkAccent;
    } else if (classfication == 4) {
      // romm 3
      return Color(0xFFcc52a5);
    } else {
      return Color(0xFFccc852);
    }
  }
}
