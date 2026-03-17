import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../colorpalette/color_palette.dart';
import '../storage/subject.dart';

class AddSubjectDialog extends StatefulWidget {
  const AddSubjectDialog({super.key});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final TextEditingController subjectController = TextEditingController();

  void submit() {
    if (subjectController.text.isEmpty) {
      Navigator.of(context).pop({'error': 'field-missing'});
      return;
    }

    final newSubject = Subject(
      id: const Uuid().v4(),
      name: subjectController.text,
      tasks: [],
    );

    Navigator.of(context).pop({'subject': newSubject});
  }

  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.menu_book_rounded, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'Add Subject',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: TextField(
          controller: subjectController,
          autofocus: true,
          style: TextStyle(
            color: colors.tertiaryText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          onSubmitted: (_) => submit(),
          decoration: InputDecoration(
            labelText: 'Subject Name',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: submit, child: const Text('Add')),
      ],
    );
  }
}
