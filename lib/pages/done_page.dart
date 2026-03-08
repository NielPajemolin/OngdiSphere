import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../colorpalette/color_palette.dart';
import '../storage/task.dart';
import '../storage/exam.dart';
import '../components/task_card.dart';
import '../components/exam_card.dart';
import '../features/task/presentation/bloc/task_bloc.dart';
import '../features/task/presentation/bloc/task_event.dart';
import '../features/task/presentation/bloc/task_state.dart';
import '../features/exam/presentation/bloc/exam_bloc.dart';
import '../features/exam/presentation/bloc/exam_event.dart';
import '../features/exam/presentation/bloc/exam_state.dart';

/// Page showing all tasks and exams that have been marked as done.
/// Users can delete items from this page, but cannot mark them as undone.
class DonePage extends StatefulWidget {
  const DonePage({super.key});

  @override
  State<DonePage> createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {
  @override
  void initState() {
    super.initState();
    // Load tasks and exams when page initializes
    context.read<TaskBloc>().add(const LoadTasksEvent());
    context.read<ExamBloc>().add(const LoadExamsEvent());
  }

  /// Shows a confirmation dialog and deletes a task using BLoC
  void deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog and deletes an exam using BLoC
  void deleteExam(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Are you sure you want to delete "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExamBloc>().add(DeleteExamEvent(exam.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, taskState) {
          return BlocBuilder<ExamBloc, ExamState>(
            builder: (context, examState) {
              List<Task> doneTasks = [];
              List<Exam> doneExams = [];

              if (taskState is TaskLoaded) {
                doneTasks = taskState.tasks.where((t) => t.done).toList();
              }

              if (examState is ExamLoaded) {
                doneExams = examState.exams.where((e) => e.done).toList();
              }

              return SingleChildScrollView(
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
                                  onEdit: null, // Hide edit button in Done page
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
                                  onEdit: null, // Hide edit button in Done page
                                );
                              },
                            ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
