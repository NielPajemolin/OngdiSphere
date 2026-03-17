import 'package:cloud_firestore/cloud_firestore.dart';
import '../exam.dart';

class ExamRepository {
  final CollectionReference<Map<String, dynamic>> _exams = FirebaseFirestore
      .instance
      .collection('exams');

  /// Get all exams for a specific user
  Future<List<Exam>> getAllExams(String userId) async {
    final snapshot = await _exams.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map(_docToExam).toList();
  }

  /// Get exams by subject ID
  Future<List<Exam>> getExamsBySubjectId(String subjectId) async {
    final snapshot = await _exams
        .where('subjectId', isEqualTo: subjectId)
        .get();
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
    await _exams.doc(examId).set({
      'id': examId,
      'userId': userId,
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
    await _exams.doc(exam.id).update({
      'title': exam.title,
      'subjectId': exam.subjectId,
      'subjectName': exam.subjectName,
      'dateTime': Timestamp.fromDate(exam.dateTime),
      'done': exam.done,
    });
  }

  /// Toggle exam done status
  Future<void> toggleExamDone(String examId) async {
    final examRef = _exams.doc(examId);
    final snapshot = await examRef.get();
    final data = snapshot.data();

    if (data == null) {
      return;
    }

    final currentDone = (data['done'] as bool?) ?? false;
    await examRef.update({'done': !currentDone});
  }

  /// Delete an exam
  Future<void> deleteExam(String examId) async {
    await _exams.doc(examId).delete();
  }

  /// Delete all exams by subject ID
  Future<void> deleteExamsBySubjectId(String subjectId) async {
    final snapshot = await _exams
        .where('subjectId', isEqualTo: subjectId)
        .get();
    final batch = FirebaseFirestore.instance.batch();

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
    );
  }
}
