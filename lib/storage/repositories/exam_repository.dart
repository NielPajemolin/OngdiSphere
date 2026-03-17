import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../exam.dart';

class ExamRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _examsForUser(String userId) {
    return _firestore.collection('users').doc(userId).collection('exams');
  }

  /// Get all exams for a specific user
  Future<List<Exam>> getAllExams(String userId) async {
    final snapshot = await _examsForUser(userId).get();
    return snapshot.docs.map(_docToExam).toList();
  }

  /// Get exams by subject ID
  Future<List<Exam>> getExamsBySubjectId(String subjectId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    final snapshot = await _examsForUser(
      userId,
    ).where('subjectId', isEqualTo: subjectId).get();
    return snapshot.docs.map(_docToExam).toList();
  }

  /// Create a new exam
  Future<Exam> createExam(
    String examId,
    String title,
    String subjectId,
    String subjectName,
    DateTime dateTime,
    String userId,
  ) async {
    await _examsForUser(userId).doc(examId).set({
      'id': examId,
      'title': title,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'dateTime': Timestamp.fromDate(dateTime),
      'done': false,
    });

    return Exam(
      id: examId,
      title: title,
      subjectId: subjectId,
      subjectName: subjectName,
      dateTime: dateTime,
      done: false,
    );
  }

  /// Update an exam
  Future<void> updateExam(Exam exam) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    await _examsForUser(userId).doc(exam.id).update({
      'title': exam.title,
      'subjectId': exam.subjectId,
      'subjectName': exam.subjectName,
      'dateTime': Timestamp.fromDate(exam.dateTime),
      'done': exam.done,
    });
  }

  /// Set exam done status directly to avoid an extra read before update.
  Future<void> setExamDone(String examId, bool done, {bool? wasLate}) async {
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
    await _examsForUser(userId).doc(examId).update(update);
  }

  /// Delete an exam
  Future<void> deleteExam(String examId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    await _examsForUser(userId).doc(examId).delete();
  }

  /// Delete all exams by subject ID
  Future<void> deleteExamsBySubjectId(String subjectId) async {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    final snapshot = await _examsForUser(
      userId,
    ).where('subjectId', isEqualTo: subjectId).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Exam _docToExam(DocumentSnapshot<Map<String, dynamic>> doc) {
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

    return Exam(
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
