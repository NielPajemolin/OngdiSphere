// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ongdisphere/components/add_exam_dialog.dart';
import '../colorpalette/color_palette.dart';
import '../storage/storage_service.dart';
import '../storage/task.dart';
import '../storage/subject.dart';
import '../components/task_card.dart';


class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final StorageService storage = StorageService(); // Handles reading/writing tasks and subjects
  List<Subject> subjects = []; // List of all subjects
  List<Task> tasks = []; // Flattened list of all tasks
  String? selectedSubjectId; // Currently selected subject filter (null = show all)

  @override
  void initState() {
    super.initState();
    loadData(); // Load tasks and subjects when page initializes
  }

  /// Loads subjects from storage and flattens all their tasks into [tasks]
  Future<void> loadData() async {
    subjects = await storage.readSubjects();
    tasks = subjects.expand((s) => s.tasks).toList(); // Flatten tasks for easy filtering
    if (!mounted) return;
    setState(() {});
  }

  /// Opens the AddTaskDialog to create a new task
  Future<void> addTask() async {
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

    // Find the subject in the list and add the task
    final int subjIndex = subjects.indexWhere((s) => s.id == selectedSubject.id);
    if (subjIndex == -1) return;

    subjects[subjIndex].tasks.add(newTask);

    try {
      await storage.saveSubjects(subjects); // Persist changes
      await loadData(); // Refresh task list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully')),
      );
    } catch (e) {
      subjects[subjIndex].tasks.removeLast(); // Rollback if failed
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save task: $e')),
      );
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

    // Find the subject containing the task
    final subjIndex = subjects.indexWhere((s) => s.tasks.contains(task));
    if (subjIndex == -1) return;

    subjects[subjIndex].tasks.remove(task); // Remove the task

    try {
      await storage.saveSubjects(subjects); // Persist changes
      await loadData(); // Refresh task list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    // Apply filter: show all tasks or only those for the selected subject
    final filteredTasks = selectedSubjectId == null
        ? tasks.where((t) => !t.done).toList() // Exclude done tasks
        : tasks.where((t) => t.subjectId == selectedSubjectId && !t.done).toList();

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
      floatingActionButton: FloatingActionButton(
        onPressed: addTask, // Add a new task
        child: const Icon(Icons.add),
      ),
      body: Column(
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
                        onDoneChanged: (value) async {
                          setState(() => task.done = value ?? false);
                          await storage.saveSubjects(subjects); // Persist done state
                        },
                        // Delete task
                        onDelete: () => deleteTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
