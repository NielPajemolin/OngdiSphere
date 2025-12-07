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
  // Controller to manage the text input for the subject name
  final TextEditingController subjectController = TextEditingController();

  // Function triggered when the user taps the "Add" button
  void submit() {
    // Check if the text field is empty
    if (subjectController.text.isEmpty) {
      // Return an error map to indicate the field is missing
      Navigator.of(context).pop({'error': 'field-missing'});
      return;
    }

    // Create a new Subject object with a unique ID
    final newSubject = Subject(
      id: const Uuid().v4(),
      name: subjectController.text,
      tasks: [], // Initialize with empty task list
    );

    // Return the newly created subject to the caller
    Navigator.of(context).pop({'subject': newSubject});
  }

  @override
  Widget build(BuildContext context) {
    // Access custom theme colors
    final colors = Theme.of(context).extension<AppColors>()!;

    return AlertDialog(
      backgroundColor: colors.surface, // Dialog background color
      title: const Text("Add Subject"), // Dialog title
      content: TextField(
        controller: subjectController, // Connect text field to controller
        decoration: const InputDecoration(
          labelText: "Subject Name", // Label inside the text field
          border: OutlineInputBorder(), // Outline style for the input field
        ),
      ),
      actions: [
        // Cancel button closes the dialog without returning data
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text("Cancel"),
        ),
        // Add button triggers the submit function
        ElevatedButton(
          onPressed: submit,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
