import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart' as picked;

/// Widget مخصص لعرض منتقي الوقت مع تعليم الأوقات المحجوزة بألوان
class TimePickerWithBookedHours extends StatelessWidget {
  final BuildContext context;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<picked.TimeRange>? disabledTimes;
  final List<Color>? disabledColors;
  final Function(TimeOfDay) onStartChange;
  final Function(TimeOfDay) onEndChange;

  const TimePickerWithBookedHours({
    Key? key,
    required this.context,
    required this.startTime,
    required this.endTime,
    this.disabledTimes,
    this.disabledColors,
    required this.onStartChange,
    required this.onEndChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // عرض علامات الأوقات المحجوزة
        if (disabledTimes != null && disabledTimes!.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الأوقات المحجوزة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(disabledTimes!.length, (index) {
                    final timeRange = disabledTimes![index];
                    final color = (disabledColors != null &&
                            index < disabledColors!.length)
                        ? disabledColors![index]
                        : Colors.red.withOpacity(0.5);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: Text(
                        '${timeRange.startTime.hour.toString().padLeft(2, '0')}:${timeRange.startTime.minute.toString().padLeft(2, '0')} - ${timeRange.endTime.hour.toString().padLeft(2, '0')}:${timeRange.endTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        // عرض منتقي الوقت
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            await picked.showTimeRangePicker(
              context: context,
              paintingStyle: PaintingStyle.fill,
              start: startTime,
              end: endTime,
              disabledColor: Colors.red.withOpacity(0.5),
              // تمرير أول وقت معطل كمثال
              disabledTime: disabledTimes != null && disabledTimes!.isNotEmpty
                  ? disabledTimes![0]
                  : picked.TimeRange(
                      startTime: const TimeOfDay(hour: 21, minute: 0),
                      endTime: const TimeOfDay(hour: 8, minute: 0),
                    ),
              onStartChange: onStartChange,
              onEndChange: onEndChange,
              interval: const Duration(minutes: 10),
              minDuration: const Duration(minutes: 15),
              maxDuration: const Duration(hours: 3),
              use24HourFormat: false,
              padding: 30,
              strokeWidth: 20,
              handlerRadius: 8,
              strokeColor: Colors.green.withOpacity(0.3),
              handlerColor: Colors.orange[700],
              selectedColor: Colors.purpleAccent,
              backgroundColor: Colors.grey.withOpacity(0.5),
              ticks: 72,
              ticksColor: Colors.white,
              snap: true,
              labels: [
                "12am",
                "1am",
                "2am",
                "3am",
                "4am",
                "5am",
                "6am",
                "7am",
                "8am",
                "9am",
                "10am",
                "11am",
                "12pm",
                "1pm",
                "2pm",
                "3pm",
                "4pm",
                "5pm",
                "6pm",
                "7pm",
                "8pm",
                "9pm",
                "10pm",
                "11pm",
                "12pm",
              ].asMap().entries.map((e) {
                return picked.ClockLabel.fromIndex(
                  idx: e.key,
                  length: 24,
                  text: e.value,
                );
              }).toList(),
              labelOffset: -30,
              labelStyle: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              timeTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
              activeTimeTextStyle: const TextStyle(
                color: Colors.pink,
                fontSize: 26,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
          },
          child: Text(
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
