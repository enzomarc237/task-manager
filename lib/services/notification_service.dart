import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    _initialized = true;
  }

  static void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handle iOS foreground notification
    debugPrint('Received local notification: $title');
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific task
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.macOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true;
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (!_initialized) await initialize();
    if (task.dueDate == null) return;

    final scheduledDate = task.dueDate!.subtract(const Duration(minutes: 15));
    
    // Don't schedule if the time has already passed
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      task.id.hashCode,
      'Task Reminder',
      '${task.title} is due soon',
      _convertToTZDateTime(scheduledDate),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for upcoming task due dates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'task_reminder',
          threadIdentifier: 'task_reminders',
        ),
        macOS: DarwinNotificationDetails(
          categoryIdentifier: 'task_reminder',
          threadIdentifier: 'task_reminders',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  Future<void> scheduleTaskDueNotification(Task task) async {
    if (!_initialized) await initialize();
    if (task.dueDate == null) return;

    // Don't schedule if the time has already passed
    if (task.dueDate!.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      (task.id + '_due').hashCode,
      'Task Due Now',
      '${task.title} is due now!',
      _convertToTZDateTime(task.dueDate!),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_due',
          'Task Due',
          channelDescription: 'Notifications for tasks that are due now',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFFF5722),
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'task_due',
          threadIdentifier: 'task_due',
          sound: 'default',
        ),
        macOS: DarwinNotificationDetails(
          categoryIdentifier: 'task_due',
          threadIdentifier: 'task_due',
          sound: 'default',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  Future<void> scheduleRecurringTaskNotification(Task task) async {
    if (!_initialized) await initialize();
    if (!task.isRecurring || task.recurrencePattern == null) return;

    // Schedule next occurrence notification
    final nextDueDate = _calculateNextRecurrence(task);
    if (nextDueDate == null) return;

    final reminderDate = nextDueDate.subtract(const Duration(minutes: 15));
    
    if (reminderDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      (task.id + '_recurring').hashCode,
      'Recurring Task Reminder',
      '${task.title} is due soon (recurring)',
      _convertToTZDateTime(reminderDate),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_tasks',
          'Recurring Tasks',
          channelDescription: 'Notifications for recurring tasks',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF4CAF50),
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'recurring_task',
          threadIdentifier: 'recurring_tasks',
        ),
        macOS: DarwinNotificationDetails(
          categoryIdentifier: 'recurring_task',
          threadIdentifier: 'recurring_tasks',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    if (!_initialized) await initialize();
    
    await _notifications.cancel(taskId.hashCode);
    await _notifications.cancel((taskId + '_due').hashCode);
    await _notifications.cancel((taskId + '_recurring').hashCode);
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
  }

  Future<void> showTaskCompletedNotification(Task task) async {
    if (!_initialized) await initialize();

    await _notifications.show(
      (task.id + '_completed').hashCode,
      'Task Completed! 🎉',
      '${task.title} has been marked as completed',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_completed',
          'Task Completed',
          channelDescription: 'Notifications for completed tasks',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF4CAF50),
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'task_completed',
          threadIdentifier: 'task_completed',
        ),
        macOS: DarwinNotificationDetails(
          categoryIdentifier: 'task_completed',
          threadIdentifier: 'task_completed',
        ),
      ),
      payload: task.id,
    );
  }

  Future<void> showDailySummaryNotification(int totalTasks, int completedTasks, int overdueTasks) async {
    if (!_initialized) await initialize();

    final pendingTasks = totalTasks - completedTasks;
    String body = 'You have $pendingTasks tasks pending';
    
    if (completedTasks > 0) {
      body += ' and completed $completedTasks tasks today';
    }
    
    if (overdueTasks > 0) {
      body += '. $overdueTasks tasks are overdue';
    }

    await _notifications.show(
      'daily_summary'.hashCode,
      'Daily Task Summary',
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          channelDescription: 'Daily task summary notifications',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'daily_summary',
          threadIdentifier: 'daily_summary',
        ),
        macOS: DarwinNotificationDetails(
          categoryIdentifier: 'daily_summary',
          threadIdentifier: 'daily_summary',
        ),
      ),
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _notifications.pendingNotificationRequests();
  }

  // Private helper methods
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // This would normally use timezone package, but for simplicity we'll use DateTime
    // In a real app, you'd want to properly handle timezones
    return dateTime;
  }

  DateTime? _calculateNextRecurrence(Task task) {
    if (task.dueDate == null || task.recurrencePattern == null) return null;

    final pattern = task.recurrencePattern!;
    final currentDue = task.dueDate!;
    
    switch (pattern.type) {
      case RecurrenceType.daily:
        return currentDue.add(Duration(days: pattern.interval));
      case RecurrenceType.weekly:
        return currentDue.add(Duration(days: 7 * pattern.interval));
      case RecurrenceType.monthly:
        return DateTime(
          currentDue.year,
          currentDue.month + pattern.interval,
          currentDue.day,
          currentDue.hour,
          currentDue.minute,
        );
      case RecurrenceType.yearly:
        return DateTime(
          currentDue.year + pattern.interval,
          currentDue.month,
          currentDue.day,
          currentDue.hour,
          currentDue.minute,
        );
    }
  }

  // Notification categories for iOS/macOS
  Future<void> _setupNotificationCategories() async {
    if (defaultTargetPlatform == TargetPlatform.iOS || 
        defaultTargetPlatform == TargetPlatform.macOS) {
      
      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.initialize(
            const DarwinInitializationSettings(),
            onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
          );
    }
  }
}