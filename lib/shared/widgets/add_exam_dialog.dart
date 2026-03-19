import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/animations/animated_form_dialog.dart';
import 'package:ongdisphere/shared/animations/press_scale.dart';

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

          return AnimatedFormDialog(
            title: exam == null ? 'Add Exam' : 'Edit Exam',
            icon: exam != null ? Icons.edit_rounded : Icons.add_rounded,
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
                      const SizedBox(height: 18),
                      // Exam Name Label
                      Text(
                        'Exam Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.tertiaryText.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: examController,
                        style: TextStyle(
                          color: colors.tertiaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter exam name',
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
                        'Exam Date & Time',
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
                            color: selectedDateTime != null
                                ? colors.primary
                                : colors.primary.withValues(alpha: 0.15),
                            width: selectedDateTime != null ? 2 : 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final picked = await pickDateTime(dialogContext);
                              if (picked == null) return;
                              selectedDateTime = picked;
                              if (!dialogContext.mounted) return;
                              setStateDialog(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_rounded,
                                    color: colors.primary.withValues(alpha: 0.7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedDateTime == null
                                          ? 'Pick Date & Time'
                                          : DateFormat(
                                              'E, MMM d – HH:mm',
                                            ).format(selectedDateTime!.toLocal()),
                                      style: TextStyle(
                                        color: selectedDateTime == null
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
                      const SizedBox(height: 28),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PressScale(
                            child: TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
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
                                exam == null ? 'Add' : 'Update',
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
        },
      );
    },
  );
}
