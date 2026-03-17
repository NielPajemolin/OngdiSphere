import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../storage/repositories/task_repository.dart';
import '../../../../storage/task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(const TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<LoadTasksBySubjectEvent>(_onLoadTasksBySubject);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<ToggleTaskDoneEvent>(_onToggleTaskDone);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) {
      emit(const TaskLoading());
    }
    try {
      final tasks = await taskRepository.getAllTasks(event.userId);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onLoadTasksBySubject(
    LoadTasksBySubjectEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) {
      emit(const TaskLoading());
    }
    try {
      final tasks = await taskRepository.getTasksBySubjectId(event.subjectId);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final taskId = const Uuid().v4();
      await taskRepository.createTask(
        taskId,
        event.title,
        event.subjectId,
        event.subjectName,
        event.dateTime,
        event.userId,
      );

      // Reload tasks after creation
      final tasks = await taskRepository.getAllTasks(event.userId);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to create task: $e'));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepository.updateTask(event.task);

      // Update task in current state with new list instance
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final updatedTasks = currentState.tasks
            .map((t) => t.id == event.task.id ? event.task : t)
            .toList();
        emit(TaskLoaded(updatedTasks));
      }
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> _onToggleTaskDone(
    ToggleTaskDoneEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepository.toggleTaskDone(event.taskId);

      // Update task in current state
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final updatedTasks = currentState.tasks.map((t) {
          if (t.id == event.taskId) {
            return Task(
              id: t.id,
              title: t.title,
              subjectId: t.subjectId,
              subjectName: t.subjectName,
              dateTime: t.dateTime,
              done: !t.done,
            );
          }
          return t;
        }).toList();
        emit(TaskLoaded(updatedTasks));
      }
    } catch (e) {
      emit(TaskError('Failed to toggle task: $e'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await taskRepository.deleteTask(event.taskId);

      // Remove task from current state
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final tasks = currentState.tasks
            .where((t) => t.id != event.taskId)
            .toList();
        emit(TaskLoaded(tasks));
      }
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }
}
