import 'package:equatable/equatable.dart';
import '../../../../storage/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  const LoadTasksEvent();
}

class LoadTasksBySubjectEvent extends TaskEvent {
  final String subjectId;

  const LoadTasksBySubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

class CreateTaskEvent extends TaskEvent {
  final String title;
  final String subjectId;
  final String subjectName;
  final DateTime dateTime;

  const CreateTaskEvent(
    this.title,
    this.subjectId,
    this.subjectName,
    this.dateTime,
  );

  @override
  List<Object?> get props => [title, subjectId, subjectName, dateTime];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class ToggleTaskDoneEvent extends TaskEvent {
  final String taskId;

  const ToggleTaskDoneEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
