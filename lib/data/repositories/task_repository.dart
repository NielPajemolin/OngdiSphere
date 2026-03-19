import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _tasksForUser(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  /// Get all tasks for a specific user
  Future<List<Task>> getAllTasks(String userId) async {
    final snapshot = await _tasksForUser(userId).get();
    return snapshot.docs.map(_docToTask).toList();
  }

  /// Get tasks by subject ID
  Future<List<Task>> getTasksBySubjectId(String subjectId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    final snapshot = await _tasksForUser(
      userId,
    ).where('subjectId', isEqualTo: subjectId).get();
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
    await _tasksForUser(userId).doc(taskId).set({
      'id': taskId,
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
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    await _tasksForUser(userId).doc(task.id).update({
      'title': task.title,
      'subjectId': task.subjectId,
      'subjectName': task.subjectName,
      'dateTime': Timestamp.fromDate(task.dateTime),
      'done': task.done,
    });
  }

  /// Set task done status directly to avoid an extra read before update.
  Future<void> setTaskDone(String taskId, bool done, {bool? wasLate}) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    final update = <String, dynamic>{'done': done};
    if (done) {
      update['wasLate'] = wasLate ?? false;
    } else {
      update['wasLate'] = FieldValue.delete();
    }
    await _tasksForUser(userId).doc(taskId).update(update);
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    await _tasksForUser(userId).doc(taskId).delete();
  }

  /// Delete all tasks by subject ID
  Future<void> deleteTasksBySubjectId(String subjectId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    final snapshot = await _tasksForUser(
      userId,
    ).where('subjectId', isEqualTo: subjectId).get();
    final batch = _firestore.batch();

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
      wasLate: data['wasLate'] as bool?,
    );
  }
}
