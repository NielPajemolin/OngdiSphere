import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../storage/repositories/subject_repository.dart';
import '../../../../storage/repositories/exam_repository.dart';
import '../../../../storage/subject.dart';
import 'subject_event.dart';
import 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository subjectRepository;
  final ExamRepository examRepository;

  SubjectBloc({required this.subjectRepository, required this.examRepository})
    : super(const SubjectInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
  }

  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<SubjectState> emit,
  ) async {
      final alreadyLoaded = state is SubjectLoaded && (state as SubjectLoaded).userId == event.userId;
      if (!alreadyLoaded) {
        emit(const SubjectLoading());
      }
    try {
      final subjects = await subjectRepository.getAllSubjects(event.userId);
        emit(SubjectLoaded(subjects, event.userId));
    } catch (e) {
      emit(SubjectError('Failed to load subjects: $e'));
    }
  }

  Future<void> _onCreateSubject(
    CreateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    try {
      final subjectId = const Uuid().v4();
      final createdSubject = await subjectRepository.createSubject(
        subjectId,
        event.name,
        event.userId,
      );

      if (state is SubjectLoaded) {
        final currentState = state as SubjectLoaded;
        emit(
          SubjectLoaded(
            [...currentState.subjects, createdSubject],
            currentState.userId,
          ),
        );
        return;
      }

      final subjects = await subjectRepository.getAllSubjects(event.userId);
      emit(SubjectLoaded(subjects, event.userId));
    } catch (e) {
      emit(SubjectError('Failed to create subject: $e'));
    }
  }

  Future<void> _onUpdateSubject(
    UpdateSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    try {
      await subjectRepository.updateSubject(event.id, event.name);

      if (state is SubjectLoaded) {
        final currentState = state as SubjectLoaded;
        final updatedSubjects = currentState.subjects.map((subject) {
          if (subject.id != event.id) {
            return subject;
          }
          return Subject(id: subject.id, name: event.name, tasks: subject.tasks);
        }).toList();
        emit(SubjectLoaded(updatedSubjects, currentState.userId));
      }
    } catch (e) {
      emit(SubjectError('Failed to update subject: $e'));
    }
  }

  Future<void> _onDeleteSubject(
    DeleteSubjectEvent event,
    Emitter<SubjectState> emit,
  ) async {
    try {
      await subjectRepository.deleteSubject(event.id);

      if (state is SubjectLoaded) {
        final currentState = state as SubjectLoaded;
        final subjects = currentState.subjects
            .where((s) => s.id != event.id)
            .toList();
        emit(SubjectLoaded(subjects, currentState.userId));
      }
    } catch (e) {
      emit(SubjectError('Failed to delete subject: $e'));
    }
  }
}
