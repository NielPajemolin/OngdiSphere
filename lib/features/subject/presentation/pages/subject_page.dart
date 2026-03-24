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
    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Subject',
      message: 'Remove "${subject.name}" permanently?',
    );

    if (!mounted || !confirm) return;

    // Delete subject via BLoC
    context.read<SubjectBloc>().add(DeleteSubjectEvent(subject.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 1024
        ? 26.0
        : screenWidth >= 768
        ? 22.0
        : 18.0;
    final maxContentWidth = screenWidth >= 1280 ? 1040.0 : 920.0;
    final useMaxWidth = screenWidth >= 900;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Subjects',
          style: TextStyle(
            color: colors.tertiaryText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: PressAnimatedFab(
        onPressed: addSubject, // Open dialog to add new subject
        tooltip: 'Add subject',
        child: const Icon(Icons.add_rounded),
      ),
      body: KuromiPageBackground(
        topColor: colors.surface,
        bottomColor: const Color(0xFFF8EAF4),
        preset: KuromiBackgroundPreset.blush,
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

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: useMaxWidth ? maxContentWidth : double.infinity,
                        ),
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            10,
                            horizontalPadding,
                            120,
                          ),
                          children: [
                            SummaryHeaderCard(
                              icon: Icons.menu_book_rounded,
                              iconColor: const Color(0xFF131015),
                              iconBackgroundColor: const Color(0x1AF48FB1),
                              title: 'Learning Spaces',
                              subtitle: '${subjects.length} subject(s) organized',
                              titleColor: colors.tertiaryText,
                              showShadow: true,
                            ),
                            const SizedBox(height: 14),
                            if (subjects.isEmpty)
                              TweenAnimationBuilder<double>(
                                key: ValueKey('subject-empty-${subjects.length}'),
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, (1 - value) * 12),
                                    child: Opacity(opacity: value, child: child),
                                  );
                                },
                                child: KuromiDecoratedContainer(
                                  borderRadius: BorderRadius.circular(18),
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  patternColor: colors.secondary,
                                  patternOpacity: 0.08,
                                  child: const Column(
                                    children: [
                                      Icon(
                                        Icons.library_add_rounded,
                                        size: 36,
                                        color: Color(0xFFF48FB1),
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
                                ),
                              )
                            else
                              ...subjects.asMap().entries.map((entry) {
                                final index = entry.key;
                                final subject = entry.value;
                                final taskCount = tasks
                                    .where((task) => task.subjectId == subject.id)
                                    .length;
                                final examCount = exams
                                    .where((exam) => exam.subjectId == subject.id)
                                    .length;
                                final staggerIndex = index > 8 ? 8 : index;

                                return TweenAnimationBuilder<double>(
                                  key: ValueKey('subject-${subject.id}'),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(
                                    milliseconds: 240 + (staggerIndex * 45),
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, (1 - value) * 14),
                                      child: Opacity(opacity: value, child: child),
                                    );
                                  },
                                  child: SubjectCard(
                                    subject: subject,
                                    taskCount: taskCount,
                                    examCount: examCount,
                                    onDelete: () => deleteSubject(subject),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
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
