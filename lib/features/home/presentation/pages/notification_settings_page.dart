import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/core/services/local_notification_service.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/features/auth/auth.dart';
import 'package:ongdisphere/features/exam/exam.dart';
import 'package:ongdisphere/features/task/task.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _loading = true;
  bool _notificationsEnabled = true;
  bool _reminderEnabled = true;
  bool _deadlineEnabled = true;
  int _leadCompensationSeconds = 15;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await LocalNotificationService.instance
        .getAppNotificationSettings();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = settings['notificationsEnabled'] as bool;
      _reminderEnabled = settings['reminderEnabled'] as bool;
      _deadlineEnabled = settings['deadlineEnabled'] as bool;
      _leadCompensationSeconds = settings['leadCompensationSeconds'] as int;
      _loading = false;
    });
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Master switch for all app notifications.'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    await _save(notificationsEnabled: value);
                  },
                ),
                SwitchListTile.adaptive(
                  title: const Text('5/10 Minute Reminders'),
                  subtitle: const Text('Show advance reminders before deadlines.'),
                  value: _reminderEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          setState(() => _reminderEnabled = value);
                          await _save(reminderEnabled: value);
                        }
                      : null,
                ),
                SwitchListTile.adaptive(
                  title: const Text('Deadline Alerts'),
                  subtitle: const Text('Show the final alert at deadline time.'),
                  value: _deadlineEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          setState(() => _deadlineEnabled = value);
                          await _save(deadlineEnabled: value);
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timing Compensation',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Advance notifications by $_leadCompensationSeconds seconds to offset device delay.',
                        ),
                        const SizedBox(height: 8),
                        Slider(
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
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
                  label: const Text('Send Test Notification'),
                ),
              ],
            ),
    );
  }
}
