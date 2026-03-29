import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'dart:ui' as ui;
import 'package:hussam_clinc/db/dbdate.dart';
import 'package:hussam_clinc/db/dbrooms.dart';
import 'package:hussam_clinc/db/dbemployee.dart';
import 'package:hussam_clinc/dialog/dating_add_dialog.dart';
import 'package:hussam_clinc/dialog/dating_edite_dialog.dart';
import 'package:time/time.dart';
import 'package:timetable/timetable.dart';
import 'package:hussam_clinc/db/patients/dbpatient.dart';
import 'package:hussam_clinc/theme/app_theme.dart';
import '../global_var/globals.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../main.dart';
import '../model/DatesModel.dart';
import 'positioning_demo.dart';

final draggedEvents = <BasicEvent>[];

class TimetableExample extends StatefulWidget {
  const TimetableExample({super.key});

  @override
  State<TimetableExample> createState() => _TimetableExampleState();
}

class _TimetableExampleState extends State<TimetableExample>
    with TickerProviderStateMixin {
  OverlayEntry? _hoverOverlayEntry;
  List<String> _selectedPatients = [];
  Set<int> _selectedAppointmentIds = {}; // للتحديد المتعدد للمواعيد
  List<String> dynamicRooms =
      []; // ابدأ فارغة - سيتم تحميل الغرف من قاعدة البيانات

  var _visibleDateRange = PredefinedVisibleDateRange.threeDays;
  void _updateVisibleDateRange(PredefinedVisibleDateRange newValue) {
    setState(() {
      _visibleDateRange = newValue;
      _dateController.visibleRange = newValue.visibleDateRange;
    });
  }

  void _navigate(int direction) {
    int days = 1;
    switch (_visibleDateRange) {
      case PredefinedVisibleDateRange.day:
        days = 1;
        break;
      case PredefinedVisibleDateRange.threeDays:
        days = 3;
        break;
      case PredefinedVisibleDateRange.sevenDays:
      case PredefinedVisibleDateRange.week:
        days = 7;
        break;
    }

    final targetDate =
        _dateController.value.date.add(Duration(days: direction * days));
    _dateController.animateTo(targetDate, vsync: this);
  }

  late DateTime selectedDate = DateTimeTimetable.today();
  List<String> listPersons = [];
  List<String> listDoctors = [];
  List<BasicEvent> positioniemoEvents = <BasicEvent>[];
  bool get _isRecurringLayout =>
      _visibleDateRange == PredefinedVisibleDateRange.sevenDays ||
      _visibleDateRange == PredefinedVisibleDateRange.threeDays;
  DateTime currentDate = DateTime.now();
  TimeOfDay currentTime = TimeOfDay.now();
  String selectDoctorList = allPatient.isNotEmpty ? allPatient.elementAt(0).name : "";
  late final _dateController = DateController(
    // All parameters are optional.
    initialDate: DateTimeTimetable.today(),
    //visibleRange: VisibleDateRange.week(startOfWeek: DateTime.saturday),
    visibleRange: _visibleDateRange.visibleDateRange,
  );

  final _timeController = TimeController(
    minDuration: 15.minutes, // The closest you can zoom in (quarter hour).
    maxDuration:
        9.hours, // The furthest you can zoom out (matched to initial range).
    initialRange: TimeRange(8.hours, 17.hours),
    maxRange: TimeRange(7.hours, 19.hours),
  );

  @override
  void initState() {
    // TODO: implement initState
    _loadRooms();
    selecedPatientList();

    // عرض رسالة توضيحية عن كيفية استخدام التحديد المتعدد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '💡 اضغط على الموعد للتحديد/إلغاء التحديد، ثم اضغط بالزر الأيمن للعمليات الجماعية',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.blue.shade700,
        ),
      );
    });
    selecedDoctorList();

    super.initState();
  }

  Future<void> _loadRooms() async {
    DbRooms dbRooms = DbRooms();
    // تأكد من وجود جدول الغرف وإنشاء الغرف الافتراضية
    await dbRooms.ensureDefaultRooms();

    // تحميل الغرف من قاعدة البيانات وإزالة التكرار
    final rooms = await dbRooms.allRooms();
    setState(() {
      // استخدم Set لإزالة التكرار ثم حول إلى List وعيّن في dynamicRooms
      dynamicRooms = rooms.map((room) => room.name).toSet().toList();
      // تأكد من أن dynamicRooms ليست فارغة
      if (dynamicRooms.isEmpty) {
        dynamicRooms = ['غرفة 1', 'غرفة 2', 'غرفة 3'];
      }
      print('تم تحميل ${dynamicRooms.length} غرفة: $dynamicRooms');
    });
    // انتظر حتى تنتهي من تحميل التواريخ
    await SetDateList();

    setState(() {
      DatesData();
    });
  }

  Future<void> _addRoom() async {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة غرفة جديدة'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'أدخل اسم الغرفة (مثلاً: غرفة 4)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                try {
                  DbRooms dbRooms = DbRooms();
                  await dbRooms.addRoom(textController.text);

                  Navigator.pop(context);

                  // إعادة تحميل الغرف من قاعدة البيانات وإزالة التكرار
                  final rooms = await dbRooms.allRooms();
                  setState(() {
                    dynamicRooms =
                        rooms.map((room) => room.name).toSet().toList();
                  });

                  // انتظر حتى تنتهي من تحميل التواريخ
                  await SetDateList();

                  setState(() {
                    DatesData();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تمت إضافة ${textController.text} بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('خطأ: الغرفة موجودة بالفعل أو ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('إضافة', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _editRoom() async {
    if (dynamicRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد غرف لتعديلها'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل أسماء الغرف'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: dynamicRooms.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(dynamicRooms[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context);
                        _updateRoomName(dynamicRooms[index]);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteRoom(dynamicRooms[index]);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRoomName(String oldRoomName) async {
    final textController = TextEditingController(text: oldRoomName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل اسم الغرفة'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'أدخل الاسم الجديد للغرفة',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.door_front_door),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty &&
                  textController.text != oldRoomName) {
                try {
                  DbRooms dbRooms = DbRooms();

                  // تحديث اسم الغرفة في القائمة المحلية
                  setState(() {
                    final index = dynamicRooms.indexOf(oldRoomName);
                    if (index != -1) {
                      dynamicRooms[index] = textController.text;
                    }
                  });

                  // تحديث اسم الغرفة في قاعدة البيانات
                  await dbRooms.updateRoomName(
                      oldRoomName, textController.text);

                  Navigator.pop(context);

                  // تحديث الواجهة
                  await SetDateList();
                  setState(() {
                    DatesData();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'تم تغيير اسم الغرفة من "$oldRoomName" إلى "${textController.text}" بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _editRoom();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('تحديث', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(String roomName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الغرفة "$roomName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                DbRooms dbRooms = DbRooms();
                await dbRooms.deleteRoomByName(roomName);

                setState(() {
                  dynamicRooms.remove(roomName);
                });

                Navigator.pop(context);

                await SetDateList();
                setState(() {
                  DatesData();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الغرفة "$roomName" بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
                _editRoom();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideHoverOverlay();
    _timeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _handleScroll(PointerScrollEvent event, double height) {
    // Zoom only if the mouse is on the left side (hours indicator area)
    if (event.localPosition.dx > 70) return;

    final currentRange = _timeController.value;
    final currentDuration = currentRange.duration;

    // Zoom factor: dy < 0 is scroll up (zoom in), dy > 0 is scroll down (zoom out)
    final factor = 1.0 + (event.scrollDelta.dy / 2000.0);
    Duration newDuration = Duration(
        microseconds: (currentDuration.inMicroseconds * factor).round());

    const minVisible = Duration(minutes: 15);
    const Duration maxVisible = Duration(hours: 9);

    if (newDuration < minVisible) newDuration = minVisible;
    if (newDuration > maxVisible) newDuration = maxVisible;

    if (newDuration == currentDuration) return;

    // Calculate the time at the current mouse position
    // localPosition.dy is relative to the Listener/LayoutBuilder
    final relativePos = event.localPosition.dy / height;
    final mouseTime = currentRange.startTime +
        Duration(
            microseconds:
                (currentDuration.inMicroseconds * relativePos).round());

    // New start and end such that mouseTime stays at the same relative position
    var newStart = mouseTime -
        Duration(
            microseconds: (newDuration.inMicroseconds * relativePos).round());
    var newEnd = newStart + newDuration;

    // Keep within maxRange (8.hours to 22.hours)
    const maxRangeStart = Duration(hours: 8);
    const maxRangeEnd = Duration(hours: 22);

    if (newStart < maxRangeStart) {
      newStart = maxRangeStart;
      newEnd = newStart + newDuration;
    }
    if (newEnd > maxRangeEnd) {
      newEnd = maxRangeEnd;
      newStart = (newEnd - newDuration);
      if (newStart < maxRangeStart) newStart = maxRangeStart;
    }

    _timeController.value = TimeRange(newStart, newEnd);
  }

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: refreshKey,
      onRefresh: refreshList,
      child: TimetableConfig<BasicEvent>(
        // Required:
        dateController: _dateController,
        timeController: _timeController,
        eventBuilder: (context, event) => _buildPartDayEvent(event),
        // ignore: sort_child_properties_last
        child: Column(children: [
          _buildAppBar(),
          _buildDoctorsHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      _handleScroll(pointerSignal, constraints.maxHeight);
                    }
                  },
                  child: _isRecurringLayout
                      ? RecurringMultiDateTimetable<BasicEvent>()
                      : MultiDateTimetable<BasicEvent>(),
                );
              },
            ),
          ),
        ]),
        eventProvider: eventProviderFromFixedList(positioningDemoEvents),
        allDayEventBuilder: (context, event, info) => BasicAllDayEventWidget(
          event,
          info: info,
          onTap: () => _showSnackBar('All-day event $event tapped'),
        ),
        timeOverlayProvider: mergeTimeOverlayProviders([
          positioningDemoOverlayProvider,
          (context, date) => draggedEvents
              .map(
                (it) =>
                    it.toTimeOverlay(date: date, widget: BasicEventWidget(it)),
              )
              .whereNotNull()
              .toList(),
        ]),
        callbacks: TimetableCallbacks(
          onWeekTap: (week) {
            //_showSnackBar('Tapped on week $week.');
            selectedDate = week.getDayOfWeek(1);
            _showSnackBar('  ${week.getDayOfWeek(1)}');
            _updateVisibleDateRange(PredefinedVisibleDateRange.week);
            _dateController.animateTo(
              week.getDayOfWeek(DateTime.friday),
              vsync: this,
            );
          },
          onDateTap: (date) {
            final weekDay = date.weekday == 7 ? 0 : date.weekday;
            selectedDate = date.subtract(Duration(days: weekDay));
            _showSnackBar(
                '  تاريخ اليوم المحدد هو : ${date.day}/${date.month}/${date.year} ');
            _dateController.animateTo(date, vsync: this);
          },
          onDateBackgroundTap: (date) =>
              _showSnackBar('Tapped on date background at $date.'),
          onDateTimeBackgroundTap: (dateTime) =>
              _showSnackBar('Tapped on date-time background at $dateTime.'),
          onMultiDateHeaderOverflowTap: (date) =>
              _showSnackBar('Tapped on the overflow of $date.'),
        ),
        theme: TimetableThemeData(
          context,
          dateDividersStyle: DateDividersStyle(
            context,
            color: AppTheme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
          nowIndicatorStyle: NowIndicatorStyle(
            context,
            lineColor: Colors.redAccent,
            shape: TriangleNowIndicatorShape(color: Colors.redAccent),
          ),
          timeIndicatorStyleProvider: (time) => TimeIndicatorStyle(
            context,
            time,
            alwaysUse24HourFormat: false,
            textStyle: TextStyle(
              color: AppTheme.primaryColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          weekdayIndicatorStyleProvider: (date) => WeekdayIndicatorStyle(
            context,
            date,
            label: _getArabicWeekday(date.weekday),
            textStyle: TextStyle(
              color: DateUtils.isSameDay(date, DateTime.now())
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshList() async {
    setState(() {
      DatesListUniq.clear();
      DatesList.clear();
      allDatesList.clear();
      positioningDemoEvents.clear();
    });
    refreshKey.currentState?.show(atTop: true);
    await Future.delayed(const Duration(seconds: 1));

    // إعادة تحميل الغرف وإزالة التكرار
    DbRooms dbRooms = DbRooms();
    final rooms = await dbRooms.allRooms();

    setState(() {
      dynamicRooms = rooms.map((room) => room.name).toSet().toList();
    });

    // انتظر حتى تنتهي من تحميل التواريخ قبل استدعاء DatesData
    await SetDateList();

    setState(() {
      DatesData();
    });
    print('refreshList: allDatesList size: ${allDatesList.length}');
    return;
  }

  Widget _buildPartDayEvent(BasicEvent event) {
    // Check if this is a fixed header event (negative ID means fixed room header)
    final isFixedHeader = event.id.toString().startsWith('-');

    if (isFixedHeader) {
      // Fixed headers are non-interactive
      return BasicEventWidget(event);
    }

    final roundedTo = 10.minutes;
    final appointmentId = int.tryParse(event.id.toString()) ?? 0;
    final isSelected = _selectedAppointmentIds.contains(appointmentId);

    // إنشاء widget مخصص مع علامة الاختيار
    Widget eventWidget = MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (eventCursor) {
        print('MouseRegion: onEnter for event ${event.id}');
        _showHoverOverlay(context, event, eventCursor.position);
      },
      onExit: (_) {
        print('MouseRegion: onExit for event ${event.id}');
        _hideHoverOverlay();
      },
      child: PartDayDraggableEvent(
        onDragStart: () => setState(() => draggedEvents.add(event)),
        onDragUpdate: (dateTime) => setState(() {
          dateTime = dateTime.roundTimeToMultipleOf(roundedTo);
          final index = draggedEvents.indexWhere((it) => it.id == event.id);
          final oldEvent = draggedEvents[index];
          draggedEvents[index] = oldEvent.copyWith(
            start: dateTime,
            end: dateTime + oldEvent.duration,
          );
        }),
        onDragEnd: (dateTime) {
          dateTime = (dateTime ?? event.start).roundTimeToMultipleOf(roundedTo);
          draggedEvents.removeWhere((it) => it.id == event.id);
          if (dateTime.hour < 8 || dateTime.hour >= 21) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              action: SnackBarAction(
                textColor: Colors.white,
                backgroundColor: Colors.pinkAccent,
                label: ' هل تريد الحذف بالفعل ',
                onPressed: () {
                  DbDate dbDate = DbDate();
                  dbDate.deletedate(int.parse(event.id.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      ' تم حذف الموعد بنجاح ',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    duration: Duration(seconds: 4),
                  ));
                  refreshList();
                },
              ),
              content: const Column(
                children: [
                  Text(
                    'لم يتم حذف الموعد  ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              duration: const Duration(seconds: 4),
            ));
          } else {
            DbDate dbDate = DbDate();
            dbDate.searchDatesById(event.id.toString()).then((value) {
              int DurationEvent = event.end.difference(event.start).inMinutes;
              DateTime Start =
                  DateTime.utc(dateTime!.year, dateTime.month, dateTime.day) +
                      Duration(hours: dateTime.hour, minutes: dateTime.minute);
              value.dateStart = Start.toString();
              DateTime End = Start.add(Duration(minutes: DurationEvent));
              value.dateEnd = End.toString();
              dbDate
                  .updateDate(int.parse(event.id.toString()), value)
                  .then((_) {
                refreshList();
                _showSnackBar(' $dateTime تم تغيير الوقت إلى  ');
              });
            });
          }
        },
        onDragCanceled: (isMoved) =>
            _showSnackBar('Your finger moved: $isMoved'),
        child: GestureDetector(
          onTap: () {
            // تبديل التحديد بزر الماوس الأيسر
            setState(() {
              final appointmentId = int.tryParse(event.id.toString()) ?? 0;
              if (_selectedAppointmentIds.contains(appointmentId)) {
                _selectedAppointmentIds.remove(appointmentId);
                if (_selectedAppointmentIds.isEmpty) {
                  _showSnackBar('تم إلغاء التحديد');
                }
              } else {
                _selectedAppointmentIds.add(appointmentId);
                _showSnackBar('${_selectedAppointmentIds.length} موعد محدد');
              }
            });

            // تخزين أول موعد محدد للتعديل
            if (_selectedAppointmentIds.isNotEmpty) {
              DbDate dbDate = DbDate();
              selected_event_id = _selectedAppointmentIds.first.toString();
              dbDate.searchDatesById(selected_event_id).then((value) {
                setState(() {
                  selected_event_Model = value;
                });
              });
            }
          },
          onSecondaryTapDown: (details) {
            _showEventContextMenu(context, event, details.globalPosition);
          },
          onDoubleTap: () {
            final model = allDatesList
                .firstWhereOrNull((it) => it.id.toString() == event.id);
            if (model != null) {
              _showSnackBar(
                  'الدكتور: ${model.doctorName}\nالمريض: ${model.costumerName}\nالغرفة: ${model.place}\nالبداية: ${model.dateStart}\nالنهاية: ${model.dateEnd}');
            }
          },
          child: Stack(
            children: [
              BasicEventWidget(
                event,
              ),
              // عرض علامة الاختيار عند التحديد
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return eventWidget;
  }

  void _showHoverOverlay(
      BuildContext context, BasicEvent event, Offset position) {
    if (_hoverOverlayEntry != null) return; // Already showing
    print('Showing hover overlay for event ${event.id} at $position');

    final model =
        allDatesList.firstWhereOrNull((it) => it.id.toString() == event.id);
    if (model == null) {
      print(
          'ShowHoverOverlay: model for event ${event.id} not found in allDatesList (size: ${allDatesList.length})');
      return;
    }

    final patient =
        allPatient.firstWhereOrNull((p) => p.id.toString() == model.costumerId);
    if (patient == null) {
      print(
          'ShowHoverOverlay: patient ${model.costumerId} not found in allPatient (size: ${allPatient.length})');
    }
    final mobile = patient?.mobile ?? 'غير متوفر';
    final note = (model.note.isEmpty || model.note == "d")
        ? 'لا يوجد ملاحظات'
        : model.note;
    final gender = patient?.sex ?? '';
    final status = patient?.status ?? '';

    _hoverOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + 25,
        top: position.dy + 15,
        child: IgnorePointer(
          child: Material(
            elevation: 25,
            shadowColor: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: event.backgroundColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: event.backgroundColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium Header with Adaptive Gradient
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              event.backgroundColor.withOpacity(0.8),
                              event.backgroundColor.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                patient?.sex == 'أنثى'
                                    ? Icons.woman
                                    : Icons.man,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    model.costumerName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _buildHoverBadge(
                                        gender.isNotEmpty
                                            ? gender
                                            : (patient?.sex ?? "مريض"),
                                        event.backgroundColor.withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 6),
                                      if (status.isNotEmpty)
                                        _buildHoverBadge(
                                          status,
                                          Colors.white24,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Column(
                          children: [
                            _buildHoverDetail(Icons.phone_android_rounded,
                                mobile, Colors.greenAccent),
                            const SizedBox(height: 12),
                            _buildHoverDetail(Icons.medical_services_outlined,
                                'د. ${model.doctorName}', Colors.blueAccent),
                            const SizedBox(height: 12),
                            _buildHoverDetail(Icons.door_front_door_outlined,
                                'الموقع: ${model.place}', Colors.purpleAccent),
                            const SizedBox(height: 12),
                            _buildHoverDetail(
                                Icons.access_time_filled_rounded,
                                '${event.start.hour}:${event.start.minute.toString().padLeft(2, '0')} - ${event.end.hour}:${event.end.minute.toString().padLeft(2, '0')}',
                                Colors.orangeAccent),
                            if (note.isNotEmpty &&
                                note != 'لا يوجد ملاحظات') ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child:
                                    Divider(color: Colors.white10, height: 1),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.description_outlined,
                                            color: Colors.amber, size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ملاحظات الموعد',
                                          style: TextStyle(
                                            color:
                                                Colors.amber.withOpacity(0.8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      note,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_hoverOverlayEntry!);
  }

  Widget _buildHoverBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withOpacity(0.9),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHoverDetail(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _hideHoverOverlay() {
    if (_hoverOverlayEntry != null) {
      print('Hiding hover overlay');
      _hoverOverlayEntry!.remove();
      _hoverOverlayEntry = null;
    }
  }

  Future<void> _exportPatientsReport() async {
    if (_selectedPatients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار مريض واحد على الأقل')),
      );
      return;
    }

    final pdf = pw.Document();
    final fontData =
        await rootBundle.load("assets/fonts/ArbFONTS-Amiri-Bold.ttf");
    final font = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('قائمة المرضى المختارين',
                    style: pw.TextStyle(
                        font: font, fontSize: 24, color: PdfColors.blue)),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('رقم الجوال',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('اسم المريض',
                            style: pw.TextStyle(
                                font: font, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ..._selectedPatients.map((name) {
                    final patient =
                        allPatient.firstWhereOrNull((p) => p.name == name);
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(patient?.mobile ?? '',
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(name, style: pw.TextStyle(font: font)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await savePDFFile(bytes,
        'تقرير المرضى المختارين_${DateTime.now().millisecondsSinceEpoch}.pdf');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('تم تصدير التقرير بنجاح'),
          backgroundColor: Colors.green),
    );
  }

  Widget _buildAppBar() {
    final colorScheme = context.theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Navigation Group
              TextButton.icon(
                onPressed: () => _navigate(-1),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                label: const Text('السابق',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
              const SizedBox(width: 8),
              _buildDateHeader(),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _navigate(1),
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                label: const Text('التالي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
              const VerticalDivider(width: 32, indent: 8, endIndent: 8),
              // Actions Group
              _buildActionButton(
                icon: Icons.refresh_outlined,
                color: Colors.blue,
                onPressed: refreshList,
                tooltip: 'تحديث',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.today_rounded,
                color: AppTheme.primaryColor,
                onPressed: () {
                  _dateController.animateToToday(vsync: this);
                  _timeController.animateToShowFullDay(vsync: this);
                },
                tooltip: 'اذهب إلى تاريخ اليوم',
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 250, // Fixed width for mobile/web consistency
                child: DropdownSearch<String>.multiSelection(
                  popupProps: PopupPropsMultiSelection.menu(
                    fit: FlexFit.loose,
                    showSelectedItems: true,
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "ابحث باسم المريض",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  items: (filter, loadProps) => listPersons,
                  selectedItems: _selectedPatients,
                  onChanged: (values) {
                    setState(() {
                      _selectedPatients = values;
                    });
                  },
                  decoratorProps: DropDownDecoratorProps(
                    baseStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person,
                          color: AppTheme.primaryColor, size: 20),
                      labelText: "اختيار مرضى",
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.picture_as_pdf_rounded,
                color: Colors.red,
                onPressed: _exportPatientsReport,
                tooltip: 'تصدير قائمة المختارات',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.add_location_rounded,
                color: Colors.purple,
                onPressed: _addRoom,
                tooltip: 'إضافة غرفة جديدة',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.edit_location_rounded,
                color: Colors.cyan,
                onPressed: _editRoom,
                tooltip: 'تعديل أسماء الغرف',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.add_alarm_rounded,
                color: Colors.orange,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DatingAddDialog(
                      title: "إضافة موعد جديد ",
                      positiveBtnText: "حفظ",
                      negativeBtnText: "إلغاء الأمر",
                    ),
                  ).then((_) => refreshList());
                },
                tooltip: 'اضافة مواعيد',
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<PredefinedVisibleDateRange>(
                  underline: const SizedBox(),
                  onChanged: (visibleRange) =>
                      _updateVisibleDateRange(visibleRange!),
                  value: _visibleDateRange,
                  items: [
                    for (final visibleRange in PredefinedVisibleDateRange.values)
                      DropdownMenuItem(
                        value: visibleRange,
                        child: Text(visibleRange.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return ValueListenableBuilder<DatePageValue>(
      valueListenable: _dateController,
      builder: (context, value, _) {
        final date = value.date;
        int days = 1;
        switch (_visibleDateRange) {
          case PredefinedVisibleDateRange.day:
            days = 1;
            break;
          case PredefinedVisibleDateRange.threeDays:
            days = 3;
            break;
          case PredefinedVisibleDateRange.sevenDays:
          case PredefinedVisibleDateRange.week:
            days = 7;
            break;
        }

        final endDate = date.add(Duration(days: days - 1));

        String text;
        if (days == 1) {
          text = "${date.day}/${date.month}/${date.year}";
        } else {
          if (date.month == endDate.month) {
            text =
                "${date.day} - ${endDate.day} / ${date.month} / ${date.year}";
          } else {
            text =
                "${date.day}/${date.month} - ${endDate.day}/${endDate.month} / ${date.year}";
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  /// بناء widget لعرض أسماء الأطباء مع ألوانهم تحت اسم اليوم
  Widget _buildDoctorsHeader() {
    DateTime displayDate = _dateController.value.date;
    List<Map<String, String>> doctors = getDoctorsForDate(displayDate);

    String dayName = _getArabicWeekday(displayDate.weekday);
    String dateStr =
        '${displayDate.day}/${displayDate.month}/${displayDate.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () async {
                final date = await pickDate();
                if (date != null) {
                  _dateController.animateTo(date, vsync: this);
                  setState(() {
                    DatesData();
                  });
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$dayName - $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (doctors.isNotEmpty) ...[
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    ...doctors.map(
                      (doctor) => _buildDoctorNameWithColor(
                        doctor['name']!,
                        doctor['id']!,
                        doctor['room']!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'لا توجد مواعيد',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSnackBar(String content) =>
      context.scaffoldMessenger.showSnackBar(SnackBar(content: Text(content)));

  Future<DateTime?> pickDate() {
    return showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2620),
      locale: const Locale('ar'),
    );
  }

  Future<TimeOfDay?> pickMin() {
    return showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: currentTime.hour, minute: currentTime.minute),
    );
  }

  /// تحويل رقم اليوم إلى اسم اليوم بالعربية
  String _getArabicWeekday(int weekday) {
    const arabicDays = {
      DateTime.saturday: 'السبت',
      DateTime.sunday: 'الأحد',
      DateTime.monday: 'الاثنين',
      DateTime.tuesday: 'الثلاثاء',
      DateTime.wednesday: 'الأربعاء',
      DateTime.thursday: 'الخميس',
      DateTime.friday: 'الجمعة',
    };
    return arabicDays[weekday] ?? '';
  }

  Future<void> selecedPatientList() async {
    // Populate the global list for hover card details
    await AllPatientList();

    setState(() {
      listPersons.clear();
      for (var patient in allPatient) {
        if (patient.name.isNotEmpty) {
          listPersons.add(patient.name);
        }
      }
    });
  }

  Future<void> selecedDoctorList() async {
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

  /// استخراج أسماء الأطباء الفريدة لتاريخ معين مع doctorId والغرفة
  List<Map<String, String>> getDoctorsForDate(DateTime date) {
    DateTime dateYMD = DateTime.utc(date.year, date.month, date.day);
    final doctorsMap = <String, Map<String, String>>{};

    for (final appointment in allDatesList) {
      DateTime appointmentStart = DateTime.parse(appointment.dateStart);
      DateTime appointmentYMD = DateTime.utc(
          appointmentStart.year, appointmentStart.month, appointmentStart.day);

      if (appointmentYMD == dateYMD) {
        final doctorId = appointment.doctorId;
        final doctorName = appointment.doctorName;
        final room = appointment.place;
        if (doctorName.isNotEmpty && !doctorsMap.containsKey(doctorName)) {
          doctorsMap[doctorName] = {'id': doctorId, 'room': room};
        }
      }
    }

    // تحميل النتائج إلى قائمة مع الحفاظ على الترتيب
    return doctorsMap.entries
        .map((e) =>
            {'name': e.key, 'id': e.value['id']!, 'room': e.value['room']!})
        .toList();
  }

  /// الحصول على جميع مواعيد طبيب معين في تاريخ معين
  List<DateModel> getDoctorAppointmentsForDate(DateTime date, String doctorId) {
    DateTime dateYMD = DateTime.utc(date.year, date.month, date.day);
    final appointments = <DateModel>[];

    for (final appointment in allDatesList) {
      DateTime appointmentStart = DateTime.parse(appointment.dateStart);
      DateTime appointmentYMD = DateTime.utc(
          appointmentStart.year, appointmentStart.month, appointmentStart.day);

      if (appointmentYMD == dateYMD && appointment.doctorId == doctorId) {
        appointments.add(appointment);
      }
    }

    // ترتيب المواعيد حسب الساعة
    appointments.sort((a, b) {
      DateTime aStart = DateTime.parse(a.dateStart);
      DateTime bStart = DateTime.parse(b.dateStart);
      return aStart.compareTo(bStart);
    });

    return appointments;
  }

  /// الحصول على لون الطبيب بناءً على doctorId
  Color _getDoctorColor(String doctorId) {
    final docId = int.tryParse(doctorId) ?? 0;
    if (docId % 6 == 0) {
      return const Color(0xFF87cc52);
    } else if (docId % 6 == 1) {
      return Colors.blue;
    } else if (docId % 6 == 2) {
      return Colors.amberAccent;
    } else if (docId % 6 == 3) {
      return Colors.deepPurple;
    } else if (docId % 6 == 4) {
      return Colors.teal;
    } else {
      return Colors.indigo;
    }
  }

  /// بناء زر الطبيب الكبير مع اللون والغرفة
  Widget _buildDoctorNameWithColor(
      String doctorName, String doctorId, String room) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getDoctorColor(doctorId),
        foregroundColor: Colors.white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: () {
        _showDoctorAppointmentsDialog(doctorName, doctorId);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            doctorName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            room,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// عرض dialog بمواعيد الطبيب
  void _showDoctorAppointmentsDialog(String doctorName, String doctorId) {
    DateTime displayDate = _dateController.value.date;
    List<DateModel> appointments =
        getDoctorAppointmentsForDate(displayDate, doctorId);

    showDialog(
      context: context,
      builder: (context) => _DoctorAppointmentsDialogWidget(
        doctorName: doctorName,
        doctorId: doctorId,
        displayDate: displayDate,
        appointments: appointments,
        doctorColor: _getDoctorColor(doctorId),
        getPatientPhone: _getPatientPhone,
      ),
    );
  }

  /// الحصول على رقم هاتف المريض
  String _getPatientPhone(String patientId) {
    try {
      final patient = allPatient.firstWhere(
        (p) => p.id.toString() == patientId,
        orElse: () => allPatient.first,
      );
      return patient.mobile.isNotEmpty ? patient.mobile : 'غير متوفر';
    } catch (e) {
      return 'غير متوفر';
    }
  }

  Future<void> SetDateList() async {
    DbDate dbDates = DbDate();

    // Clear lists to prevent duplication on refresh
    setState(() {
      DatesListUniq.clear();
      DatesList.clear();
      allDatesList.clear();
    });

    // انتظر حتى تنتهي من جلب جميع المواعيد
    final allDates = await dbDates.alldate();
    final groupedDates = await dbDates.GroupDates();

    setState(() {
      allDatesList = allDates;
      DatesList = groupedDates;

      Set<DateTime> uniqueDates = {};
      for (var e in groupedDates) {
        DateTime dateS = DateTime.parse(e.dateStart);
        DateTime dateStart = DateTime.utc(dateS.year, dateS.month, dateS.day);
        DateTime dateE = DateTime.parse(e.dateEnd);
        DateTime dateEnd = DateTime.utc(dateE.year, dateE.month, dateE.day);

        uniqueDates.add(dateStart);
        uniqueDates.add(dateEnd);
      }

      DatesListUniq = uniqueDates.toList()..sort();
    });
  }

  void DatesData() {
    // 1. Clear the global events list first
    positioningDemoEvents.clear();

    // 2. Deduplicate allDatesList based on appointment ID
    // Also normalize appointment dates to avoid issues with where/filtering
    final Map<int, DateModel> uniqueApptMap = {};
    for (var appt in allDatesList) {
      if (appt.id != null) {
        // Ensure place is trimmed for consistent grouping
        appt.place = appt.place.trim();
        uniqueApptMap[appt.id!] = appt;
      }
    }
    final List<DateModel> deduplicatedAppts = uniqueApptMap.values.toList();

    // 3. Normalize all days to UTC start of day to ensure absolute uniqueness
    final Set<DateTime> normalizedDays = {};
    for (var d in DatesListUniq) {
      normalizedDays.add(DateTime.utc(d.year, d.month, d.day));
    }
    final List<DateTime> sortedDays = normalizedDays.toList()..sort();

    // Iterate through each unique date we are displaying.
    for (var dateDay in sortedDays) {
      final currentDayYMD =
          DateTime.utc(dateDay.year, dateDay.month, dateDay.day);

      // 1. Find appointments for this specific day
      List<DateModel> dayAppointments = deduplicatedAppts.where((appt) {
        DateTime apptStart = DateTime.parse(appt.dateStart);
        return apptStart.year == currentDayYMD.year &&
            apptStart.month == currentDayYMD.month &&
            apptStart.day == currentDayYMD.day;
      }).toList();

      // 2. Identify unique rooms for THIS DAY (trim to be absolutely sure)
      Set<String> dayRooms = dayAppointments
          .map((appt) => appt.place.trim())
          .where((room) => room.isNotEmpty)
          .toSet();

      // If no rooms booked for this day, use default empty view
      if (dayRooms.isEmpty) {
        dayRooms.addAll(dynamicRooms.map((r) => r.trim()));
      }

      // Sort rooms to be consistent
      List<String> sortedDayRooms = dayRooms.toList()..sort();

      for (int i = 0; i < sortedDayRooms.length; i++) {
        String room = sortedDayRooms[i];
        int columnIndex = i; // 0, 1, 2... for this day

        // Fixed Header (Room Name)
        positioningDemoEvents.add(_DemoEvent(
          -(currentDayYMD.millisecondsSinceEpoch +
              i), // Stable unique negative ID
          room,
          columnIndex,
          currentDayYMD + const Duration(hours: 8, minutes: 0),
          currentDayYMD + const Duration(hours: 8, minutes: 30),
          color: Colors.grey[400],
        ));

        // Background (Visual container)
        positioningDemoEvents.add(_DemoEvent(
          0, // ID 0 for background
          "",
          columnIndex,
          currentDayYMD + const Duration(hours: 8, minutes: 40),
          currentDayYMD + const Duration(hours: 21, minutes: 0),
        ));

        // Add Actual Appointments for this Room on this Day
        var roomAppts = dayAppointments.where((a) => a.place.trim() == room);
        for (var element in roomAppts) {
          DateTime dateStart = DateTime.parse(element.dateStart);
          DateTime dateEnd = DateTime.parse(element.dateEnd);

          // Use currentDayYMD as the base for appointment rendering to align with column
          DateTime dateStartYMD =
              DateTime.utc(dateStart.year, dateStart.month, dateStart.day);
          DateTime dateEndYMD =
              DateTime.utc(dateEnd.year, dateEnd.month, dateEnd.day);

          String title =
              ' ${element.costumerName} \n ${element.doctorName} \n ${element.note} \n ${element.place}';

          final docId = int.tryParse(element.doctorId) ?? 0;
          final docColor = _DemoEvent._getColor(5, id: docId);
          final Color eventColor = _selectedAppointmentIds.contains(element.id)
              ? Colors.amber.shade600
              : docColor;

          positioningDemoEvents.add(_DemoEvent(
            element.id!,
            title,
            columnIndex,
            dateStartYMD +
                Duration(hours: dateStart.hour, minutes: dateStart.minute),
            dateEndYMD + Duration(hours: dateEnd.hour, minutes: dateEnd.minute),
            color: eventColor,
          ));
        }
      }
    }
  }

  void _showEventContextMenu(
      BuildContext context, BasicEvent event, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // إضافة الموعد الحالي إلى المحددة إذا لم يكن موجودًا
    final appointmentId = int.tryParse(event.id.toString()) ?? 0;
    if (!_selectedAppointmentIds.contains(appointmentId)) {
      _selectedAppointmentIds.add(appointmentId);
    }

    final isMultipleSelected = _selectedAppointmentIds.length > 1;

    showMenu(
      context: context,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.95),
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: <PopupMenuEntry<String>>[
        if (isMultipleSelected)
          PopupMenuItem<String>(
            enabled: false,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                'العمليات على ${_selectedAppointmentIds.length} مواعيد',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        if (isMultipleSelected) const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'edit',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 22),
                const SizedBox(width: 12),
                Text(
                  isMultipleSelected ? 'تعديل جميع المحددة' : 'تعديل الموعد',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'copy',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.copy_rounded,
                    color: Colors.orange.shade700, size: 22),
                const SizedBox(width: 12),
                Text(
                  isMultipleSelected ? 'نسخ جميع المحددة' : 'نسخ الموعد',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'move',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.move_down_rounded,
                    color: Colors.purple.shade700, size: 22),
                const SizedBox(width: 12),
                Text(
                  isMultipleSelected ? 'نقل جميع المحددة' : 'نقل الموعد',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'delete',
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade700, size: 22),
                const SizedBox(width: 12),
                Text(
                  isMultipleSelected ? 'حذف جميع المحددة' : 'حذف الموعد',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        if (isMultipleSelected) {
          _editMultipleAppointments();
        } else {
          _editSingleAppointment(event);
        }
      } else if (value == 'copy') {
        if (isMultipleSelected) {
          _copyMultipleAppointments();
        } else {
          _copyAppointment(event);
        }
      } else if (value == 'move') {
        _moveAppointments();
      } else if (value == 'delete') {
        if (isMultipleSelected) {
          _deleteMultipleAppointments();
        } else {
          _showDeleteConfirmation(event);
        }
      }
    });
  }

  void _editSingleAppointment(BasicEvent event) {
    DbDate dbDate = DbDate();
    selected_event_id = event.id.toString();

    dbDate.searchDatesById(selected_event_id).then((value) {
      setState(() {
        selected_event_Model = value;
      });
      showDialog(
        context: context,
        builder: (context) {
          return DatingEditeDialog(
            title: "تعديل الموعد",
            positiveBtnText: "حفظ",
            negativeBtnText: "إلغاء الأمر",
          );
        },
      ).then((_) {
        setState(() {
          _selectedAppointmentIds.clear();
        });
        refreshList();
      });
    });
  }

  void _editMultipleAppointments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المواعيد المحددة'),
        content: const Text('اختر العملية المطلوبة:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _changeRoomForSelected();
            },
            icon: const Icon(Icons.place),
            label: const Text('تغيير الغرفة'),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _changeDoctorForSelected();
            },
            icon: const Icon(Icons.person),
            label: const Text('تغيير الدكتور'),
          ),
        ],
      ),
    );
  }

  void _changeRoomForSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير الغرفة'),
        content: DropdownButton<String>(
          items: dynamicRooms
              .map((room) => DropdownMenuItem(value: room, child: Text(room)))
              .toList(),
          onChanged: (selectedRoom) {
            if (selectedRoom != null) {
              Navigator.pop(context);
              _applyRoomChange(selectedRoom);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _applyRoomChange(String newRoom) {
    DbDate dbDate = DbDate();
    for (int id in _selectedAppointmentIds) {
      dbDate.searchDatesById(id.toString()).then((appointment) {
        appointment.place = newRoom;
        dbDate.updateDate(id, appointment);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('تم تغيير الغرفة لـ ${_selectedAppointmentIds.length} موعد'),
        backgroundColor: Colors.green.shade700,
      ),
    );
    setState(() {
      _selectedAppointmentIds.clear();
    });
    refreshList();
  }

  void _changeDoctorForSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير الدكتور'),
        content: DropdownButton<String>(
          items: listDoctors
              .map((doctor) =>
                  DropdownMenuItem(value: doctor, child: Text(doctor)))
              .toList(),
          onChanged: (selectedDoctor) {
            if (selectedDoctor != null) {
              Navigator.pop(context);
              _applyDoctorChange(selectedDoctor);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _applyDoctorChange(String newDoctorName) {
    DbDate dbDate = DbDate();

    for (int id in _selectedAppointmentIds) {
      dbDate.searchDatesById(id.toString()).then((appointment) {
        appointment.doctorName = newDoctorName;
        dbDate.updateDate(id, appointment);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('تم تغيير الدكتور لـ ${_selectedAppointmentIds.length} موعد'),
        backgroundColor: Colors.green.shade700,
      ),
    );
    setState(() {
      _selectedAppointmentIds.clear();
    });
    refreshList();
  }

  void _copyMultipleAppointments() {
    DbDate dbDate = DbDate();

    for (int id in _selectedAppointmentIds) {
      dbDate.searchDatesById(id.toString()).then((originalAppointment) {
        dbDate.adddate(
          originalAppointment.kind,
          originalAppointment.place,
          originalAppointment.dateStart,
          originalAppointment.dateEnd,
          originalAppointment.note,
          originalAppointment.doctorId,
          originalAppointment.doctorName,
          originalAppointment.costumerId,
          originalAppointment.costumerName,
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ ${_selectedAppointmentIds.length} موعد بنجاح'),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _selectedAppointmentIds.clear();
    });
    refreshList();
  }

  void _moveAppointments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نقل المواعيد'),
        content: const Text('اختر التاريخ الجديد:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (newDate != null && mounted) {
                Navigator.pop(context);
                _applyDateChange(newDate);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('اختر التاريخ'),
          ),
        ],
      ),
    );
  }

  void _applyDateChange(DateTime newDate) {
    DbDate dbDate = DbDate();

    for (int id in _selectedAppointmentIds) {
      dbDate.searchDatesById(id.toString()).then((appointment) {
        // استخراج الوقت من التاريخ الأصلي
        DateTime originalStart = DateTime.parse(appointment.dateStart);
        DateTime originalEnd = DateTime.parse(appointment.dateEnd);

        // إنشاء تاريخ جديد مع الوقت الأصلي
        DateTime newStart = DateTime(newDate.year, newDate.month, newDate.day,
            originalStart.hour, originalStart.minute);
        DateTime newEnd = DateTime(newDate.year, newDate.month, newDate.day,
            originalEnd.hour, originalEnd.minute);

        appointment.dateStart = newStart.toString();
        appointment.dateEnd = newEnd.toString();
        dbDate.updateDate(id, appointment);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'تم نقل ${_selectedAppointmentIds.length} موعد إلى ${newDate.day}/${newDate.month}/${newDate.year}'),
        backgroundColor: Colors.green.shade700,
      ),
    );

    setState(() {
      _selectedAppointmentIds.clear();
    });
    refreshList();
  }

  void _deleteMultipleAppointments() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content:
              Text('هل تريد حذف ${_selectedAppointmentIds.length} مواعيد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DbDate dbDate = DbDate();

                for (int id in _selectedAppointmentIds) {
                  dbDate.deletedate(id);
                }

                setState(() {
                  _selectedAppointmentIds.clear();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم حذف المواعيد بنجاح'),
                    backgroundColor: Colors.green.shade700,
                  ),
                );

                refreshList();
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BasicEvent event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل تريد حذف هذا الموعد بالفعل؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DbDate dbDate = DbDate();
                dbDate.deletedate(int.parse(event.id.toString()));
                setState(() {
                  _selectedAppointmentIds.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'تم حذف الموعد بنجاح',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  duration: Duration(seconds: 4),
                ));
                refreshList();
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _copyAppointment(BasicEvent event) {
    DbDate dbDate = DbDate();

    dbDate.searchDatesById(event.id.toString()).then((originalAppointment) {
      // Save the copied appointment with the same details
      dbDate.adddate(
        originalAppointment.kind,
        originalAppointment.place,
        originalAppointment.dateStart,
        originalAppointment.dateEnd,
        originalAppointment.note,
        originalAppointment.doctorId,
        originalAppointment.doctorName,
        originalAppointment.costumerId,
        originalAppointment.costumerName,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم نسخ الموعد بنجاح: ${originalAppointment.costumerName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade700,
        ),
      );

      setState(() {
        _selectedAppointmentIds.clear();
      });
      refreshList();
    });
  }
}

enum PredefinedVisibleDateRange { day, threeDays, sevenDays, week }

extension on PredefinedVisibleDateRange {
  VisibleDateRange get visibleDateRange {
    switch (this) {
      case PredefinedVisibleDateRange.day:
        return VisibleDateRange.days(1);
      case PredefinedVisibleDateRange.threeDays:
        return VisibleDateRange.days(3);
      case PredefinedVisibleDateRange.sevenDays:
        return VisibleDateRange.days(6);
      case PredefinedVisibleDateRange.week:
        return VisibleDateRange.week(startOfWeek: DateTime.saturday);
    }
  }

  String get title {
    switch (this) {
      case PredefinedVisibleDateRange.day:
        return 'يوم';
      case PredefinedVisibleDateRange.threeDays:
        return 'ثلاث أيام';
      case PredefinedVisibleDateRange.sevenDays:
        return ' سبع أيام';
      case PredefinedVisibleDateRange.week:
        return 'أسبوع';
    }
  }
}

/// Dialog لعرض مواعيد الطبيب بطريقة جدول
class _DoctorAppointmentsDialogWidget extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  final DateTime displayDate;
  final List<DateModel> appointments;
  final Color doctorColor;
  final Function(String) getPatientPhone;

  const _DoctorAppointmentsDialogWidget({
    required this.doctorName,
    required this.doctorId,
    required this.displayDate,
    required this.appointments,
    required this.doctorColor,
    required this.getPatientPhone,
  });

  @override
  State<_DoctorAppointmentsDialogWidget> createState() =>
      _DoctorAppointmentsDialogWidgetState();
}

class _DoctorAppointmentsDialogWidgetState
    extends State<_DoctorAppointmentsDialogWidget> {
  final GlobalKey _tableKey = GlobalKey();

  Future<void> _captureAndSaveImage() async {
    try {
      // إعطاء الـ context وقت للـ render
      await Future.delayed(const Duration(milliseconds: 500));

      final RenderRepaintBoundary? boundary = _tableKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتمكن من التقاط الصورة'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final timestamp = DateTime.now()
          .toString()
          .replaceAll(RegExp(r'[^0-9]'), '')
          .substring(0, 14);
      final fileName =
          'doctor_${widget.doctorName.replaceAll(' ', '_')}_$timestamp.png';
      final filePath = await saveImageFile(pngBytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الصورة: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ الصورة: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.doctorColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.displayDate.day}/${widget.displayDate.month}/${widget.displayDate.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.appointments.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      tooltip: 'تحميل صورة الجدول',
                      onPressed: _captureAndSaveImage,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: widget.appointments.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد مواعيد لهذا الطبيب في هذا اليوم',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : RepaintBoundary(
                      key: _tableKey,
                      child: Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                decoration: BoxDecoration(
                                  color: widget.doctorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.doctorColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // Header Row
                                    Container(
                                      decoration: BoxDecoration(
                                        color: widget.doctorColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'اسم المريض',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'الوقت',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'الغرفة',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'رقم الجوال',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Data Rows
                                    ...List.generate(
                                      widget.appointments.length,
                                      (index) {
                                        final appointment =
                                            widget.appointments[index];
                                        DateTime startTime = DateTime.parse(
                                            appointment.dateStart);
                                        DateTime endTime =
                                            DateTime.parse(appointment.dateEnd);
                                        final isEven = index.isEven;

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: isEven
                                                ? Colors.grey[50]
                                                : Colors.white,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: widget.doctorColor
                                                    .withOpacity(0.1),
                                              ),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              // اسم المريض
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  appointment.costumerName,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              // الوقت
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                              // الغرفة
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  appointment.place,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              // رقم الجوال
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  widget.getPatientPhone(
                                                      appointment.costumerId),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoEvent extends BasicEvent {
  _DemoEvent(int demoId, String title, int classification, DateTime start,
      DateTime end,
      {Color? color})
      : super(
          id: '$demoId',
          title: title,
          backgroundColor: color ?? _getColor(classification),
          start: start,
          end: end,
        );

  static Color _getColor(int classfication, {int id = 0}) {
    if (classfication == 1) {
      return Colors.white60;
    } else if (classfication == 2) {
      // romm 1
      return const Color(0xFF87cc52);
    } else if (classfication == 3) {
      // romm 2
      return Colors.pinkAccent;
    } else if (classfication == 4) {
      // romm 3
      return const Color(0xFFcc52a5);
    } else if (classfication == 5) {
      // Doctors Dating
      if (id % 6 == 0) {
        return const Color(0xFF87cc52);
      } else if (id % 6 == 1) {
        return Colors.blue;
      } else if (id % 6 == 2) {
        return Colors.amberAccent;
      } else if (id % 6 == 3) {
        return Colors.deepPurple;
      } else if (id % 6 == 4) {
        return Colors.teal;
      } else {
        return Colors.indigo;
      }
    } else {
      return const Color(0xFFcc52a5);
    }
  }
}

List<TimeOverlay> positioningDemoOverlayProvider(
  BuildContext context,
  DateTime date,
) {
  assert(date.debugCheckIsValidTimetableDate());

  final widget =
      ColoredBox(color: context.theme.brightness.contrastColor.withOpacity(.1));

  if (date.weekday != DateTime.friday) {
    return [
      TimeOverlay(start: 0.hours, end: 9.hours, widget: widget),
      TimeOverlay(start: 21.hours, end: 24.hours, widget: widget),
    ];
  } else {
    return [TimeOverlay(start: 0.hours, end: 24.hours, widget: widget)];
  }
}
