import 'package:cloud_firestore/cloud_firestore.dart';
import '../subject.dart';
import 'task_repository.dart';
import 'exam_repository.dart';

class SubjectRepository {
  final CollectionReference<Map<String, dynamic>> _subjects = FirebaseFirestore
      .instance
      .collection('subjects');

  /// Get all subjects for a specific user
  Future<List<Subject>> getAllSubjects(String userId) async {
    final snapshot = await _subjects.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map(_docToSubject).toList();
  }

  /// Get a subject by ID
  Future<Subject?> getSubjectById(String uuid) async {
    final doc = await _subjects.doc(uuid).get();
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
    await _subjects.doc(subjectId).set({
      'id': subjectId,
      'name': name,
      'userId': userId,
    });

    return Subject(id: subjectId, name: name);
  }

  /// Update a subject
  Future<void> updateSubject(String subjectId, String name) async {
    await _subjects.doc(subjectId).update({'name': name});
  }

  /// Delete a subject and all its associated tasks and exams
  Future<void> deleteSubject(String subjectId) async {
    // Delete all associated tasks and exams first.
    final taskRepository = TaskRepository();
    final examRepository = ExamRepository();

    await taskRepository.deleteTasksBySubjectId(subjectId);
    await examRepository.deleteExamsBySubjectId(subjectId);

    await _subjects.doc(subjectId).delete();
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
