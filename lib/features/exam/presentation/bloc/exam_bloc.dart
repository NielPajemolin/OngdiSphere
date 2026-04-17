import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/repositories/exam_repository.dart';
import 'package:ongdisphere/core/services/local_notification_service.dart';
import 'package:ongdisphere/data/models/models.dart';
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
      for (final exam in exams) {
        if (exam.done) {
          await LocalNotificationService.instance.cancelExamReminder(exam.id);
          continue;
        }
        await LocalNotificationService.instance.scheduleExamReminder(
          examId: exam.id,
          title: exam.title,
          deadline: exam.dateTime,
          reminderMinutes:
              exam.reminderMinutes ??
              LocalNotificationService.defaultReminderMinutes,
        );
      }
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
        event.reminderMinutes,
        event.userId,
      );

      await LocalNotificationService.instance.scheduleExamReminder(
        examId: createdExam.id,
        title: createdExam.title,
        deadline: createdExam.dateTime,
        reminderMinutes:
            createdExam.reminderMinutes ??
            LocalNotificationService.defaultReminderMinutes,
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

      if (event.exam.done) {
        await LocalNotificationService.instance.cancelExamReminder(event.exam.id);
      } else {
        await LocalNotificationService.instance.scheduleExamReminder(
          examId: event.exam.id,
          title: event.exam.title,
          deadline: event.exam.dateTime,
          reminderMinutes:
              event.exam.reminderMinutes ??
              LocalNotificationService.defaultReminderMinutes,
        );
      }

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

      if (nextDoneValue) {
        await LocalNotificationService.instance.cancelExamReminder(event.examId);
      } else {
        await LocalNotificationService.instance.scheduleExamReminder(
          examId: targetExam.id,
          title: targetExam.title,
          deadline: targetExam.dateTime,
          reminderMinutes:
              targetExam.reminderMinutes ??
              LocalNotificationService.defaultReminderMinutes,
        );
      }

      final updatedExams = currentState.exams.map((exam) {
        if (exam.id == event.examId) {
          return Exam(
            id: exam.id,
            title: exam.title,
            subjectId: exam.subjectId,
            subjectName: exam.subjectName,
            dateTime: exam.dateTime,
            reminderMinutes: exam.reminderMinutes,
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
      await LocalNotificationService.instance.cancelExamReminder(event.examId);

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
