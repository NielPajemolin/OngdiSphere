import 'package:isar/isar.dart';
import '../isar_database_service.dart';
import '../isar_models/isar_exam.dart';
import '../exam.dart';

class ExamRepository {
  final isar = IsarDatabaseService.getInstance();

  /// Get all exams for a specific user
  Future<List<Exam>> getAllExams(String userId) async {
    final isarExams = await isar.isarExams
        .where()
        .userIdEqualTo(userId)
        .findAll();
    return isarExams.map((e) => _isarToExam(e)).toList();
  }

  /// Get exams by subject ID
  Future<List<Exam>> getExamsBySubjectId(String subjectId) async {
    final isarExams = await isar.isarExams
        .where()
        .subjectIdEqualTo(subjectId)
        .findAll();
    return isarExams.map((e) => _isarToExam(e)).toList();
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
    final isarExam = IsarExam()
      ..uuid = examId
      ..userId = userId
      ..title = title
      ..subjectId = subjectId
      ..subjectName = subjectName
      ..dateTime = dateTime
      ..done = false;

    await isar.writeTxn(() async {
      await isar.isarExams.put(isarExam);
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
    final isarExam = await isar.isarExams
        .where()
        .uuidEqualTo(exam.id)
        .findFirst();

    if (isarExam != null) {
      isarExam.title = exam.title;
      isarExam.subjectId = exam.subjectId;
      isarExam.subjectName = exam.subjectName;
      isarExam.dateTime = exam.dateTime;
      isarExam.done = exam.done;

      await isar.writeTxn(() async {
        await isar.isarExams.put(isarExam);
      });
    }
  }

  /// Toggle exam done status
  Future<void> toggleExamDone(String examId) async {
    final isarExam = await isar.isarExams
        .where()
        .uuidEqualTo(examId)
        .findFirst();

    if (isarExam != null) {
      isarExam.done = !isarExam.done;
      await isar.writeTxn(() async {
        await isar.isarExams.put(isarExam);
      });
    }
  }

  /// Delete an exam
  Future<void> deleteExam(String examId) async {
    final isarExam = await isar.isarExams
        .where()
        .uuidEqualTo(examId)
        .findFirst();

    if (isarExam != null) {
      await isar.writeTxn(() async {
        await isar.isarExams.delete(isarExam.id);
      });
    }
  }

  /// Delete all exams by subject ID
  Future<void> deleteExamsBySubjectId(String subjectId) async {
    final isarExams = await isar.isarExams
        .where()
        .subjectIdEqualTo(subjectId)
        .findAll();

    await isar.writeTxn(() async {
      await isar.isarExams.deleteAll(isarExams.map((e) => e.id).toList());
    });
  }

  /// Convert IsarExam to Exam
  Exam _isarToExam(IsarExam isarExam) {
    return Exam(
      id: isarExam.uuid,
      title: isarExam.title,
      subjectId: isarExam.subjectId,
      subjectName: isarExam.subjectName,
      dateTime: isarExam.dateTime,
      done: isarExam.done,
    );
  }
}
