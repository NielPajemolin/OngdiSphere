import 'package:equatable/equatable.dart';
import 'package:ongdisphere/data/models/models.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final String userId;
  
  const LoadTasksEvent(this.userId);
  
  @override
  List<Object?> get props => [userId];
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
  final int reminderMinutes;
  final String userId;

  const CreateTaskEvent(
    this.title,
    this.subjectId,
    this.subjectName,
    this.dateTime,
    this.reminderMinutes,
    this.userId,
  );

  @override
  List<Object?> get props => [
    title,
    subjectId,
    subjectName,
    dateTime,
    reminderMinutes,
    userId,
  ];
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
