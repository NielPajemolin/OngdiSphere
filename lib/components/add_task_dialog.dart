import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../colorpalette/color_palette.dart';
import '../storage/subject.dart';
import '../storage/exam.dart';

/// Shows a dialog for adding a new Exam to a selected Subject.
/// Returns a Map containing the new exam and the selected subject,
/// or an error message if validation fails.
Future<Map<String, dynamic>?> showAddExamDialog({
  required BuildContext context,
  required List<Subject> subjects,
}) async {
  final TextEditingController examController = TextEditingController(); // Controller for the exam name input
  Subject? selectedSubject; // The subject selected by the user
  DateTime? selectedDateTime; // The date & time picked by the user

  /// Opens date and time pickers sequentially and returns the combined DateTime
  Future<DateTime?> pickDateTime(BuildContext dialogContext) async {
    final date = await showDatePicker(
      context: dialogContext,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: dialogContext, // ignore: use_build_context_synchronously
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Main dialog UI
  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          final colors = Theme.of(context).extension<AppColors>()!; // Custom color palette
          final screenWidth = MediaQuery.of(context).size.width; // Screen width for responsive design
          final screenHeight = MediaQuery.of(context).size.height; // Screen height for responsive design

          return AlertDialog(
            backgroundColor: colors.surface, // Dialog background color
            title: Text("Add Exam", style: TextStyle(fontSize: screenWidth * 0.05)), // Dialog title

            // Dialog content
            content: SizedBox(
              width: screenWidth * 0.8, // Responsive width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown for selecting a subject
                  DropdownButtonFormField<Subject>(
                    initialValue: selectedSubject,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Subject",
                      border: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    ),
                    items: subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.name, style: TextStyle(fontSize: screenWidth * 0.045)),
                      );
                    }).toList(),
                    onChanged: (value) => setStateDialog(() => selectedSubject = value),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // TextField for entering exam name
                  TextField(
                    controller: examController,
                    decoration: InputDecoration(
                      labelText: "Exam Name",
                      border: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Button to pick date & time
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await pickDateTime(dialogContext);
                        if (picked == null) return;
                        selectedDateTime = picked;
                        if (!dialogContext.mounted) return;
                        setStateDialog(() {});
                      },
                      child: Text(
                        selectedDateTime == null
                            ? "Pick Date & Time"
                            : DateFormat('yyyy-MM-dd – HH:mm').format(selectedDateTime!.toLocal()),
                        style: TextStyle(fontSize: screenWidth * 0.045),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dialog actions
            actions: [
              // Cancel button
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text("Cancel", style: TextStyle(fontSize: screenWidth * 0.045)),
              ),

              // Add button
              TextButton(
                onPressed: () {
                  // Validation: all fields must be filled
                  if (examController.text.isEmpty || selectedSubject == null || selectedDateTime == null) {
                    Navigator.of(dialogContext).pop({'error': 'fields-missing'});
                    return;
                  }

                  // Create new Exam object
                  final newExam = Exam(
                    id: const Uuid().v4(),
                    title: examController.text,
                    subjectId: selectedSubject!.id,
                    subjectName: selectedSubject!.name,
                    dateTime: selectedDateTime!,
                    done: false, // Newly added exams start as not done
                  );

                  // Return the new exam and the selected subject
                  Navigator.of(dialogContext).pop({'exam': newExam, 'subject': selectedSubject});
                },
                child: Text("Add", style: TextStyle(fontSize: screenWidth * 0.045)),
              ),
            ],
          );
        },
      );
    },
  );
}
