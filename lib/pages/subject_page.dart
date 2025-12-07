import 'package:flutter/material.dart';
import '../colorpalette/color_palette.dart';
import '../storage/subject.dart';
import '../storage/exam.dart';
import '../components/subject_card.dart';
import '../components/add_subject_dialog.dart';
import '../storage/storage_service.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  // Instance of storage service to read/write subjects and exams
  final StorageService storage = StorageService();

  // List to store subjects loaded from storage
  List<Subject> subjects = [];

  // List to store exams loaded from storage
  List<Exam> exams = [];

  @override
  void initState() {
    super.initState();
    loadData(); // Load subjects and exams when the page is initialized
  }

  // Load subjects and exams from persistent storage
  Future<void> loadData() async {
    subjects = await storage.readSubjects(); // Read subjects from storage
    exams = await storage.readExams();       // Read exams from storage
    if (!mounted) return;                     // Check if widget is still mounted
    setState(() {});                          // Refresh the UI with the loaded data
  }

  // Show a dialog to add a new subject
  Future<void> addSubject() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => const AddSubjectDialog(), // Custom dialog to enter subject name
    );

    // Exit if dialog was cancelled or returned an error
    if (!mounted || result == null || result['error'] != null) return;

    final Subject newSubject = result['subject']; // Retrieve new subject from dialog

    subjects.add(newSubject); // Add the new subject to the list

    try {
      await storage.saveSubjects(subjects); // Save updated subject list to storage
      if (!mounted) return;
      setState(() {});                     // Refresh UI
    } catch (e) {
      subjects.removeLast();                // Rollback if saving fails
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save subject: $e')), // Show error message
      );
    }
  }

  // Delete a subject with confirmation dialog
  Future<void> deleteSubject(Subject subject) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel deletion
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),  // Confirm deletion
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return; // Exit if deletion not confirmed

    // Remove the subject from the list
    subjects.removeWhere((s) => s.id == subject.id);

    // Also remove any exams associated with this subject
    exams.removeWhere((e) => e.subjectId == subject.id);

    try {
      // Save updated lists to storage
      await storage.saveSubjects(subjects);
      await storage.saveExams(exams);
      if (!mounted) return;
      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete subject: $e')), // Show error
      );
    }
  }

  // Count how many exams belong to a specific subject
  int getExamCount(Subject subject) {
    return exams.where((e) => e.subjectId == subject.id).length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!; // Get theme colors
    final screenWidth = MediaQuery.of(context).size.width;    // Responsive width

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          "Subjects",
          style: TextStyle(
            color: colors.primaryText,
            fontSize: screenWidth * 0.07,  // Responsive font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSubject, // Open dialog to add new subject
        child: const Icon(Icons.add),
      ),
      body: subjects.isEmpty
          ? const Center(child: Text("No subjects yet")) // Show when list is empty
          : ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final taskCount = subject.tasks.length;      // Count tasks
                final examCount = getExamCount(subject);    // Count exams

                return SubjectCard(
                  subject: subject,
                  taskCount: taskCount,   // Pass task count to card
                  examCount: examCount,   // Pass exam count to card
                  onDelete: () => deleteSubject(subject), // Delete callback
                );
              },
            ),
    );
  }
}
