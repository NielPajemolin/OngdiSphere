import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int defaultReminderMinutes = 10;

    static const String _kNotificationsEnabled = 'notifications_enabled';
    static const String _kReminderEnabled = 'notifications_reminder_enabled';
    static const String _kDeadlineEnabled = 'notifications_deadline_enabled';
    static const String _kLeadCompensationSeconds =
      'notifications_lead_compensation_seconds';

    bool _notificationsEnabled = true;
    bool _reminderEnabled = true;
    bool _deadlineEnabled = true;
    int _leadCompensationSeconds = 15;

  String _lastTaskDeadlineOutcome = 'not scheduled yet';
  String _lastExamDeadlineOutcome = 'not scheduled yet';

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _configureTimezone();
    await _requestPermissions();
    await _loadPreferences();

    _isInitialized = true;
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_kNotificationsEnabled) ?? true;
    _reminderEnabled = prefs.getBool(_kReminderEnabled) ?? true;
    _deadlineEnabled = prefs.getBool(_kDeadlineEnabled) ?? true;
    final savedComp = prefs.getInt(_kLeadCompensationSeconds) ?? 15;
    _leadCompensationSeconds = savedComp.clamp(0, 30);
  }

  Future<Map<String, Object>> getAppNotificationSettings() async {
    if (!_isInitialized) {
      await init();
    }
    return {
      'notificationsEnabled': _notificationsEnabled,
      'reminderEnabled': _reminderEnabled,
      'deadlineEnabled': _deadlineEnabled,
      'leadCompensationSeconds': _leadCompensationSeconds,
    };
  }

  Future<void> updateAppNotificationSettings({
    bool? notificationsEnabled,
    bool? reminderEnabled,
    bool? deadlineEnabled,
    int? leadCompensationSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (notificationsEnabled != null) {
      _notificationsEnabled = notificationsEnabled;
      await prefs.setBool(_kNotificationsEnabled, notificationsEnabled);
    }
    if (reminderEnabled != null) {
      _reminderEnabled = reminderEnabled;
      await prefs.setBool(_kReminderEnabled, reminderEnabled);
    }
    if (deadlineEnabled != null) {
      _deadlineEnabled = deadlineEnabled;
      await prefs.setBool(_kDeadlineEnabled, deadlineEnabled);
    }
    if (leadCompensationSeconds != null) {
      _leadCompensationSeconds = leadCompensationSeconds.clamp(0, 30);
      await prefs.setInt(_kLeadCompensationSeconds, _leadCompensationSeconds);
    }
  }

  Future<void> _configureTimezone() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _requestPermissions() async {
    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'deadline_reminders',
      'Deadline Reminders',
      channelDescription: 'Alerts before task and exam deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      999001,
      'Test Notification',
      'If you see this, local notifications are working.',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'test',
    );
  }

  Future<Map<String, String>> getDiagnostics() async {
    final result = <String, String>{
      'timezone': tz.local.name,
      'initialized': _isInitialized.toString(),
      'notifications_enabled_in_app': _notificationsEnabled.toString(),
      'reminder_enabled_in_app': _reminderEnabled.toString(),
      'deadline_enabled_in_app': _deadlineEnabled.toString(),
      'lead_compensation_seconds': _leadCompensationSeconds.toString(),
      'last_task_deadline_outcome': _lastTaskDeadlineOutcome,
      'last_exam_deadline_outcome': _lastExamDeadlineOutcome,
    };

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      final notificationsEnabled =
          await androidImplementation.areNotificationsEnabled();
      final exactAllowed =
          await androidImplementation.canScheduleExactNotifications();
      result['android_notifications_enabled'] =
          (notificationsEnabled ?? false).toString();
      result['android_exact_alarms_allowed'] =
          (exactAllowed ?? false).toString();
    }

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      final perms = await iosImplementation.checkPermissions();
      result['ios_alert_permission'] = (perms?.isEnabled ?? false).toString();
      result['ios_sound_permission'] = (perms?.isEnabled ?? false).toString();
      result['ios_badge_permission'] = (perms?.isEnabled ?? false).toString();
    }

    final pending = await _plugin.pendingNotificationRequests();
    result['pending_notifications'] = pending.length.toString();

    return result;
  }

  int _stablePositiveId(String raw, {required int salt}) {
    final id = Object.hash(raw, salt);
    return id & 0x7fffffff;
  }

  int _taskNotificationId(String taskId) =>
      _stablePositiveId(taskId, salt: 0x11);

  int _examNotificationId(String examId) =>
      _stablePositiveId(examId, salt: 0x33);

  String _formatMinutes(int minutes) {
    return minutes == 1 ? '1 minute' : '$minutes minutes';
  }

  String _taskReminderBody(String title, int minutes) {
    return 'Task "$title" is due in ${_formatMinutes(minutes)}.';
  }

  String _taskLateReminderBody(String title, Duration remaining) {
    final minutes = remaining.inMinutes;
    if (minutes <= 0) {
      return 'Task "$title" is due now.';
    }
    return 'Only ${_formatMinutes(minutes)} left for task "$title".';
  }

  String _examReminderBody(String title, int minutes) {
    return 'Exam "$title" starts in ${_formatMinutes(minutes)}.';
  }

  String _examLateReminderBody(String title, Duration remaining) {
    final minutes = remaining.inMinutes;
    if (minutes <= 0) {
      return 'Exam "$title" starts now.';
    }
    return 'Only ${_formatMinutes(minutes)} left until exam "$title".';
  }

  Future<void> _showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'deadline_reminders',
      'Deadline Reminders',
      channelDescription: 'Alerts before task and exam deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: id.toString(),
    );
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required DateTime deadline,
    int reminderMinutes = defaultReminderMinutes,
  }) async {
    if (!_notificationsEnabled) {
      _lastTaskDeadlineOutcome = 'disabled_in_app';
      await cancelTaskReminder(taskId);
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(deadline.add(const Duration(minutes: 1)))) {
      _lastTaskDeadlineOutcome = 'skipped_stale';
      await cancelTaskReminder(taskId);
      return;
    }

    final baseId = _taskNotificationId(taskId);
    final reminderAt = deadline
      .subtract(Duration(minutes: reminderMinutes))
      .subtract(Duration(seconds: _leadCompensationSeconds));
    if (_reminderEnabled) {
      if (reminderAt.isBefore(now)) {
        await _showImmediate(
          id: baseId,
          title: 'Task Reminder',
          body: _taskLateReminderBody(title, deadline.difference(now)),
        );
      } else {
        await _scheduleAt(
          id: baseId,
          title: 'Task Reminder',
          futureBody: _taskReminderBody(title, reminderMinutes),
          immediateBody: _taskLateReminderBody(title, deadline.difference(DateTime.now())),
          scheduledAt: reminderAt,
        );
      }
    } else {
      await _plugin.cancel(baseId);
    }
    if (_deadlineEnabled) {
      _lastTaskDeadlineOutcome = await _scheduleAt(
        id: baseId + 1,
        title: 'Task Deadline',
        futureBody: 'Task "$title" is due now.',
        immediateBody: 'Task "$title" is due now.',
        scheduledAt: deadline.subtract(Duration(seconds: _leadCompensationSeconds)),
        showImmediatelyIfPast: true,
      );
    } else {
      _lastTaskDeadlineOutcome = 'disabled_in_app';
      await _plugin.cancel(baseId + 1);
    }
  }

  Future<void> scheduleExamReminder({
    required String examId,
    required String title,
    required DateTime deadline,
    int reminderMinutes = defaultReminderMinutes,
  }) async {
    if (!_notificationsEnabled) {
      _lastExamDeadlineOutcome = 'disabled_in_app';
      await cancelExamReminder(examId);
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(deadline.add(const Duration(minutes: 1)))) {
      _lastExamDeadlineOutcome = 'skipped_stale';
      await cancelExamReminder(examId);
      return;
    }

    final baseId = _examNotificationId(examId);
    final reminderAt = deadline
      .subtract(Duration(minutes: reminderMinutes))
      .subtract(Duration(seconds: _leadCompensationSeconds));
    if (_reminderEnabled) {
      if (reminderAt.isBefore(now)) {
        await _showImmediate(
          id: baseId,
          title: 'Exam Reminder',
          body: _examLateReminderBody(title, deadline.difference(now)),
        );
      } else {
        await _scheduleAt(
          id: baseId,
          title: 'Exam Reminder',
          futureBody: _examReminderBody(title, reminderMinutes),
          immediateBody: _examLateReminderBody(title, deadline.difference(DateTime.now())),
          scheduledAt: reminderAt,
        );
      }
    } else {
      await _plugin.cancel(baseId);
    }
    if (_deadlineEnabled) {
      _lastExamDeadlineOutcome = await _scheduleAt(
        id: baseId + 1,
        title: 'Exam Deadline',
        futureBody: 'Exam "$title" starts now.',
        immediateBody: 'Exam "$title" starts now.',
        scheduledAt: deadline.subtract(Duration(seconds: _leadCompensationSeconds)),
        showImmediatelyIfPast: true,
      );
    } else {
      _lastExamDeadlineOutcome = 'disabled_in_app';
      await _plugin.cancel(baseId + 1);
    }
  }

  Future<String> _scheduleAt({
    required int id,
    required String title,
    required String futureBody,
    required String immediateBody,
    required DateTime scheduledAt,
    bool showImmediatelyIfPast = false,
  }) async {
    // Keep scheduling idempotent: refresh existing schedule for this id.
    await _plugin.cancel(id);

    final now = DateTime.now();
    final androidDetails = AndroidNotificationDetails(
      'deadline_reminders',
      'Deadline Reminders',
      channelDescription: 'Alerts before task and exam deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canScheduleExact =
        await androidImplementation?.canScheduleExactNotifications() ?? false;
    final scheduleMode = canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    // If the target time is already behind us, either show now or drop it depending on the use case.
    if (scheduledAt.isBefore(now) ||
        !scheduledAt.isAfter(now.add(const Duration(seconds: 15)))) {
      if (scheduledAt.isBefore(now) && !showImmediatelyIfPast) {
        return 'skipped_stale';
      }
      await _plugin.show(
        id,
        title,
        immediateBody,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: id.toString(),
      );
      return 'shown_immediately';
    }

    await _plugin.zonedSchedule(
      id,
      title,
      futureBody,
      tz.TZDateTime.from(scheduledAt, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: scheduleMode,
      payload: id.toString(),
    );
    return 'scheduled_normally';
  }

  Future<void> cancelTaskReminder(String taskId) async {
    final baseId = _taskNotificationId(taskId);
    await _plugin.cancel(baseId);
    await _plugin.cancel(baseId + 1);
  }

  Future<void> cancelExamReminder(String examId) async {
    final baseId = _examNotificationId(examId);
    await _plugin.cancel(baseId);
    await _plugin.cancel(baseId + 1);
  }
}
