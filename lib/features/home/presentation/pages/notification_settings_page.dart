import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/core/services/local_notification_service.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/features/auth/auth.dart';
import 'package:ongdisphere/features/exam/exam.dart';
import 'package:ongdisphere/features/task/task.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _loading = true;
  bool _diagnosticsLoading = true;
  bool _notificationsEnabled = true;
  bool _reminderEnabled = true;
  bool _deadlineEnabled = true;
  int _leadCompensationSeconds = 15;
  Map<String, String> _diagnostics = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await LocalNotificationService.instance
        .getAppNotificationSettings();
    final diagnostics = await LocalNotificationService.instance.getDiagnostics();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = settings['notificationsEnabled'] as bool;
      _reminderEnabled = settings['reminderEnabled'] as bool;
      _deadlineEnabled = settings['deadlineEnabled'] as bool;
      _leadCompensationSeconds = settings['leadCompensationSeconds'] as int;
      _diagnostics = diagnostics;
      _loading = false;
      _diagnosticsLoading = false;
    });
  }

  Future<void> _refreshBackgroundCheck() async {
    setState(() => _diagnosticsLoading = true);
    final diagnostics = await LocalNotificationService.instance.getDiagnostics();
    if (!mounted) return;
    setState(() {
      _diagnostics = diagnostics;
      _diagnosticsLoading = false;
    });
  }

  String _statusFromBoolString(String key) {
    final value = _diagnostics[key] ?? 'false';
    return value == 'true' ? 'Enabled' : 'Disabled';
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _save({
    bool? notificationsEnabled,
    bool? reminderEnabled,
    bool? deadlineEnabled,
    int? leadCompensationSeconds,
  }) async {
    final authCubit = context.read<AuthCubit>();
    final taskBloc = context.read<TaskBloc>();
    final examBloc = context.read<ExamBloc>();

    await LocalNotificationService.instance.updateAppNotificationSettings(
      notificationsEnabled: notificationsEnabled,
      reminderEnabled: reminderEnabled,
      deadlineEnabled: deadlineEnabled,
      leadCompensationSeconds: leadCompensationSeconds,
    );

    final userId = authCubit.currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      taskBloc.add(LoadTasksEvent(userId));
      examBloc.add(LoadExamsEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 768;
    final horizontalPadding = isTablet ? 24.0 : 16.0;
    final sectionSpacing = isTablet ? 16.0 : 12.0;
    final maxContentWidth = screenWidth >= 1100 ? 860.0 : 760.0;
    final useMaxWidth = screenWidth >= 900;
    final titleSize = isTablet ? 18.0 : 16.0;
    final bodySize = isTablet ? 14.5 : 14.0;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: TextStyle(fontSize: isTablet ? 22 : 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: useMaxWidth ? maxContentWidth : double.infinity,
                ),
                child: ListView(
                  padding: EdgeInsets.all(horizontalPadding),
                  children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 4 : 0,
                  ),
                  title: Text(
                    'Enable Notifications',
                    style: TextStyle(fontSize: titleSize),
                  ),
                  subtitle: Text(
                    'Master switch for all app notifications.',
                    style: TextStyle(fontSize: bodySize),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    await _save(notificationsEnabled: value);
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 4 : 0,
                  ),
                  title: Text(
                    '5/10 Minute Reminders',
                    style: TextStyle(fontSize: titleSize),
                  ),
                  subtitle: Text(
                    'Show advance reminders before deadlines.',
                    style: TextStyle(fontSize: bodySize),
                  ),
                  value: _reminderEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          setState(() => _reminderEnabled = value);
                          await _save(reminderEnabled: value);
                        }
                      : null,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 4 : 0,
                  ),
                  title: Text(
                    'Deadline Alerts',
                    style: TextStyle(fontSize: titleSize),
                  ),
                  subtitle: Text(
                    'Show the final alert at deadline time.',
                    style: TextStyle(fontSize: bodySize),
                  ),
                  value: _deadlineEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          setState(() => _deadlineEnabled = value);
                          await _save(deadlineEnabled: value);
                        }
                      : null,
                ),
                SizedBox(height: sectionSpacing),
                AppSectionCard(
                  title: 'Timing Compensation',
                  subtitle:
                      'Advance notifications by $_leadCompensationSeconds seconds to offset device delay.',
                  child: Slider(
                    value: _leadCompensationSeconds.toDouble(),
                    min: 0,
                    max: 30,
                    divisions: 6,
                    label: '$_leadCompensationSeconds s',
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _leadCompensationSeconds = value.toInt();
                            });
                          }
                        : null,
                    onChangeEnd: _notificationsEnabled
                        ? (value) async {
                            await _save(
                              leadCompensationSeconds: value.toInt(),
                            );
                          }
                        : null,
                  ),
                ),
                SizedBox(height: sectionSpacing),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 14 : 12,
                      horizontal: isTablet ? 18 : 16,
                    ),
                  ),
                  onPressed: _notificationsEnabled
                      ? () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await LocalNotificationService.instance
                              .showTestNotification();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Test notification sent.'),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.notifications_active_rounded),
                  label: Text(
                    'Send Test Notification',
                    style: TextStyle(fontSize: isTablet ? 15 : 14),
                  ),
                ),
                SizedBox(height: sectionSpacing),
                AppSectionCard(
                  title: 'Background Notification Check',
                  trailing: IconButton(
                    tooltip: 'Refresh check',
                    onPressed: _refreshBackgroundCheck,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  child: _diagnosticsLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _statusRow(
                              'Notification Permission',
                              _statusFromBoolString(
                                'android_notifications_enabled',
                              ),
                            ),
                            _statusRow(
                              'Exact Alarm Permission',
                              _statusFromBoolString(
                                'android_exact_alarms_allowed',
                              ),
                            ),
                            _statusRow(
                              'Pending Scheduled Notifications',
                              _diagnostics['pending_notifications'] ?? '0',
                            ),
                            _statusRow(
                              'Timezone',
                              _diagnostics['timezone'] ?? 'Unknown',
                            ),
                            _statusRow(
                              'Service Initialized',
                              _statusFromBoolString('initialized'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tip: if checks are enabled but reminders still fail while the app is closed, set battery mode to unrestricted for this app.',
                              style: TextStyle(fontSize: bodySize),
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
}
