import 'package:cloud_firestore/cloud_firestore.dart';
import '../task.dart';

class TaskRepository {
  final CollectionReference<Map<String, dynamic>> _tasks = FirebaseFirestore
      .instance
      .collection('tasks');

  /// Get all tasks for a specific user
  Future<List<Task>> getAllTasks(String userId) async {
    final snapshot = await _tasks.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map(_docToTask).toList();
  }

  /// Get tasks by subject ID
  Future<List<Task>> getTasksBySubjectId(String subjectId) async {
    final snapshot = await _tasks
        .where('subjectId', isEqualTo: subjectId)
        .get();
    return snapshot.docs.map(_docToTask).toList();
  }

  /// Create a new task
  Future<Task> createTask(
    String taskId,
    String title,
    String subjectId,
    String subjectName,
    DateTime dateTime,
    String userId,
  ) async {
    await _tasks.doc(taskId).set({
      'id': taskId,
      'userId': userId,
      'title': title,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'dateTime': Timestamp.fromDate(dateTime),
      'done': false,
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
    await _tasks.doc(task.id).update({
      'title': task.title,
      'subjectId': task.subjectId,
      'subjectName': task.subjectName,
      'dateTime': Timestamp.fromDate(task.dateTime),
      'done': task.done,
    });
  }

  /// Toggle task done status
  Future<void> toggleTaskDone(String taskId) async {
    final taskRef = _tasks.doc(taskId);
    final snapshot = await taskRef.get();
    final data = snapshot.data();

    if (data == null) {
      return;
    }

    final currentDone = (data['done'] as bool?) ?? false;
    await taskRef.update({'done': !currentDone});
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }

  /// Delete all tasks by subject ID
  Future<void> deleteTasksBySubjectId(String subjectId) async {
    final snapshot = await _tasks
        .where('subjectId', isEqualTo: subjectId)
        .get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Task _docToTask(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final dynamic dateField = data['dateTime'];

    final DateTime parsedDate;
    if (dateField is Timestamp) {
      parsedDate = dateField.toDate();
    } else if (dateField is String) {
      parsedDate = DateTime.tryParse(dateField) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Task(
      id: (data['id'] as String?) ?? doc.id,
      title: (data['title'] as String?) ?? '',
      subjectId: (data['subjectId'] as String?) ?? '',
      subjectName: (data['subjectName'] as String?) ?? '',
      dateTime: parsedDate,
      done: (data['done'] as bool?) ?? false,
    );
  }
}
