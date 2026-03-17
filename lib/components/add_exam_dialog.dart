import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../colorpalette/color_palette.dart';
import '../storage/subject.dart';
import '../storage/exam.dart';

Future<Map<String, dynamic>?> showAddExamDialog({
  required BuildContext context,
  required List<Subject> subjects,
  Exam? exam,
}) async {
  final TextEditingController examController = TextEditingController(
    text: exam?.title ?? '',
  );
  Subject? selectedSubject = exam != null
      ? subjects.firstWhere(
          (subject) => subject.id == exam.subjectId,
          orElse: () => subjects.first,
        )
      : null;
  DateTime? selectedDateTime = exam?.dateTime;

  Future<DateTime?> pickDateTime(BuildContext dialogContext) async {
    final date = await showDatePicker(
      context: dialogContext,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (!dialogContext.mounted || date == null) return null;

    final time = await showTimePicker(
      context: dialogContext,
      initialTime: TimeOfDay.now(),
    );
    if (!dialogContext.mounted || time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          final colors = Theme.of(context).extension<AppColors>()!;

          return AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              exam == null ? 'Add Exam' : 'Edit Exam',
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
                    items: subjects
                        .map(
                          (subject) => DropdownMenuItem(
                            value: subject,
                            child: Text(subject.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setStateDialog(() => selectedSubject = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: examController,
                    style: TextStyle(
                      color: colors.tertiaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Exam Name',
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
                        color: selectedDateTime != null
                            ? colors.primary
                            : colors.primary.withValues(alpha: 0.2),
                        width: selectedDateTime != null ? 1.4 : 1.0,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final picked = await pickDateTime(dialogContext);
                        if (picked == null) return;
                        selectedDateTime = picked;
                        if (!dialogContext.mounted) return;
                        setStateDialog(() {});
                      },
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
                              selectedDateTime == null
                                  ? 'Pick Date & Time'
                                  : DateFormat(
                                      'yyyy-MM-dd – HH:mm',
                                    ).format(selectedDateTime!.toLocal()),
                              style: TextStyle(
                                color: selectedDateTime == null
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
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (examController.text.isEmpty ||
                      selectedSubject == null ||
                      selectedDateTime == null) {
                    Navigator.of(
                      dialogContext,
                    ).pop({'error': 'fields-missing'});
                    return;
                  }

                  final newExam = Exam(
                    id: exam?.id ?? const Uuid().v4(),
                    title: examController.text,
                    subjectId: selectedSubject!.id,
                    subjectName: selectedSubject!.name,
                    dateTime: selectedDateTime!,
                    done: exam?.done ?? false,
                  );

                  Navigator.of(
                    dialogContext,
                  ).pop({'exam': newExam, 'subject': selectedSubject});
                },
                child: Text(exam == null ? 'Add' : 'Update'),
              ),
            ],
          );
        },
      );
    },
  );
}
