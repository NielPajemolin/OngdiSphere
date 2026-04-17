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
  static const int _maxReminderMinutes = 10;
  static const int _notificationBlockSize = 32;

    static const String _kNotificationsEnabled = 'notifications_enabled';
    static const String _kReminderEnabled = 'notifications_reminder_enabled';
    static const String _kDeadlineEnabled = 'notifications_deadline_enabled';
    static const String _kLeadCompensationSeconds =
      'notifications_lead_compensation_seconds';
      static const String _kLastImmediateShownAtPrefix =
        'notifications_last_immediate_shown_at_';

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
    if (!_isInitialized) {
      await init();
    }

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
    if (!_isInitialized) {
      await init();
    }

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
    // Deterministic FNV-1a 32-bit hash to keep IDs stable across app restarts.
    var hash = 0x811c9dc5 ^ salt;
    for (final codeUnit in raw.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  int _notificationBlockBase(String raw, {required int salt}) {
    final seed = _stablePositiveId(raw, salt: salt) & 0x03ffffff;
    return seed * _notificationBlockSize;
  }

  int _taskReminderNotificationId(String taskId, int minutesLeft) {
    final base = _notificationBlockBase('task:$taskId', salt: 0x11);
    return base + minutesLeft;
  }

  int _taskDeadlineNotificationId(String taskId) {
    final base = _notificationBlockBase('task:$taskId', salt: 0x11);
    return base + (_notificationBlockSize - 1);
  }

  int _examReminderNotificationId(String examId, int minutesLeft) {
    final base = _notificationBlockBase('exam:$examId', salt: 0x33);
    return base + minutesLeft;
  }

  int _examDeadlineNotificationId(String examId) {
    final base = _notificationBlockBase('exam:$examId', salt: 0x33);
    return base + (_notificationBlockSize - 1);
  }

  String _formatMinutes(int minutes) {
    return minutes == 1 ? '1 minute' : '$minutes minutes';
  }

  int _remainingMinutesRoundedUp(Duration remaining) {
    final seconds = remaining.inSeconds;
    if (seconds <= 0) {
      return 0;
    }
    return ((seconds + 59) ~/ 60);
  }

  String _taskReminderBody(String title, int minutes) {
    return 'Task "$title" is due in ${_formatMinutes(minutes)}.';
  }

  String _taskLateReminderBody(String title, Duration remaining) {
    final minutes = _remainingMinutesRoundedUp(remaining);
    if (minutes <= 0) {
      return 'Task "$title" is due now.';
    }
    return 'Only ${_formatMinutes(minutes)} left for task "$title".';
  }

  String _examReminderBody(String title, int minutes) {
    return 'Exam "$title" starts in ${_formatMinutes(minutes)}.';
  }

  String _examLateReminderBody(String title, Duration remaining) {
    final minutes = _remainingMinutesRoundedUp(remaining);
    if (minutes <= 0) {
      return 'Exam "$title" starts now.';
    }
    return 'Only ${_formatMinutes(minutes)} left until exam "$title".';
  }

  Future<bool> _shouldThrottleImmediate(
    int id, {
    int throttleSeconds = 35,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kLastImmediateShownAtPrefix$id';
    final lastShownMillis = prefs.getInt(key);
    final nowMillis = DateTime.now().millisecondsSinceEpoch;

    // Prevent repeated alerts for the same notification id in quick succession
    // when BLoCs reload and reschedule near deadline.
    if (lastShownMillis != null &&
        nowMillis - lastShownMillis < throttleSeconds * 1000) {
      return true;
    }

    await prefs.setInt(key, nowMillis);
    return false;
  }

  Future<void> _showImmediate({
    required int id,
    required String title,
    required String body,
    int throttleSeconds = 35,
  }) async {
    if (await _shouldThrottleImmediate(id, throttleSeconds: throttleSeconds)) {
      return;
    }

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
    if (!_isInitialized) {
      await init();
    }

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

    final reminderWindow = reminderMinutes.clamp(1, _maxReminderMinutes);
    var scheduledAnyFutureReminder = false;

    if (_reminderEnabled) {
      for (var minutesLeft = reminderWindow; minutesLeft >= 1; minutesLeft--) {
        final reminderId = _taskReminderNotificationId(taskId, minutesLeft);
        final reminderAt = deadline
            .subtract(Duration(minutes: minutesLeft))
            .subtract(Duration(seconds: _leadCompensationSeconds));

        if (reminderAt.isBefore(now)) {
          await _plugin.cancel(reminderId);
          continue;
        }

        scheduledAnyFutureReminder = true;
        await _scheduleAt(
          id: reminderId,
          title: 'Task Reminder',
          futureBody: _taskReminderBody(title, minutesLeft),
          immediateBody: _taskLateReminderBody(
            title,
            deadline.difference(DateTime.now()),
          ),
          scheduledAt: reminderAt,
        );
      }

      if (!scheduledAnyFutureReminder && now.isBefore(deadline)) {
        await _showImmediate(
          id: _taskReminderNotificationId(taskId, 0),
          title: 'Task Reminder',
          body: _taskLateReminderBody(title, deadline.difference(now)),
        );
      }
    } else {
      for (var minutesLeft = 0; minutesLeft <= _maxReminderMinutes; minutesLeft++) {
        await _plugin.cancel(_taskReminderNotificationId(taskId, minutesLeft));
      }
    }

    if (_deadlineEnabled) {
      _lastTaskDeadlineOutcome = await _scheduleAt(
        id: _taskDeadlineNotificationId(taskId),
        title: 'Task Deadline',
        futureBody: 'Task "$title" is due now.',
        immediateBody: 'Task "$title" is due now.',
        scheduledAt: deadline,
        showImmediatelyIfPast: true,
        immediateThrottleSeconds: 300,
      );
    } else {
      _lastTaskDeadlineOutcome = 'disabled_in_app';
      await _plugin.cancel(_taskDeadlineNotificationId(taskId));
    }
  }

  Future<void> scheduleExamReminder({
    required String examId,
    required String title,
    required DateTime deadline,
    int reminderMinutes = defaultReminderMinutes,
  }) async {
    if (!_isInitialized) {
      await init();
    }

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

    final reminderWindow = reminderMinutes.clamp(1, _maxReminderMinutes);
    var scheduledAnyFutureReminder = false;

    if (_reminderEnabled) {
      for (var minutesLeft = reminderWindow; minutesLeft >= 1; minutesLeft--) {
        final reminderId = _examReminderNotificationId(examId, minutesLeft);
        final reminderAt = deadline
            .subtract(Duration(minutes: minutesLeft))
            .subtract(Duration(seconds: _leadCompensationSeconds));

        if (reminderAt.isBefore(now)) {
          await _plugin.cancel(reminderId);
          continue;
        }

        scheduledAnyFutureReminder = true;
        await _scheduleAt(
          id: reminderId,
          title: 'Exam Reminder',
          futureBody: _examReminderBody(title, minutesLeft),
          immediateBody: _examLateReminderBody(
            title,
            deadline.difference(DateTime.now()),
          ),
          scheduledAt: reminderAt,
        );
      }

      if (!scheduledAnyFutureReminder && now.isBefore(deadline)) {
        await _showImmediate(
          id: _examReminderNotificationId(examId, 0),
          title: 'Exam Reminder',
          body: _examLateReminderBody(title, deadline.difference(now)),
        );
      }
    } else {
      for (var minutesLeft = 0; minutesLeft <= _maxReminderMinutes; minutesLeft++) {
        await _plugin.cancel(_examReminderNotificationId(examId, minutesLeft));
      }
    }

    if (_deadlineEnabled) {
      _lastExamDeadlineOutcome = await _scheduleAt(
        id: _examDeadlineNotificationId(examId),
        title: 'Exam Deadline',
        futureBody: 'Exam "$title" starts now.',
        immediateBody: 'Exam "$title" starts now.',
        scheduledAt: deadline,
        showImmediatelyIfPast: true,
        immediateThrottleSeconds: 300,
      );
    } else {
      _lastExamDeadlineOutcome = 'disabled_in_app';
      await _plugin.cancel(_examDeadlineNotificationId(examId));
    }
  }

  Future<String> _scheduleAt({
    required int id,
    required String title,
    required String futureBody,
    required String immediateBody,
    required DateTime scheduledAt,
    bool showImmediatelyIfPast = false,
    int immediateThrottleSeconds = 35,
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
      await androidImplementation?.canScheduleExactNotifications();
    final scheduleMode = canScheduleExact
      // Null can happen on older Android versions where exact alarms are allowed
      // without the Android 12+ special app access; prefer exact in that case.
      ?? true
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    // If the target time is already behind us, either show now or drop it depending on the use case.
    // Keep near-future alerts scheduled by the OS to avoid firing early.
    if (scheduledAt.isBefore(now)) {
      if (await _shouldThrottleImmediate(
        id,
        throttleSeconds: immediateThrottleSeconds,
      )) {
        return 'throttled_duplicate_immediate';
      }
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
    if (!_isInitialized) {
      await init();
    }

    for (var minutesLeft = 0; minutesLeft <= _maxReminderMinutes; minutesLeft++) {
      await _plugin.cancel(_taskReminderNotificationId(taskId, minutesLeft));
    }
    await _plugin.cancel(_taskDeadlineNotificationId(taskId));
  }

  Future<void> cancelExamReminder(String examId) async {
    if (!_isInitialized) {
      await init();
    }

    for (var minutesLeft = 0; minutesLeft <= _maxReminderMinutes; minutesLeft++) {
      await _plugin.cancel(_examReminderNotificationId(examId, minutesLeft));
    }
    await _plugin.cancel(_examDeadlineNotificationId(examId));
  }
}
