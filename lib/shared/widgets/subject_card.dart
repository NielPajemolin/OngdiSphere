import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final int taskCount;
  final int examCount;
  final VoidCallback? onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.taskCount,
    required this.examCount,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0x1A1565C0),
              child: Icon(Icons.menu_book_rounded, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: TextStyle(
                      color: colors.tertiaryText,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tasks: $taskCount',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  Text(
                    'Exams: $examCount',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
