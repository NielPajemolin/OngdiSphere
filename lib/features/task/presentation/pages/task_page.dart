import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';
import 'package:ongdisphere/features/subject/subject.dart';
import 'package:ongdisphere/features/task/presentation/bloc/task_bloc.dart';
import 'package:ongdisphere/features/task/presentation/bloc/task_event.dart';
import 'package:ongdisphere/features/task/presentation/bloc/task_state.dart';
import 'package:ongdisphere/features/auth/auth.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String?
  selectedSubjectId; // Currently selected subject filter (null = show all)

  @override
  void initState() {
    super.initState();
    // Load tasks and subjects when page initializes
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<SubjectBloc>().add(LoadSubjectsEvent(userId));
      context.read<TaskBloc>().add(LoadTasksEvent(userId));
    }
  }

  /// Opens the AddTaskDialog to create a new task
  Future<void> addTask(List<Subject> subjects) async {
    if (subjects.isEmpty) {
      // If there are no subjects, show a message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No subjects available')));
      return;
    }

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) =>
          AddTaskDialog(subjects: subjects), // Pass subjects for selection
    );

    if (!mounted || result == null) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Extract task and selected subject from the dialog result
    final Task newTask = result['task'];
    final Subject selectedSubject = result['subject'];

    // Add task via BLoC
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (mounted && userId.isNotEmpty) {
      context.read<TaskBloc>().add(
        CreateTaskEvent(
          newTask.title,
          selectedSubject.id,
          selectedSubject.name,
          newTask.dateTime,
          newTask.reminderMinutes ?? 10,
          userId,
        ),
      );
    }
  }

  /// Opens the edit dialog for a task
  Future<void> editTask(List<Subject> subjects, Task task) async {
    if (subjects.isEmpty) return;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => AddTaskDialog(
        subjects: subjects,
        task: task,
      ), // Pass task for editing
    );

    if (!mounted || result == null) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Extract updated task info
    final Task updatedTask = result['task'];
    final Subject selectedSubject = result['subject'];

    // Update task via BLoC
    final updatedData = Task(
      id: task.id,
      title: updatedTask.title,
      subjectId: selectedSubject.id,
      subjectName: selectedSubject.name,
      dateTime: updatedTask.dateTime,
      reminderMinutes: updatedTask.reminderMinutes,
      done: task.done,
    );

    if (mounted) {
      context.read<TaskBloc>().add(UpdateTaskEvent(updatedData));
    }
  }

  /// Deletes a task after confirming with the user
  Future<void> deleteTask(Task task) async {
    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Task',
      message: 'Remove "${task.title}" permanently?',
    );

    if (!mounted || !confirm) return;

    // Delete task via BLoC
    context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
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
    final listHorizontalPadding = screenWidth >= 768 ? 16.0 : 12.0;
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
          'Tasks',
          style: TextStyle(
            color: colors.tertiaryText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, state) {
          List<Subject> subjects = [];
          if (state is SubjectLoaded) {
            subjects = state.subjects;
          }
          return PressAnimatedFab(
            onPressed: () => addTask(subjects),
            tooltip: 'Add task',
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
      body: KuromiPageBackground(
        topColor: colors.surface,
        bottomColor: const Color(0xFFF8EAF5),
        preset: KuromiBackgroundPreset.candy,
        child: BlocBuilder<SubjectBloc, SubjectState>(
          builder: (context, subjectState) {
            List<Subject> subjects = [];
            if (subjectState is SubjectLoaded) {
              subjects = subjectState.subjects;
            }

            return BlocBuilder<TaskBloc, TaskState>(
              builder: (context, taskState) {
                List<Task> tasks = [];
                if (taskState is TaskLoaded) {
                  tasks = taskState.tasks;
                }

                if (taskState is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (taskState is TaskError) {
                  return Center(child: Text(taskState.message));
                }

                final filteredTasks = selectedSubjectId == null
                    ? tasks.where((task) => !task.done).toList()
                    : tasks
                          .where(
                            (task) =>
                                task.subjectId == selectedSubjectId &&
                                !task.done,
                          )
                          .toList();

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: useMaxWidth ? maxContentWidth : double.infinity,
                    ),
                    child: Column(
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
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              10,
                              horizontalPadding,
                              8,
                            ),
                            child: SummaryHeaderCard(
                              icon: Icons.checklist_rounded,
                              iconColor: const Color(0xFF131015),
                              iconBackgroundColor: const Color(0x1AF48FB1),
                              title: 'Active Tasks',
                              subtitle: '${filteredTasks.length} pending item(s)',
                              titleColor: colors.tertiaryText,
                            ),
                          ),
                        ),
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
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              10,
                            ),
                            child: SubjectFilterDropdown(
                              value: selectedSubjectId,
                              subjects: subjects,
                              onChanged: (value) => setState(() {
                                selectedSubjectId = value;
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredTasks.isEmpty
                              ? Center(
                                  child: EmptyStateWidget(
                                    key: ValueKey(
                                      'task-empty-$selectedSubjectId-${filteredTasks.length}',
                                    ),
                                    icon: Icons.task_alt_rounded,
                                    message: 'No active tasks found',
                                    color: const Color(0x66F48FB1),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    listHorizontalPadding,
                                    0,
                                    listHorizontalPadding,
                                    120,
                                  ),
                                  itemCount: filteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = filteredTasks[index];
                                    final staggerIndex = index > 10 ? 10 : index;

                                    return TweenAnimationBuilder<double>(
                                      key: ValueKey('task-${task.id}'),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: Duration(
                                        milliseconds: 220 + (staggerIndex * 40),
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(0, (1 - value) * 12),
                                          child: Opacity(
                                            opacity: value,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: TaskCard(
                                        task: task,
                                        onDoneChanged: (value) {
                                          context.read<TaskBloc>().add(
                                            ToggleTaskDoneEvent(task.id),
                                          );
                                        },
                                        onEdit: () => editTask(subjects, task),
                                        onDelete: () => deleteTask(task),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
