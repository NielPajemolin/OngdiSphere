import 'package:equatable/equatable.dart';
import '../../../../storage/exam.dart';

abstract class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamState {
  const ExamInitial();
}

class ExamLoading extends ExamState {
  const ExamLoading();
}

class ExamLoaded extends ExamState {
  final List<Exam> exams;
  final String userId;

  const ExamLoaded(this.exams, this.userId);

  @override
  List<Object?> get props => [exams, userId];
}

class ExamError extends ExamState {
  final String message;

  const ExamError(this.message);

  @override
  List<Object?> get props => [message];
}
