import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/animations/press_scale.dart';
import 'package:ongdisphere/shared/widgets/card_action_buttons.dart';
import 'package:ongdisphere/shared/widgets/kuromi_accents.dart';
import 'package:ongdisphere/shared/widgets/status_badge.dart';

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
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 390;

    final isOverdue = task.done
        ? (task.wasLate ?? false)
        : task.dateTime.isBefore(DateTime.now());

    return Card(
      margin: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 10, vertical: 6),
      color: Theme.of(context).cardColor,
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
      child: KuromiDecoratedContainer(
        borderRadius: BorderRadius.circular(20),
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 10 : 14,
          vertical: isNarrow ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        patternColor: colors.secondary,
        patternOpacity: 0.06,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            color: colors.tertiaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: isNarrow ? 14 : 16,
                            decoration: task.done ? TextDecoration.lineThrough : null,
                            decorationThickness: 2,
                            decorationColor: colors.tertiaryText.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        isComplete: task.done,
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
                        color: isOverdue
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat.yMd().add_jm().format(task.dateTime.toLocal()),
                          style: TextStyle(
                            color: isOverdue
                                ? Colors.red
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
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
                onTap: () => onDoneChanged?.call(!task.done),
                borderRadius: BorderRadius.circular(8),
                splashColor: task.done ? Colors.green.withValues(alpha: 0.1) : colors.primary.withValues(alpha: 0.1),
                highlightColor: task.done ? Colors.green.withValues(alpha: 0.08) : colors.primary.withValues(alpha: 0.08),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: task.done
                        ? Colors.green.withValues(alpha: 0.15)
                        : colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: task.done
                          ? Colors.green.withValues(alpha: 0.4)
                          : colors.primary.withValues(alpha: 0.2),
                      width: task.done ? 1.5 : 1,
                    ),
                    boxShadow: task.done
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
                    scale: task.done ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: task.done ? 1.0 : 0.0,
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
            CardActionButtons(
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
