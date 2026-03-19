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
      done: task.done,
    );

    if (mounted) {
      context.read<TaskBloc>().add(UpdateTaskEvent(updatedData));
    }
  }

  /// Deletes a task after confirming with the user
  Future<void> deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete task via BLoC
    if (mounted) {
      context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
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
          return FloatingActionButton(
            onPressed: () => addTask(subjects), // Add a new task
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surface, const Color(0xFFE6F2FF)],
          ),
        ),
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

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                      child: SummaryHeaderCard(
                        icon: Icons.checklist_rounded,
                        iconColor: const Color(0xFF0D47A1),
                        iconBackgroundColor: const Color(0x1A1565C0),
                        title: 'Active Tasks',
                        subtitle: '${filteredTasks.length} pending item(s)',
                        titleColor: colors.tertiaryText,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                      child: SubjectFilterDropdown(
                        value: selectedSubjectId,
                        subjects: subjects,
                        onChanged: (value) => setState(() {
                          selectedSubjectId = value;
                        }),
                      ),
                    ),
                    Expanded(
                      child: filteredTasks.isEmpty
                          ? const Center(
                              child: Text(
                                'No active tasks found',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                0,
                                12,
                                120,
                              ),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];
                                return TaskCard(
                                  task: task,
                                  onDoneChanged: (value) {
                                    context.read<TaskBloc>().add(
                                      ToggleTaskDoneEvent(task.id),
                                    );
                                  },
                                  onEdit: () => editTask(subjects, task),
                                  onDelete: () => deleteTask(task),
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
