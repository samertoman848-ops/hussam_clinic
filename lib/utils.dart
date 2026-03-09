import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

LinkedHashMap<DateTime, List<Event>> kEvents =
    LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource!);
Map<DateTime, List<Event>>? _kEventSource;

void getNotificationDate(List<DateTime> dates, List<Object?> numbers) {
  //print('dates= $dates');
  // print('numbers= $numbers');
  _kEventSource = {
    for (var item in List.generate(dates.length, (index) => index))
      DateTime.utc(dates[item].year, dates[item].month, dates[item].day):
          List.generate(5, (index) => Event('Event $item |ح ${index + 1}'))
  };
  //print('_kEventSource=   $_kEventSource');
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 240, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 240, kToday.day);


