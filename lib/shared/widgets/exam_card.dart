import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/animations/press_scale.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final ValueChanged<bool?>? onDoneChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ExamCard({
    super.key,
    required this.exam,
    this.onDoneChanged,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final isOverdue = exam.done
        ? (exam.wasLate ?? false)
        : exam.dateTime.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.white,
      shadowColor: isOverdue ? Colors.red.withValues(alpha: 0.2) : colors.primary.withValues(alpha: 0.15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.5)
              : colors.primary.withValues(alpha: 0.2),
          width: isOverdue ? 1.5 : 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Exam Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exam.title,
                          style: TextStyle(
                            color: colors.tertiaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            decoration: exam.done ? TextDecoration.lineThrough : null,
                            decorationThickness: 2,
                            decorationColor: colors.tertiaryText.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: exam.done
                              ? Colors.green.withValues(alpha: 0.12)
                              : colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: exam.done
                                ? Colors.green.withValues(alpha: 0.3)
                                : colors.primary.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          exam.done ? 'Completed' : 'Pending',
                          style: TextStyle(
                            color: exam.done ? Colors.green : colors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 13, color: colors.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          exam.subjectName,
                          style: TextStyle(
                            color: colors.primary.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 13,
                        color: isOverdue ? Colors.red : Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat.yMd().add_jm().format(exam.dateTime.toLocal()),
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.black54,
                            fontSize: 12,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'Late',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Animated Completion Button
            PressScale(
              child: InkWell(
                onTap: () => onDoneChanged?.call(!exam.done),
                borderRadius: BorderRadius.circular(8),
                splashColor: exam.done ? Colors.green.withValues(alpha: 0.1) : colors.primary.withValues(alpha: 0.1),
                highlightColor: exam.done ? Colors.green.withValues(alpha: 0.08) : colors.primary.withValues(alpha: 0.08),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: exam.done
                        ? Colors.green.withValues(alpha: 0.15)
                        : colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: exam.done
                          ? Colors.green.withValues(alpha: 0.4)
                          : colors.primary.withValues(alpha: 0.2),
                      width: exam.done ? 1.5 : 1,
                    ),
                    boxShadow: exam.done
                        ? [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedScale(
                    scale: exam.done ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: exam.done ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 240),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Edit and Delete Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  PressScale(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: colors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                PressScale(
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
