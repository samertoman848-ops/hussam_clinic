import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:timetable/src/utils.dart';
import 'package:timetable/timetable.dart';

List<BasicEvent> positioningDemoEvents = <BasicEvent>[];

List<TimeOverlay> positioningDemoOverlayProvider(
  BuildContext context,
  DateTime date,
) {
  assert(date.debugCheckIsValidTimetableDate());

  final widget = ColoredBox(
      color: context.theme.brightness.contrastColor.withOpacity(.05));

  if (date.weekday != DateTime.friday) {
    return [
      TimeOverlay(start: 0.hours, end: 8.hours, widget: widget),
      TimeOverlay(start: 20.hours, end: 24.hours, widget: widget),
    ];
  } else {
    return [TimeOverlay(start: 0.hours, end: 24.hours, widget: widget)];
  }
}
