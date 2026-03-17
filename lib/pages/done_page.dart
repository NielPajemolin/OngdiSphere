import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../colorpalette/color_palette.dart';
import '../storage/task.dart';
import '../storage/exam.dart';
import '../components/task_card.dart';
import '../components/exam_card.dart';
import '../components/summary_header_card.dart';
import '../features/task/presentation/bloc/task_bloc.dart';
import '../features/task/presentation/bloc/task_event.dart';
import '../features/task/presentation/bloc/task_state.dart';
import '../features/exam/presentation/bloc/exam_bloc.dart';
import '../features/exam/presentation/bloc/exam_event.dart';
import '../features/exam/presentation/bloc/exam_state.dart';
import '../features/auth/presentation/cubits/auth/auth_cubit.dart';

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
  void deleteTask(Task task) {
    final colors = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Delete Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog and deletes an exam using BLoC
  void deleteExam(Exam exam) {
    final colors = Theme.of(context).extension<AppColors>()!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Delete Exam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text('Are you sure you want to delete "${exam.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ExamBloc>().add(DeleteExamEvent(exam.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
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
                    SummaryHeaderCard(
                      icon: Icons.verified_rounded,
                      iconColor: const Color(0xFF1B5E20),
                      iconBackgroundColor: const Color(0x1A1B5E20),
                      title: 'Completed Archive',
                      subtitle: '$totalDone total completed item(s)',
                      titleColor: colors.tertiaryText,
                      showShadow: true,
                    ),
                    const SizedBox(height: 14),
                    _DoneSection(
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
                                return TaskCard(
                                  task: task,
                                  onDelete: () => deleteTask(task),
                                  onDoneChanged: null,
                                  onEdit: null,
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 14),
                    _DoneSection(
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
                                return ExamCard(
                                  exam: exam,
                                  onDelete: () => deleteExam(exam),
                                  onDoneChanged: null,
                                  onEdit: null,
                                );
                              },
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
              Column(
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
        ],
      ),
    );
  }
}
