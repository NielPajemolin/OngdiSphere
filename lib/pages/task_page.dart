// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../colorpalette/color_palette.dart';
import '../storage/task.dart';
import '../storage/subject.dart';
import '../components/task_card.dart';
import '../components/add_exam_dialog.dart';
import '../features/subject/presentation/bloc/subject_bloc.dart';
import '../features/subject/presentation/bloc/subject_event.dart';
import '../features/subject/presentation/bloc/subject_state.dart';
import '../features/task/presentation/bloc/task_bloc.dart';
import '../features/task/presentation/bloc/task_event.dart';
import '../features/task/presentation/bloc/task_state.dart';
import '../features/auth/presentation/cubits/auth/auth_cubit.dart';


class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String? selectedSubjectId; // Currently selected subject filter (null = show all)

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects available')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => AddTaskDialog(subjects: subjects), // Pass subjects for selection
    );

    if (!mounted || result == null) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
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
      builder: (_) => AddTaskDialog(subjects: subjects, task: task), // Pass task for editing
    );

    if (!mounted || result == null) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          "Tasks",
          style: TextStyle(
            color: colors.primaryText,
            fontSize: screenWidth * 0.07, // Responsive font size
            fontWeight: FontWeight.bold,
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
            child: const Icon(Icons.add),
          );
        },
      ),
      body: BlocBuilder<SubjectBloc, SubjectState>(
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

              // Apply filter: show all tasks or only those for the selected subject
              final filteredTasks = selectedSubjectId == null
                  ? tasks.where((t) => !t.done).toList() // Exclude done tasks
                  : tasks.where((t) => t.subjectId == selectedSubjectId && !t.done).toList();

              return Column(
                children: [
                  // Dropdown to filter tasks by subject
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
                        const DropdownMenuItem(value: null, child: Text("All Subjects")),
                        ...subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                      ],
                      onChanged: (value) => setState(() => selectedSubjectId = value),
                    ),
                  ),

                  // Display task list
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? const Center(child: Text("No tasks"))
                        : ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return TaskCard(
                                task: task,
                                // Checkbox toggle for marking task done
                                onDoneChanged: (value) {
                                  context.read<TaskBloc>().add(ToggleTaskDoneEvent(task.id));
                                },
                                // Edit task
                                onEdit: () => editTask(subjects, task),
                                // Delete task
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
    );
  }
}

