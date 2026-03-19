import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?>? onDoneChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.onDoneChanged,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final isOverdue = task.done
        ? (task.wasLate ?? false)
        : task.dateTime.isBefore(DateTime.now());

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
            // Custom Checkbox with animation
            InkWell(
              onTap: () => onDoneChanged?.call(!task.done),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: task.done
                      ? colors.primary.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: task.done
                        ? colors.primary
                        : colors.primary.withValues(alpha: 0.3),
                    width: task.done ? 2 : 1.5,
                  ),
                ),
                child: AnimatedScale(
                  scale: task.done ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: task.done
                      ? Icon(
                          Icons.check_rounded,
                          color: colors.primary,
                          size: 24,
                          weight: 600,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: colors.tertiaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      decoration: task.done ? TextDecoration.lineThrough : null,
                      decorationThickness: 2,
                      decorationColor: colors.tertiaryText.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 13, color: colors.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.subjectName,
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
                        Icons.schedule_rounded,
                        size: 13,
                        color: isOverdue ? Colors.red : Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat.yMd().add_jm().format(task.dateTime.toLocal()),
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
            // Edit and Delete Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  Material(
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
                const SizedBox(width: 6),
                Material(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
