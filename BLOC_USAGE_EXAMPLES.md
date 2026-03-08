# BLoC Events Usage Examples

This guide shows how to dispatch events in your UI to perform CRUD operations.

## Subject Events

```dart
// Load all subjects
context.read<SubjectBloc>().add(const LoadSubjectsEvent());

// Create a new subject
context.read<SubjectBloc>().add(CreateSubjectEvent('Physics'));

// Update a subject
context.read<SubjectBloc>().add(UpdateSubjectEvent(subjectId, 'Advanced Physics'));

// Delete a subject
context.read<SubjectBloc>().add(DeleteSubjectEvent(subjectId));
```

## Task Events

```dart
// Load all tasks
context.read<TaskBloc>().add(const LoadTasksEvent());

// Load tasks for a specific subject
context.read<TaskBloc>().add(LoadTasksBySubjectEvent(subjectId));

// Create a task
context.read<TaskBloc>().add(CreateTaskEvent(
  'Complete homework',           // title
  subjectId,                     // subjectId
  'Physics',                     // subjectName
  DateTime.now().add(Duration(days: 1)), // dateTime
));

// Toggle task done status
context.read<TaskBloc>().add(ToggleTaskDoneEvent(taskId));

// Delete a task
context.read<TaskBloc>().add(DeleteTaskEvent(taskId));
```

## Exam Events

```dart
// Load all exams
context.read<ExamBloc>().add(const LoadExamsEvent());

// Load exams for a specific subject
context.read<ExamBloc>().add(LoadExamsBySubjectEvent(subjectId));

// Create an exam
context.read<ExamBloc>().add(CreateExamEvent(
  'Physics Midterm',             // title
  subjectId,                     // subjectId
  'Physics',                     // subjectName
  DateTime.now().add(Duration(days: 7)), // dateTime
));

// Toggle exam done status
context.read<ExamBloc>().add(ToggleExamDoneEvent(examId));

// Delete an exam
context.read<ExamBloc>().add(DeleteExamEvent(examId));
```

## Listening to State Changes

### SubjectBloc
```dart
BlocListener<SubjectBloc, SubjectState>(
  listener: (context, state) {
    if (state is SubjectError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message))
      );
    }
  },
  child: BlocBuilder<SubjectBloc, SubjectState>(
    builder: (context, state) {
      if (state is SubjectLoading) {
        return const CircularProgressIndicator();
      }
      if (state is SubjectLoaded) {
        return ListView.builder(
          itemCount: state.subjects.length,
          itemBuilder: (context, index) {
            return Text(state.subjects[index].name);
          },
        );
      }
      return const Text('No subjects');
    },
  ),
)
```

### TaskBloc
```dart
BlocBuilder<TaskBloc, TaskState>(
  builder: (context, state) {
    if (state is TaskLoaded) {
      final tasks = state.tasks.where((t) => !t.done).toList();
      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].title),
            onTap: () => context.read<TaskBloc>().add(
              ToggleTaskDoneEvent(tasks[index].id)
            ),
          );
        },
      );
    }
    return const SizedBox();
  },
)
```

## Direct Data Access (if needed)

If you need to directly query the database without BLoC:

```dart
final subjectRepository = SubjectRepository();
final allSubjects = await subjectRepository.getAllSubjects();
final specificSubject = await subjectRepository.getSubjectById(uuid);
```

However, **it's recommended to use BLoC** for state management to keep your app reactive and testable.

## Error Handling

All BLoCs emit an error state if something fails:

```dart
BlocConsumer<SubjectBloc, SubjectState>(
  listener: (context, state) {
    if (state is SubjectError) {
      // Show error toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.message}'))
      );
    }
  },
  builder: (context, state) {
    // Rebuild UI based on state
    return Container();
  },
)
```

## Tips

1. **Always load data in initState()** or when the page first builds
2. **Use BlocListener** for side effects (snackbars, navigation)
3. **Use BlocBuilder** for rebuilding the UI
4. **Combine both** with BlocConsumer if you need both
5. **Test BLoCs** independently using block_test package for easier testing
