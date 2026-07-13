import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '/app/models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize timezone database for location-based schedules
    tz.initializeTimeZones();

    // 2. Configure Android settings specifically
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
  }

  // Request runtime notification permission (Required for Android 13+)
  Future<bool> requestAndroidPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  // Schedule task deadline reminder on Android
  Future<void> scheduleDeadlineReminder(Task task) async {
    if (task.deadline == null || task.id == null) return;
    
    // Calculate trigger time (e.g., 30 minutes before deadline)
    final reminderTime = task.deadline!.subtract(const Duration(minutes: 30));
    if (reminderTime.isBefore(DateTime.now())) return; // Deadline is in the past

    // Generate unique integer ID from UUID hash
    final int notificationId = task.id.hashCode;

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: '⏳ Batas Waktu Mendekat!',
      body: 'Kegiatan "${task.title}" harus diselesaikan dalam 30 menit.',
      scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'taskify_reminders', // Channel ID
          'Taskify Reminders', // Channel Name
          channelDescription: 'Reminder notifications for task deadlines',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel scheduled Android alarm
  Future<void> cancelReminder(String taskId) async {
    await _notificationsPlugin.cancel(id: taskId.hashCode);
  }
}

