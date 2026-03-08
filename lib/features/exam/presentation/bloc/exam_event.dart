import 'package:equatable/equatable.dart';
import '../../../../storage/exam.dart';

abstract class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object?> get props => [];
}

class LoadExamsEvent extends ExamEvent {
  final String userId;
  
  const LoadExamsEvent(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class LoadExamsBySubjectEvent extends ExamEvent {
  final String subjectId;

  const LoadExamsBySubjectEvent(this.subjectId);

  @override
  List<Object?> get props => [subjectId];
}

class CreateExamEvent extends ExamEvent {
  final String title;
  final String subjectId;
  final String subjectName;
  final DateTime dateTime;
  final String userId;

  const CreateExamEvent(
    this.title,
    this.subjectId,
    this.subjectName,
    this.dateTime,
    this.userId,
  );

  @override
  List<Object?> get props => [title, subjectId, subjectName, dateTime, userId];
}

class UpdateExamEvent extends ExamEvent {
  final Exam exam;

  const UpdateExamEvent(this.exam);

  @override
  List<Object?> get props => [exam];
}

class ToggleExamDoneEvent extends ExamEvent {
  final String examId;

  const ToggleExamDoneEvent(this.examId);

  @override
  List<Object?> get props => [examId];
}

class DeleteExamEvent extends ExamEvent {
  final String examId;

  const DeleteExamEvent(this.examId);

  @override
  List<Object?> get props => [examId];
}
