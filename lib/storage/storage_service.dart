import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'subject.dart';
import 'task.dart';
import 'exam.dart';

class StorageService {
  // ---------------- Subjects ----------------
  Future<List<Subject>> readSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('subjects');
    if (data == null) return [];
    return List<Subject>.from(json.decode(data).map((x) => Subject.fromJson(x)));
  }

  Future<void> saveSubjects(List<Subject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subjects', json.encode(subjects.map((x) => x.toJson()).toList()));
  }

  Future<void> deleteSubject(String subjectId) async {
    final subjects = await readSubjects();
    subjects.removeWhere((s) => s.id == subjectId);
    await saveSubjects(subjects);

    // Also remove exams linked to this subject
    final exams = await readExams();
    exams.removeWhere((e) => e.subjectId == subjectId);
    await saveExams(exams);
  }

  // ---------------- Exams ----------------
  Future<List<Exam>> readExams() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('exams');
    if (data == null) return [];
    return List<Exam>.from(json.decode(data).map((x) => Exam.fromJson(x)));
  }

  Future<void> saveExams(List<Exam> exams) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('exams', json.encode(exams.map((x) => x.toJson()).toList()));
  }

  // ---------------- Tasks ----------------
  Future<List<Task>> readTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data == null) return [];
    return List<Task>.from(json.decode(data).map((x) => Task.fromJson(x)));
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(tasks.map((x) => x.toJson()).toList()));
  }
}
