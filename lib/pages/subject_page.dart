import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../colorpalette/color_palette.dart';
import '../storage/subject.dart';
import '../storage/exam.dart';
import '../components/subject_card.dart';
import '../components/add_subject_dialog.dart';
import '../features/subject/presentation/bloc/subject_bloc.dart';
import '../features/subject/presentation/bloc/subject_event.dart';
import '../features/subject/presentation/bloc/subject_state.dart';
import '../features/exam/presentation/bloc/exam_bloc.dart';
import '../features/exam/presentation/bloc/exam_event.dart';
import '../features/exam/presentation/bloc/exam_state.dart';
import '../features/task/presentation/bloc/task_bloc.dart';
import '../features/task/presentation/bloc/task_event.dart';
import '../features/task/presentation/bloc/task_state.dart';
import '../features/auth/presentation/cubits/auth/auth_cubit.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  @override
  void initState() {
    super.initState();
    // Load subjects, tasks, and exams when page initializes
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<SubjectBloc>().add(LoadSubjectsEvent(userId));
      context.read<ExamBloc>().add(LoadExamsEvent(userId));
      context.read<TaskBloc>().add(LoadTasksEvent(userId));
    }
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

    // Add subject via BLoC
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (mounted && userId.isNotEmpty) {
      context.read<SubjectBloc>().add(CreateSubjectEvent(newSubject.name, userId));
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

    // Delete subject via BLoC
    if (mounted) {
      context.read<SubjectBloc>().add(DeleteSubjectEvent(subject.id));
    }
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
      body: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, subjectState) {
          return BlocBuilder<ExamBloc, ExamState>(
            builder: (context, examState) {
              return BlocBuilder<TaskBloc, TaskState>(
                builder: (context, taskState) {
                  List<Subject> subjects = [];
                  List<Exam> exams = [];
                  List<dynamic> tasks = [];

                  if (subjectState is SubjectLoaded) {
                    subjects = subjectState.subjects;
                  }

                  if (examState is ExamLoaded) {
                    exams = examState.exams;
                  }

                  if (taskState is TaskLoaded) {
                    tasks = taskState.tasks;
                  }

                  if (subjectState is SubjectLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (subjectState is SubjectError) {
                    return Center(child: Text(subjectState.message));
                  }

                  return subjects.isEmpty
                      ? const Center(child: Text("No subjects yet")) // Show when list is empty
                      : ListView.builder(
                          itemCount: subjects.length,
                          itemBuilder: (context, index) {
                            final subject = subjects[index];
                            // Count tasks for this subject
                            final taskCount = tasks.where((t) => t.subjectId == subject.id).length;
                            // Count exams for this subject
                            final examCount = exams.where((e) => e.subjectId == subject.id).length;

                            return SubjectCard(
                              subject: subject,
                              taskCount: taskCount,   // Pass task count to card
                              examCount: examCount,   // Pass exam count to card
                              onDelete: () => deleteSubject(subject), // Delete callback
                            );
                          },
                        );
                },
              );
            },
          );
        },
      ),
    );
  }
}
