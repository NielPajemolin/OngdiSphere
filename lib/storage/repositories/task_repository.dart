import 'package:isar/isar.dart';
import '../isar_database_service.dart';
import '../isar_models/isar_task.dart';
import '../task.dart';

class TaskRepository {
  final isar = IsarDatabaseService.getInstance();

  /// Get all tasks
  Future<List<Task>> getAllTasks() async {
    final isarTasks = await isar.isarTasks.where().findAll();
    return isarTasks.map((t) => _isarToTask(t)).toList();
  }

  /// Get tasks by subject ID
  Future<List<Task>> getTasksBySubjectId(String subjectId) async {
    final isarTasks = await isar.isarTasks
        .where()
        .subjectIdEqualTo(subjectId)
        .findAll();
    return isarTasks.map((t) => _isarToTask(t)).toList();
  }

  /// Create a new task
  Future<Task> createTask(
    String taskId,
    String title,
    String subjectId,
    String subjectName,
    DateTime dateTime,
  ) async {
    final isarTask = IsarTask()
      ..uuid = taskId
      ..title = title
      ..subjectId = subjectId
      ..subjectName = subjectName
      ..dateTime = dateTime
      ..done = false;

    await isar.writeTxn(() async {
      await isar.isarTasks.put(isarTask);
    });

    return Task(
      id: taskId,
      title: title,
      subjectId: subjectId,
      subjectName: subjectName,
      dateTime: dateTime,
      done: false,
    );
  }

  /// Update a task
  Future<void> updateTask(Task task) async {
    final isarTask = await isar.isarTasks
        .where()
        .uuidEqualTo(task.id)
        .findFirst();

    if (isarTask != null) {
      isarTask.title = task.title;
      isarTask.subjectId = task.subjectId;
      isarTask.subjectName = task.subjectName;
      isarTask.dateTime = task.dateTime;
      isarTask.done = task.done;

      await isar.writeTxn(() async {
        await isar.isarTasks.put(isarTask);
      });
    }
  }

  /// Toggle task done status
  Future<void> toggleTaskDone(String taskId) async {
    final isarTask = await isar.isarTasks
        .where()
        .uuidEqualTo(taskId)
        .findFirst();

    if (isarTask != null) {
      isarTask.done = !isarTask.done;
      await isar.writeTxn(() async {
        await isar.isarTasks.put(isarTask);
      });
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final isarTask = await isar.isarTasks
        .where()
        .uuidEqualTo(taskId)
        .findFirst();

    if (isarTask != null) {
      await isar.writeTxn(() async {
        await isar.isarTasks.delete(isarTask.id);
      });
    }
  }

  /// Delete all tasks by subject ID
  Future<void> deleteTasksBySubjectId(String subjectId) async {
    final isarTasks = await isar.isarTasks
        .where()
        .subjectIdEqualTo(subjectId)
        .findAll();

    await isar.writeTxn(() async {
      await isar.isarTasks.deleteAll(isarTasks.map((t) => t.id).toList());
    });
  }

  /// Convert IsarTask to Task
  Task _isarToTask(IsarTask isarTask) {
    return Task(
      id: isarTask.uuid,
      title: isarTask.title,
      subjectId: isarTask.subjectId,
      subjectName: isarTask.subjectName,
      dateTime: isarTask.dateTime,
      done: isarTask.done,
    );
  }
}
