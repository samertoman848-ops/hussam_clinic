import 'dart:math';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:hussam_clinc/db/dbdate.dart';
import 'package:hussam_clinc/db/dbrooms.dart';
import 'package:hussam_clinc/db/patients/dbpatient.dart';
import 'package:hussam_clinc/themes/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart' as picked;
import 'package:timetable/timetable.dart';
import '../data/positioning_demo.dart';
import '../db/dbemployee.dart';
import '../main.dart';
import '../model/Employment/EmployeeModel.dart';
import '../model/patients/PatientModel.dart';
import '../widgets/TimePickerWithBookedHours.dart';
import '../widgets/TimePickerWithBookedHours.dart';

class DatingEditeDialog extends StatefulWidget {
  final String title, positiveBtnText, negativeBtnText;
  const DatingEditeDialog({
    super.key,
    required this.title,
    required this.positiveBtnText,
    required this.negativeBtnText,
  });
  @override
  State<StatefulWidget> createState() => _DatingEditeDialogState();
}

class _DatingEditeDialogState extends State<DatingEditeDialog> {
  List<String> listPersons = [];
  List<String> listDoctors = [];
  List<String> listChecks = [];
  List<String> datePlaceList = []; // الآن قائمة ديناميكية
  List<picked.TimeRange>? disabledListedTime = [];
  List<Color>? disabledListedColor = [];
  List checks_list = [];
  final String positiveBtnText = "حفظ";
  final String negativeBtnText = "إلفاء الأمر";
  final String title = "تعديل الموعد";
  final _datePlace = GlobalKey<FormState>();

  List<String> get uniqueDoctors => listDoctors.toSet().toList();
  List<String> get uniquePersons => listPersons.toSet().toList();

  late String datePlace; // سيُعين في initState
  String selectPatintList = selected_event_Model.costumerName;
  String selectDoctorList = selected_event_Model.doctorName;
  String selectPatintID = selected_event_Model.costumerId;
  String selectDoctorID = selected_event_Model.doctorId;
  DateTime dateDate = DateTime.parse(selected_event_Model.dateStart);
  DateTime startDate = DateTime.parse(selected_event_Model.dateStart);
  DateTime endDate = DateTime.parse(selected_event_Model.dateEnd);
  TimeOfDay StartTime = TimeOfDay(
    hour: TimeOfDay.now().hour,
    minute: TimeOfDay.now().minute,
  );
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
  String dateNote = selected_event_Model.note;

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
      datePlace = selected_event_Model.place; // حافظ على القيمة الأصلية
      selecedtdatePlaceList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRooms().then((_) {
      if (mounted) {
        CheckDated(dateDate, datePlace, selectDoctorList);
      }
    });
    StartTime = TimeOfDay(hour: startDate.hour, minute: startDate.minute);
    EndTime = TimeOfDay(hour: endDate.hour, minute: endDate.minute);
    Start = DateTime(startDate.year, startDate.month, startDate.day);
    End = DateTime(endDate.year, endDate.month, endDate.day);
    selecedPatientList();
    selecedDoctorList();
    if (disabledListedColor != null) {
      for (int i = 0; i < 50; i++) {
        disabledListedColor!.add(
          Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
        );
      }
    }
  }

  @override
  void dispose() {
    disabledListedTime?.clear();
    disabledListedColor?.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    selecedtdatePlaceList();
    if (uniquePersons.isEmpty) {
      return const CircularProgressIndicator();
    } else {
      selectPatintList = uniquePersons.contains(selectPatintList)
          ? selectPatintList
          : (uniquePersons.isNotEmpty ? uniquePersons[0] : "");
      selectDoctorList = uniqueDoctors.contains(selectDoctorList)
          ? selectDoctorList
          : (uniqueDoctors.isNotEmpty ? uniqueDoctors[0] : "");

      selecedPatientId(selectPatintList);
      selecedDoctorId(selectDoctorList);
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _buildDialogContent(context),
        ),
      );
    }
  }

  Widget _buildDialogContent(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
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
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      title,
                      style: CustomTheme.lightTheme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    const TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.home, color: Colors.black, size: 35),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 650,
                      width: 430,
                      child: GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: TabBarView(
                          children: [
                            Container(child: textEditFisrtPage(context)),
                          ],
                        ),
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
      ),
    );
  }

  Widget textEditFisrtPage(BuildContext context) {
    return ListView(
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
              initialValue: selectDoctorList,
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
              initialValue: datePlace,
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
                labelStyle: const TextStyle(
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
              selectedItem: selectPatintList,
              popupProps: const PopupProps.menu(
                fit: FlexFit.loose,
                showSelectedItems: true,
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "ابحث باسم المريض",
                  ),
                ),
              ),
              items: (filter, loadProps) => uniquePersons,
              decoratorProps: DropDownDecoratorProps(
                baseStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  icon: Icon(Icons.person, color: Colors.blue, size: 35),
                  labelText: "اسم المريض",
                  hintText: "اختار اسم المريض",
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectPatintList = value as String;
                  selecedPatientId(value);
                });
              },
              //selectedItem: "",
            ),

            const SizedBox(height: 2),
            TextFormField(
              //controller: _dateNote,
              initialValue: dateNote,
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
                  Start = Start.add(
                    Duration(hours: StartTime.hour, minutes: StartTime.minute),
                  );
                  End = End.add(
                    Duration(hours: EndTime.hour, minutes: EndTime.minute),
                  );
                });
                if (StartTime.hour == EndTime.hour &&
                    (StartTime.minute == EndTime.minute ||
                        (EndTime.minute - StartTime.minute).abs() < 9)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        ' لم يتم تعديل  الموعد لأن موعد البداية أكثر بعشر دقائق  ',
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
                        'تم تعديل الموعد',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );
                  DbDate dbDate = DbDate();
                  selected_event_Model.dateStart = Start.toString();
                  selected_event_Model.dateEnd = End.toString();
                  selected_event_Model.place = datePlace;
                  selected_event_Model.note = dateNote;
                  selected_event_Model.doctorId = selectDoctorID;
                  selected_event_Model.doctorName = selectDoctorList;
                  selected_event_Model.costumerId = selectPatintID;
                  selected_event_Model.costumerName = selectPatintList;

                  dbDate.updateDate(
                    selected_event_Model.id,
                    selected_event_Model,
                  );
                  Navigator.of(context).pop();
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
                    'تعديل الموعد',
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
      // لا تقم بتعطيل الموعد الحالي الذي يتم تعديله
      if (dating.id == selected_event_Model.id) {
        continue;
      }

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
    dbPatient.allPatients().then((Patients) {
      if (mounted) {
        setState(() {
          listPersons.clear();
          for (var patient in Patients) {
            if (patient.name.isNotEmpty)
              listPersons.add(patient.name.toString());
          }
        });
      }
    });
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
    dbEmployee.allEmployees().then((employees) {
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
    });
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
