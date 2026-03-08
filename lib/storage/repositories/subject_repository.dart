import 'package:isar/isar.dart';
import '../isar_database_service.dart';
import '../isar_models/isar_subject.dart';
import '../subject.dart';
import 'task_repository.dart';
import 'exam_repository.dart';

class SubjectRepository {
  final isar = IsarDatabaseService.getInstance();

  /// Get all subjects
  Future<List<Subject>> getAllSubjects() async {
    final isarSubjects = await isar.isarSubjects.where().findAll();
    return isarSubjects.map((s) => _isarToSubject(s)).toList();
  }

  /// Get a subject by ID
  Future<Subject?> getSubjectById(String uuid) async {
    final isarSubject = await isar.isarSubjects
        .where()
        .uuidEqualTo(uuid)
        .findFirst();
    return isarSubject != null ? _isarToSubject(isarSubject) : null;
  }

  /// Create a new subject
  Future<Subject> createSubject(String subjectId, String name) async {
    final isarSubject = IsarSubject()
      ..uuid = subjectId
      ..name = name;

    await isar.writeTxn(() async {
      await isar.isarSubjects.put(isarSubject);
    });

    return Subject(id: subjectId, name: name);
  }

  /// Update a subject
  Future<void> updateSubject(String subjectId, String name) async {
    final isarSubject = await isar.isarSubjects
        .where()
        .uuidEqualTo(subjectId)
        .findFirst();

    if (isarSubject != null) {
      isarSubject.name = name;
      await isar.writeTxn(() async {
        await isar.isarSubjects.put(isarSubject);
      });
    }
  }

  /// Delete a subject and all its associated tasks and exams
  Future<void> deleteSubject(String subjectId) async {
    final isarSubject = await isar.isarSubjects
        .where()
        .uuidEqualTo(subjectId)
        .findFirst();

    if (isarSubject != null) {
      // Delete all associated tasks and exams
      final taskRepository = TaskRepository();
      final examRepository = ExamRepository();
      
      await taskRepository.deleteTasksBySubjectId(subjectId);
      await examRepository.deleteExamsBySubjectId(subjectId);
      
      // Finally, delete the subject
      await isar.writeTxn(() async {
        await isar.isarSubjects.delete(isarSubject.id);
      });
    }
  }

  /// Convert IsarSubject to Subject
  Subject _isarToSubject(IsarSubject isarSubject) {
    return Subject(
      id: isarSubject.uuid,
      name: isarSubject.name,
      tasks: const [], // Tasks are loaded separately
    );
  }
}
