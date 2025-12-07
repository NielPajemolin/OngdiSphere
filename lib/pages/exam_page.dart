import 'package:flutter/material.dart';
import 'package:ongdisphere/components/add_task_dialog.dart';
import '../colorpalette/color_palette.dart';
import '../storage/storage_service.dart';
import '../storage/exam.dart';
import '../storage/subject.dart';
import '../components/exam_card.dart';

/// Page displaying all exams, with filtering, adding, deleting, and marking done.
class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final StorageService storage = StorageService(); // Handles persistent storage
  List<Exam> exams = []; // All exams
  List<Subject> subjects = []; // All subjects (used for filtering & assigning exams)
  String? selectedSubjectId; // Currently selected subject filter

  @override
  void initState() {
    super.initState();
    loadData(); // Load exams and subjects when the page initializes
  }

  /// Loads subjects and exams from storage
  Future<void> loadData() async {
    subjects = await storage.readSubjects();
    exams = await storage.readExams();
    if (!mounted) return; // Prevent setState if widget is disposed
    setState(() {});
  }

  /// Opens a dialog to add a new exam and saves it
  Future<void> addExam() async {
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects available')),
      );
      return;
    }

    // Show the AddExam dialog
    final result = await showAddExamDialog(context: context, subjects: subjects);
    if (!mounted || result == null || result['error'] != null) return;

    final Exam newExam = result['exam'];
    exams.add(newExam);

    try {
      await storage.saveExams(exams); // Save updated list
      if (!mounted) return;
      setState(() {}); // Refresh UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam added successfully')),
      );
    } catch (e) {
      exams.removeLast(); // Rollback if saving fails
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save exam: $e')),
      );
    }
  }

  /// Deletes an exam after user confirmation
  Future<void> deleteExam(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    exams.removeAt(index); // Remove exam from list

    try {
      await storage.saveExams(exams); // Save updated list
      if (!mounted) return;
      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete exam: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Apply filter: show all exams or only those matching the selected subject and not done
    final filteredExams = selectedSubjectId == null
        ? exams.where((e) => !e.done).toList()
        : exams.where((e) => e.subjectId == selectedSubjectId && !e.done).toList();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          "Exams",
          style: TextStyle(
            color: colors.primaryText,
            fontSize: screenWidth * 0.07, // Responsive font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addExam,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Subject filter dropdown
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: DropdownButtonFormField<String>(
              value: selectedSubjectId,
              hint: const Text("Filter by Subject"),
              isExpanded: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text("All Subjects")), // Option to show all exams
                ...subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
              ],
              onChanged: (value) => setState(() => selectedSubjectId = value), // Apply filter
            ),
          ),

          // Exams list
          Expanded(
            child: filteredExams.isEmpty
                ? const Center(child: Text("No exams yet")) // Show message if no exams
                : ListView.builder(
                    itemCount: filteredExams.length,
                    itemBuilder: (context, index) {
                      final exam = filteredExams[index];
                      return ExamCard(
                        exam: exam,
                        onDoneChanged: (value) async {
                          exam.done = value ?? false; // Update done status
                          setState(() {}); // Refresh UI
                          await storage.saveExams(exams); // Persist changes
                        },
                        onDelete: () => deleteExam(exams.indexOf(exam)), // Delete exam
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
