import 'package:flutter/material.dart';
import '../colorpalette/color_palette.dart';
import '../storage/storage_service.dart';
import '../storage/task.dart';
import '../storage/exam.dart';
import '../storage/subject.dart';
import '../components/task_card.dart';
import '../components/exam_card.dart';

/// Page showing all tasks and exams that have been marked as done.
/// Users can delete items from this page, but cannot mark them as undone.
class DonePage extends StatefulWidget {
  const DonePage({super.key});

  @override
  State<DonePage> createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {
  final StorageService storage = StorageService(); // Handles reading/writing data
  List<Subject> subjects = []; // All subjects (to access their tasks)
  List<Task> doneTasks = []; // List of tasks marked as done
  List<Exam> doneExams = []; // List of exams marked as done

  @override
  void initState() {
    super.initState();
    loadData(); // Load done tasks and exams when page is initialized
  }

  /// Loads subjects and exams from storage, and filters for done items
  Future<void> loadData() async {
    subjects = await storage.readSubjects();
    final exams = await storage.readExams();

    // Filter only completed tasks across all subjects
    doneTasks = subjects.expand((s) => s.tasks).where((t) => t.done).toList();
    // Filter only completed exams
    doneExams = exams.where((e) => e.done).toList();

    if (!mounted) return;
    setState(() {}); // Refresh UI
  }

  /// Deletes a task from its subject and updates storage
  Future<void> deleteTask(Task task) async {
    final subjIndex = subjects.indexWhere((s) => s.tasks.contains(task));
    if (subjIndex == -1) return;

    subjects[subjIndex].tasks.remove(task);

    try {
      await storage.saveSubjects(subjects);
      await loadData(); // Refresh done list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  /// Deletes an exam from storage
  Future<void> deleteExam(Exam exam) async {
    final exams = await storage.readExams();
    exams.removeWhere((e) => e.id == exam.id);

    try {
      await storage.saveExams(exams);
      await loadData(); // Refresh done list
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

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          "Done",
          style: TextStyle(
            color: colors.primaryText,
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Completed Tasks
              Text(
                "Completed Tasks",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              doneTasks.isEmpty
                  ? const Text("No completed tasks") // Show placeholder if empty
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: doneTasks.length,
                      itemBuilder: (context, index) {
                        final task = doneTasks[index];
                        return TaskCard(
                          task: task,
                          onDelete: () => deleteTask(task), // Allow deletion
                          onDoneChanged: null, // Disable checkbox in Done page
                        );
                      },
                    ),
              const SizedBox(height: 20),

              // Section: Completed Exams
              Text(
                "Completed Exams",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              doneExams.isEmpty
                  ? const Text("No completed exams") // Show placeholder if empty
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: doneExams.length,
                      itemBuilder: (context, index) {
                        final exam = doneExams[index];
                        return ExamCard(
                          exam: exam,
                          onDelete: () => deleteExam(exam), // Allow deletion
                          onDoneChanged: null, // Disable checkbox in Done page
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
