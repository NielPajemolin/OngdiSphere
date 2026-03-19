import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';
import 'package:ongdisphere/features/task/task.dart';
import 'package:ongdisphere/features/exam/exam.dart';
import 'package:ongdisphere/features/auth/auth.dart';

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
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<TaskBloc>().add(LoadTasksEvent(userId));
      context.read<ExamBloc>().add(LoadExamsEvent(userId));
    }
  }

  /// Shows a confirmation dialog and deletes a task using BLoC
  Future<void> deleteTask(Task task) async {
    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Task',
      message: 'Remove "${task.title}" permanently?',
    );

    if (!mounted || !confirm) return;
    context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
  }

  /// Shows a confirmation dialog and deletes an exam using BLoC
  Future<void> deleteExam(Exam exam) async {
    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Exam',
      message: 'Remove "${exam.title}" permanently?',
    );

    if (!mounted || !confirm) return;
    context.read<ExamBloc>().add(DeleteExamEvent(exam.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Done',
          style: TextStyle(
            color: colors.tertiaryText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surface, const Color(0xFFEAF3FF)],
          ),
        ),
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            return BlocBuilder<ExamBloc, ExamState>(
              builder: (context, examState) {
                if (taskState is TaskLoading || examState is ExamLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskState is TaskError) {
                  return Center(child: Text(taskState.message));
                }

                if (examState is ExamError) {
                  return Center(child: Text(examState.message));
                }

                List<Task> doneTasks = [];
                List<Exam> doneExams = [];

                if (taskState is TaskLoaded) {
                  doneTasks = taskState.tasks
                      .where((task) => task.done)
                      .toList();
                }

                if (examState is ExamLoaded) {
                  doneExams = examState.exams
                      .where((exam) => exam.done)
                      .toList();
                }

                final totalDone = doneTasks.length + doneExams.length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * 10),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: SummaryHeaderCard(
                        icon: Icons.verified_rounded,
                        iconColor: const Color(0xFF1B5E20),
                        iconBackgroundColor: const Color(0x1A1B5E20),
                        title: 'Completed Archive',
                        subtitle: '$totalDone total completed item(s)',
                        titleColor: colors.tertiaryText,
                        showShadow: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * 12),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _DoneSection(
                        title: 'Completed Tasks',
                        count: doneTasks.length,
                        icon: Icons.task_alt_rounded,
                        emptyMessage: 'No completed tasks yet',
                        child: doneTasks.isEmpty
                            ? null
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: doneTasks.length,
                                itemBuilder: (context, index) {
                                  final task = doneTasks[index];
                                  final staggerIndex = index > 8 ? 8 : index;
                                  return TweenAnimationBuilder<double>(
                                    key: ValueKey('done-task-${task.id}'),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                      milliseconds: 220 + (staggerIndex * 40),
                                    ),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, (1 - value) * 10),
                                        child: Opacity(opacity: value, child: child),
                                      );
                                    },
                                    child: TaskCard(
                                      task: task,
                                      onDelete: () => deleteTask(task),
                                      onDoneChanged: null,
                                      onEdit: null,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * 12),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _DoneSection(
                        title: 'Completed Exams',
                        count: doneExams.length,
                        icon: Icons.school_rounded,
                        emptyMessage: 'No completed exams yet',
                        child: doneExams.isEmpty
                            ? null
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: doneExams.length,
                                itemBuilder: (context, index) {
                                  final exam = doneExams[index];
                                  final staggerIndex = index > 8 ? 8 : index;
                                  return TweenAnimationBuilder<double>(
                                    key: ValueKey('done-exam-${exam.id}'),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                      milliseconds: 220 + (staggerIndex * 40),
                                    ),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, (1 - value) * 10),
                                        child: Opacity(opacity: value, child: child),
                                      );
                                    },
                                    child: ExamCard(
                                      exam: exam,
                                      onDelete: () => deleteExam(exam),
                                      onDoneChanged: null,
                                      onEdit: null,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DoneSection extends StatelessWidget {
  const _DoneSection({
    required this.title,
    required this.count,
    required this.icon,
    required this.emptyMessage,
    required this.child,
  });

  final String title;
  final int count;
  final IconData icon;
  final String emptyMessage;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1F1565C0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0x1A1565C0),
                child: Icon(icon, size: 18, color: const Color(0xFF0D47A1)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child ??
              TweenAnimationBuilder<double>(
                key: ValueKey('done-empty-$title'),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (context, value, animatedChild) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * 10),
                    child: Opacity(opacity: value, child: animatedChild),
                  );
                },
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Icon(
                      Icons.inbox_rounded,
                      size: 36,
                      color: Colors.black26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      emptyMessage,
                      style: const TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
