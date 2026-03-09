import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:hussam_clinc/db/dbdate.dart';
import 'package:hussam_clinc/model/DatesModel.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? _timer;
  final Set<int> _notifiedIds = {};

  Future<void> init() async {
    if (kIsWeb) return;
    await localNotifier.setup(
      appName: 'عيادة حسام',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
    startMonitoring();
  }

  void startMonitoring() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAppointments();
    });
    // Initial check
    _checkAppointments();
  }

  Future<void> _checkAppointments() async {
    DbDate dbDate = DbDate();
    List<DateModel> appointments = await dbDate.alldate();
    DateTime now = DateTime.now();

    for (var app in appointments) {
      if (_notifiedIds.contains(app.id)) continue;

      try {
        // Ensure we parse as local time if it's stored as local, or handle UTC correctly.
        // If the string doesn't specify Z, DateTime.parse assumes local.
        DateTime appStart = DateTime.parse(app.dateStart).toLocal();

        // Calculate difference accounting for current local time
        Duration difference = appStart.difference(now);

        // Debug log to check the time calculation
        // print(
        //     'Checking App ID: ${app.id}, Start: $appStart, Now: $now, Diff: ${difference.inMinutes}m');

        // Notify if appointment is in the next 20 minutes and hasn't started yet
        // Also ensure it's on the same day to avoid "tomorrow same time" issues if using relative time
        if (difference.inMinutes >= 0 &&
            difference.inMinutes <= 20 &&
            appStart.day == now.day) {
          _showNotification(app);
          print('Showing notification for appointment: ${app.id}');
          _notifiedIds.add(app.id);
        }
      } catch (e) {
        print('Error parsing date for app ${app.id}: $e');
      }
    }
  }

  Future<void> _showNotification(DateModel app) async {
    print('Notification trigger for appointment: ${app.id}');

    // Parse the dateStart to get the correct time
    DateTime appStart = DateTime.parse(app.dateStart).toLocal();
    String formattedTime =
        '${appStart.hour.toString().padLeft(2, '0')}:${appStart.minute.toString().padLeft(2, '0')}';

    LocalNotification notification = LocalNotification(
      identifier: 'app_notif_${app.id}',
      title: 'تنبيه موعد قريب',
      body: 'المريض: ${app.costumerName}\n'
          'الزمان: $formattedTime\n'
          'المكان: ${app.place}',
      silent: false, // Ensure it's not silent to play default system sound
      actions: [
        LocalNotificationAction(text: 'تم'),
      ],
    );

    notification.show();
  }

  void dispose() {
    _timer?.cancel();
  }
}
