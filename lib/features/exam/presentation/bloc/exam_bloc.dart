import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../storage/repositories/exam_repository.dart';
import '../../../../storage/exam.dart';
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
      final alreadyLoaded = state is ExamLoaded && (state as ExamLoaded).userId == event.userId;
      if (!alreadyLoaded) {
        emit(const ExamLoading());
      }
    try {
      final exams = await examRepository.getAllExams(event.userId);
        emit(ExamLoaded(exams, event.userId));
    } catch (e) {
      emit(ExamError('Failed to load exams: $e'));
    }
  }

  Future<void> _onLoadExamsBySubject(
    LoadExamsBySubjectEvent event,
    Emitter<ExamState> emit,
  ) async {
      final currentUserId = state is ExamLoaded ? (state as ExamLoaded).userId : '';
      if (state is! ExamLoaded) {
        emit(const ExamLoading());
      }
    try {
      final exams = await examRepository.getExamsBySubjectId(event.subjectId);
        emit(ExamLoaded(exams, currentUserId));
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
      final createdExam = await examRepository.createExam(
        examId,
        event.title,
        event.subjectId,
        event.subjectName,
        event.dateTime,
        event.userId,
      );

      // Fast path: update in-memory state instantly instead of refetching all exams.
      if (state is ExamLoaded) {
        final currentState = state as ExamLoaded;
        emit(ExamLoaded([...currentState.exams, createdExam], currentState.userId));
        return;
      }

      final exams = await examRepository.getAllExams(event.userId);
      emit(ExamLoaded(exams, event.userId));
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

      // Update exam in current state with new list instance
      if (state is ExamLoaded) {
        final currentState = state as ExamLoaded;
        final updatedExams = currentState.exams
            .map((e) => e.id == event.exam.id ? event.exam : e)
            .toList();
            emit(ExamLoaded(updatedExams, currentState.userId));
      }
    } catch (e) {
      emit(ExamError('Failed to update exam: $e'));
    }
  }

  Future<void> _onToggleExamDone(
    ToggleExamDoneEvent event,
    Emitter<ExamState> emit,
  ) async {
    if (state is! ExamLoaded) {
      return;
    }

    final currentState = state as ExamLoaded;
    final examIndex = currentState.exams.indexWhere((e) => e.id == event.examId);
    if (examIndex == -1) {
      return;
    }

    final targetExam = currentState.exams[examIndex];
    final nextDoneValue = !targetExam.done;
    final wasLate = nextDoneValue
        ? targetExam.dateTime.isBefore(DateTime.now())
        : null;

    try {
      await examRepository.setExamDone(event.examId, nextDoneValue, wasLate: wasLate);

      final updatedExams = currentState.exams.map((exam) {
        if (exam.id == event.examId) {
          return Exam(
            id: exam.id,
            title: exam.title,
            subjectId: exam.subjectId,
            subjectName: exam.subjectName,
            dateTime: exam.dateTime,
            done: nextDoneValue,
            wasLate: nextDoneValue ? wasLate : null,
          );
        }
        return exam;
      }).toList();
      emit(ExamLoaded(updatedExams, currentState.userId));
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

      // Remove exam from current state
      if (state is ExamLoaded) {
        final currentState = state as ExamLoaded;
        final exams = currentState.exams
            .where((e) => e.id != event.examId)
            .toList();
            emit(ExamLoaded(exams, currentState.userId));
      }
    } catch (e) {
      emit(ExamError('Failed to delete exam: $e'));
    }
  }
}
