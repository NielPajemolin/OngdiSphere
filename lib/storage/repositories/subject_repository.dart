import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../subject.dart';
import 'task_repository.dart';
import 'exam_repository.dart';

class SubjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _subjectsForUser(String userId) {
    return _firestore.collection('users').doc(userId).collection('subjects');
  }

  String _requireCurrentUserId() {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user found.');
    }
    return uid;
  }

  /// Get all subjects for a specific user
  Future<List<Subject>> getAllSubjects(String userId) async {
    final snapshot = await _subjectsForUser(userId).get();
    return snapshot.docs.map(_docToSubject).toList();
  }

  /// Get a subject by ID
  Future<Subject?> getSubjectById(String uuid) async {
    final userId = _requireCurrentUserId();
    final doc = await _subjectsForUser(userId).doc(uuid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return _docToSubject(doc);
  }

  /// Create a new subject
  Future<Subject> createSubject(
    String subjectId,
    String name,
    String userId,
  ) async {
    await _subjectsForUser(
      userId,
    ).doc(subjectId).set({'id': subjectId, 'name': name});

    return Subject(id: subjectId, name: name);
  }

  /// Update a subject
  Future<void> updateSubject(String subjectId, String name) async {
    final userId = _requireCurrentUserId();
    await _subjectsForUser(userId).doc(subjectId).update({'name': name});
  }

  /// Delete a subject and all its associated tasks and exams
  Future<void> deleteSubject(String subjectId) async {
    final userId = _requireCurrentUserId();

    // Delete all associated tasks and exams first.
    final taskRepository = TaskRepository();
    final examRepository = ExamRepository();

    await taskRepository.deleteTasksBySubjectId(subjectId);
    await examRepository.deleteExamsBySubjectId(subjectId);

    await _subjectsForUser(userId).doc(subjectId).delete();
  }

  Subject _docToSubject(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return Subject(
      id: (data['id'] as String?) ?? doc.id,
      name: (data['name'] as String?) ?? '',
      tasks: const [], // Tasks are loaded separately
    );
  }
}
