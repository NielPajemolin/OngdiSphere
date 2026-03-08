import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../colorpalette/color_palette.dart';
import '../storage/subject.dart';
import '../storage/task.dart';

/// A dialog widget that allows the user to add or edit a task.
/// Users can select a subject, enter a task title, and pick a deadline date & time.
/// The dialog is responsive using MediaQuery for sizes.
class AddTaskDialog extends StatefulWidget {
  final List<Subject> subjects; // List of subjects to choose from
  final Task? task; // Existing task for editing, null for adding new
  
  const AddTaskDialog({
    super.key,
    required this.subjects,
    this.task,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController taskController = TextEditingController(); // Controller for task name input
  Subject? selectedSubject; // Currently selected subject from dropdown
  DateTime? selectedDate; // Selected deadline for the task

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing an existing task
    if (widget.task != null) {
      taskController.text = widget.task!.title;
      selectedSubject = widget.subjects.firstWhere(
        (s) => s.id == widget.task!.subjectId,
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

  /// Opens date picker followed by time picker to select a full DateTime.
  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  /// Called when the "Add" or "Update" button is pressed.
  /// Validates inputs and returns the new or updated Task object to the caller.
  void submit() {
    if (taskController.text.isEmpty || selectedSubject == null || selectedDate == null) {
      Navigator.of(context).pop({'error': 'fields-missing'});
      return;
    }

    final newTask = Task(
      id: widget.task?.id ?? const Uuid().v4(), // Keep existing ID when editing, generate new when adding
      title: taskController.text,
      subjectId: selectedSubject!.id,
      subjectName: selectedSubject!.name,
      dateTime: selectedDate!,
      done: widget.task?.done ?? false, // Keep done status when editing, default to false when adding
    );

    // Pass back the task and the associated subject
    Navigator.of(context).pop({'task': newTask, 'subject': selectedSubject});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width; // For responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      backgroundColor: colors.surface, // Dialog background color
      title: Text(
        widget.task == null ? "Add Task" : "Edit Task",
        style: TextStyle(fontSize: screenWidth * 0.05),
      ),
      content: SizedBox(
        width: screenWidth * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown for selecting the subject
            DropdownButtonFormField<Subject>(
              initialValue: selectedSubject,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Subject",
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              ),
              items: widget.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject.name, style: TextStyle(fontSize: screenWidth * 0.045)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedSubject = value),
            ),
            SizedBox(height: screenHeight * 0.015),

            // Text field for entering task title
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: "Task Name",
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),

            // Button to pick deadline date & time
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: pickDateTime,
                child: Text(
                  selectedDate == null
                      ? "Pick Date & Time"
                      : DateFormat('yyyy-MM-dd – HH:mm').format(selectedDate!.toLocal()),
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
              ),
            ),
          ],
        ),
      ),

      // Dialog action buttons
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel without returning any data
          child: Text("Cancel", style: TextStyle(fontSize: screenWidth * 0.045)),
        ),
        TextButton(
          onPressed: submit, // Validate and return the task
          child: Text(
            widget.task == null ? "Add" : "Update",
            style: TextStyle(fontSize: screenWidth * 0.045),
          ),
        ),
      ],
    );
  }
}
