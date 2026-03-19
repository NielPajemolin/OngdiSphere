import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';
import 'package:ongdisphere/features/subject/presentation/bloc/subject_bloc.dart';
import 'package:ongdisphere/features/subject/presentation/bloc/subject_event.dart';
import 'package:ongdisphere/features/subject/presentation/bloc/subject_state.dart';
import 'package:ongdisphere/features/exam/exam.dart';
import 'package:ongdisphere/features/task/task.dart';
import 'package:ongdisphere/features/auth/auth.dart';

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
      builder: (_) =>
          const AddSubjectDialog(), // Custom dialog to enter subject name
    );

    // Exit if dialog was cancelled or returned an error
    if (!mounted || result == null || result['error'] != null) return;

    final Subject newSubject =
        result['subject']; // Retrieve new subject from dialog

    // Add subject via BLoC
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (mounted && userId.isNotEmpty) {
      context.read<SubjectBloc>().add(
        CreateSubjectEvent(newSubject.name, userId),
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
            onPressed: () =>
                Navigator.of(context).pop(false), // Cancel deletion
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(true), // Confirm deletion
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
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Subjects',
          style: TextStyle(
            color: colors.tertiaryText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSubject, // Open dialog to add new subject
        child: const Icon(Icons.add_rounded),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surface, const Color(0xFFE6F1FF)],
          ),
        ),
        child: BlocBuilder<SubjectBloc, SubjectState>(
          builder: (context, subjectState) {
            return BlocBuilder<ExamBloc, ExamState>(
              builder: (context, examState) {
                return BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, taskState) {
                    List<Subject> subjects = [];
                    List<Exam> exams = [];
                    List<Task> tasks = [];

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

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                      children: [
                        SummaryHeaderCard(
                          icon: Icons.menu_book_rounded,
                          iconColor: const Color(0xFF0D47A1),
                          iconBackgroundColor: const Color(0x1A1565C0),
                          title: 'Learning Spaces',
                          subtitle: '${subjects.length} subject(s) organized',
                          titleColor: colors.tertiaryText,
                          showShadow: true,
                        ),
                        const SizedBox(height: 14),
                        if (subjects.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.library_add_rounded,
                                  size: 36,
                                  color: Color(0xFF1565C0),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No subjects yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tap the + button to create your first subject.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          )
                        else
                          ...subjects.map((subject) {
                            final taskCount = tasks
                                .where((task) => task.subjectId == subject.id)
                                .length;
                            final examCount = exams
                                .where((exam) => exam.subjectId == subject.id)
                                .length;

                            return SubjectCard(
                              subject: subject,
                              taskCount: taskCount,
                              examCount: examCount,
                              onDelete: () => deleteSubject(subject),
                            );
                          }),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
