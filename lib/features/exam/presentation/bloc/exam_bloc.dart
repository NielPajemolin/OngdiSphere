import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../storage/repositories/exam_repository.dart';
import 'exam_event.dart';
import 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository examRepository;

  ExamBloc({required this.examRepository}) : super(const ExamInitial()) {
    on<LoadExamsEvent>(_onLoadExams);
    on<LoadExamsBySubjectEvent>(_onLoadExamsBySubject);
    on<CreateExamEvent>(_onCreateExam);
    on<UpdateExamEvent>(_onUpdateExam);
    on<ToggleExamDoneEvent>(_onToggleExamDone);
    on<DeleteExamEvent>(_onDeleteExam);
  }

  Future<void> _onLoadExams(
    LoadExamsEvent event,
    Emitter<ExamState> emit,
  ) async {
    emit(const ExamLoading());
    try {
      final exams = await examRepository.getAllExams();
      emit(ExamLoaded(exams));
    } catch (e) {
      emit(ExamError('Failed to load exams: $e'));
    }
  }

  Future<void> _onLoadExamsBySubject(
    LoadExamsBySubjectEvent event,
    Emitter<ExamState> emit,
  ) async {
    emit(const ExamLoading());
    try {
      final exams = await examRepository.getExamsBySubjectId(event.subjectId);
      emit(ExamLoaded(exams));
    } catch (e) {
      emit(ExamError('Failed to load exams: $e'));
    }
  }

  Future<void> _onCreateExam(
    CreateExamEvent event,
    Emitter<ExamState> emit,
  ) async {
    try {
      final examId = const Uuid().v4();
      await examRepository.createExam(
        examId,
        event.title,
        event.subjectId,
        event.subjectName,
        event.dateTime,
      );

      // Reload exams after creation
      final exams = await examRepository.getAllExams();
      emit(ExamLoaded(exams));
    } catch (e) {
      emit(ExamError('Failed to create exam: $e'));
    }
  }

  Future<void> _onUpdateExam(
    UpdateExamEvent event,
    Emitter<ExamState> emit,
  ) async {
    try {
      await examRepository.updateExam(event.exam);

      // Reload exams after update
      final exams = await examRepository.getAllExams();
      emit(ExamLoaded(exams));
    } catch (e) {
      emit(ExamError('Failed to update exam: $e'));
    }
  }

  Future<void> _onToggleExamDone(
    ToggleExamDoneEvent event,
    Emitter<ExamState> emit,
  ) async {
    try {
      await examRepository.toggleExamDone(event.examId);

      // Reload exams after toggle
      final exams = await examRepository.getAllExams();
      emit(ExamLoaded(exams));
    } catch (e) {
      emit(ExamError('Failed to toggle exam: $e'));
    }
  }

  Future<void> _onDeleteExam(
    DeleteExamEvent event,
    Emitter<ExamState> emit,
  ) async {
    try {
      await examRepository.deleteExam(event.examId);

      // Reload exams after deletion
      final exams = await examRepository.getAllExams();
      emit(ExamLoaded(exams));
    } catch (e) {
      emit(ExamError('Failed to delete exam: $e'));
    }
  }
}
