import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';

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
      done: widget.task?.done ?? false,
    );

    Navigator.of(context).pop({'task': newTask, 'subject': selectedSubject});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        widget.task == null ? 'Add Task' : 'Edit Task',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Subject>(
              initialValue: selectedSubject,
              isExpanded: true,
              borderRadius: BorderRadius.circular(14),
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
                labelText: 'Subject',
                labelStyle: TextStyle(
                  color: colors.tertiaryText.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.95),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.primary, width: 1.4),
                ),
                prefixIcon: Icon(
                  Icons.menu_book_rounded,
                  color: colors.primary,
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
            const SizedBox(height: 12),
            TextField(
              controller: taskController,
              style: TextStyle(
                color: colors.tertiaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Task Name',
                labelStyle: TextStyle(
                  color: colors.tertiaryText.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.95),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colors.primary.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.primary, width: 1.4),
                ),
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selectedDate != null
                      ? colors.primary
                      : colors.primary.withValues(alpha: 0.2),
                  width: selectedDate != null ? 1.4 : 1.0,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: pickDateTime,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate == null
                            ? 'Pick Date & Time'
                            : DateFormat(
                                'yyyy-MM-dd – HH:mm',
                              ).format(selectedDate!.toLocal()),
                        style: TextStyle(
                          color: selectedDate == null
                              ? colors.tertiaryText.withValues(alpha: 0.5)
                              : colors.tertiaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: submit,
          child: Text(widget.task == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
