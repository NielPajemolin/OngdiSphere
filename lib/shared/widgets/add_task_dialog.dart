import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/animations/animated_form_dialog.dart';
import 'package:ongdisphere/shared/animations/press_scale.dart';

class AddTaskDialog extends StatefulWidget {
  final List<Subject> subjects;
  final Task? task;

  const AddTaskDialog({super.key, required this.subjects, this.task});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController taskController = TextEditingController();
  Subject? selectedSubject;
  DateTime? selectedDate;
  int selectedReminderMinutes = 10;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      taskController.text = widget.task!.title;
      selectedSubject = widget.subjects.firstWhere(
        (subject) => subject.id == widget.task!.subjectId,
        orElse: () => widget.subjects.first,
      );
      selectedDate = widget.task!.dateTime;
      selectedReminderMinutes = widget.task!.reminderMinutes ?? 10;
    }
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted || time == null) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void submit() {
    if (taskController.text.isEmpty ||
        selectedSubject == null ||
        selectedDate == null) {
      Navigator.of(context).pop({'error': 'fields-missing'});
      return;
    }

    final newTask = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: taskController.text,
      subjectId: selectedSubject!.id,
      subjectName: selectedSubject!.name,
      dateTime: selectedDate!,
      reminderMinutes: selectedReminderMinutes,
      done: widget.task?.done ?? false,
    );

    Navigator.of(context).pop({'task': newTask, 'subject': selectedSubject});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AnimatedFormDialog(
      title: widget.task == null ? 'Add Task' : 'Edit Task',
      icon: widget.task != null ? Icons.edit_rounded : Icons.add_rounded,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                // Subject Label
                Text(
                  'Subject',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.tertiaryText.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Subject>(
                  initialValue: selectedSubject,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(16),
                  style: TextStyle(
                    color: colors.tertiaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.primary,
                    size: 24,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.97),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.menu_book_rounded,
                      color: colors.primary.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                  items: widget.subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => selectedSubject = value),
                ),
                const SizedBox(height: 18),
                // Task Name Label
                Text(
                  'Task Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.tertiaryText.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: taskController,
                  style: TextStyle(
                    color: colors.tertiaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter task name',
                    hintStyle: TextStyle(
                      color: colors.tertiaryText.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.97),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.edit_note_rounded,
                      color: colors.primary.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Date & Time Label
                Text(
                  'Due Date & Time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.tertiaryText.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedDate != null
                          ? colors.primary
                          : colors.primary.withValues(alpha: 0.15),
                      width: selectedDate != null ? 2 : 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: pickDateTime,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: colors.primary.withValues(alpha: 0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? 'Pick Date & Time'
                                    : DateFormat(
                                        'E, MMM d – HH:mm',
                                      ).format(selectedDate!.toLocal()),
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? colors.tertiaryText.withValues(alpha: 0.4)
                                      : colors.tertiaryText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.access_time_rounded,
                              color: colors.primary.withValues(alpha: 0.5),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.tertiaryText.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: selectedReminderMinutes,
                  borderRadius: BorderRadius.circular(16),
                  style: TextStyle(
                    color: colors.tertiaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.97),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colors.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.notifications_active_rounded,
                      color: colors.primary.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                    DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedReminderMinutes = value);
                  },
                ),
                const SizedBox(height: 28),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PressScale(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PressScale(
                      child: FilledButton(
                        onPressed: submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          widget.task == null ? 'Add' : 'Update',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
