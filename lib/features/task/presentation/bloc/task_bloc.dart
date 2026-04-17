import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/repositories/task_repository.dart';
import 'package:ongdisphere/core/services/local_notification_service.dart';
import 'package:ongdisphere/data/models/models.dart';
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
      final alreadyLoaded = state is TaskLoaded && (state as TaskLoaded).userId == event.userId;
      if (!alreadyLoaded) {
        emit(const TaskLoading());
      }
    try {
      final tasks = await taskRepository.getAllTasks(event.userId);
      for (final task in tasks) {
        if (task.done) {
          await LocalNotificationService.instance.cancelTaskReminder(task.id);
          continue;
        }
        await LocalNotificationService.instance.scheduleTaskReminder(
          taskId: task.id,
          title: task.title,
          deadline: task.dateTime,
          reminderMinutes:
              task.reminderMinutes ??
              LocalNotificationService.defaultReminderMinutes,
        );
      }
        emit(TaskLoaded(tasks, event.userId));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> _onLoadTasksBySubject(
    LoadTasksBySubjectEvent event,
    Emitter<TaskState> emit,
  ) async {
      final currentUserId = state is TaskLoaded ? (state as TaskLoaded).userId : '';
      if (state is! TaskLoaded) {
        emit(const TaskLoading());
      }
    try {
      final tasks = await taskRepository.getTasksBySubjectId(event.subjectId);
        emit(TaskLoaded(tasks, currentUserId));
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
      final createdTask = await taskRepository.createTask(
        taskId,
        event.title,
        event.subjectId,
        event.subjectName,
        event.dateTime,
        event.reminderMinutes,
        event.userId,
      );

      await LocalNotificationService.instance.scheduleTaskReminder(
        taskId: createdTask.id,
        title: createdTask.title,
        deadline: createdTask.dateTime,
        reminderMinutes:
            createdTask.reminderMinutes ??
            LocalNotificationService.defaultReminderMinutes,
      );

      // Fast path: update in-memory state instantly instead of refetching all tasks.
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        emit(TaskLoaded([...currentState.tasks, createdTask], currentState.userId));
        return;
      }

      final tasks = await taskRepository.getAllTasks(event.userId);
      emit(TaskLoaded(tasks, event.userId));
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

      if (event.task.done) {
        await LocalNotificationService.instance.cancelTaskReminder(event.task.id);
      } else {
        await LocalNotificationService.instance.scheduleTaskReminder(
          taskId: event.task.id,
          title: event.task.title,
          deadline: event.task.dateTime,
          reminderMinutes:
              event.task.reminderMinutes ??
              LocalNotificationService.defaultReminderMinutes,
        );
      }

      // Update task in current state with new list instance
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final updatedTasks = currentState.tasks
            .map((t) => t.id == event.task.id ? event.task : t)
            .toList();
          emit(TaskLoaded(updatedTasks, currentState.userId));
      }
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> _onToggleTaskDone(
    ToggleTaskDoneEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) {
      return;
    }

    final currentState = state as TaskLoaded;
    final taskIndex = currentState.tasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex == -1) {
      return;
    }

    final targetTask = currentState.tasks[taskIndex];
    final nextDoneValue = !targetTask.done;
    final wasLate = nextDoneValue
        ? targetTask.dateTime.isBefore(DateTime.now())
        : null;

    try {
      await taskRepository.setTaskDone(event.taskId, nextDoneValue, wasLate: wasLate);

      if (nextDoneValue) {
        await LocalNotificationService.instance.cancelTaskReminder(event.taskId);
      } else {
        await LocalNotificationService.instance.scheduleTaskReminder(
          taskId: targetTask.id,
          title: targetTask.title,
          deadline: targetTask.dateTime,
          reminderMinutes:
              targetTask.reminderMinutes ??
              LocalNotificationService.defaultReminderMinutes,
        );
      }

      final updatedTasks = currentState.tasks.map((task) {
        if (task.id == event.taskId) {
          return Task(
            id: task.id,
            title: task.title,
            subjectId: task.subjectId,
            subjectName: task.subjectName,
            dateTime: task.dateTime,
            reminderMinutes: task.reminderMinutes,
            done: nextDoneValue,
            wasLate: nextDoneValue ? wasLate : null,
          );
        }
        return task;
      }).toList();
      emit(TaskLoaded(updatedTasks, currentState.userId));
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
      await LocalNotificationService.instance.cancelTaskReminder(event.taskId);

      // Remove task from current state
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        final tasks = currentState.tasks
            .where((t) => t.id != event.taskId)
            .toList();
            emit(TaskLoaded(tasks, currentState.userId));
      }
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }
}
