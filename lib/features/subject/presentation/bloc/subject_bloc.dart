import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../storage/repositories/subject_repository.dart';
import '../../../../storage/repositories/exam_repository.dart';
import 'subject_event.dart';
import 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository subjectRepository;
  final ExamRepository examRepository;

  SubjectBloc({
    required this.subjectRepository,
    required this.examRepository,
  }) : super(const SubjectInitial()) {
    on<LoadSubjectsEvent>(_onLoadSubjects);
    on<CreateSubjectEvent>(_onCreateSubject);
    on<UpdateSubjectEvent>(_onUpdateSubject);
    on<DeleteSubjectEvent>(_onDeleteSubject);
  }

  Future<void> _onLoadSubjects(
    LoadSubjectsEvent event,
    Emitter<SubjectState> emit,
  ) async {
    emit(const SubjectLoading());
    try {
      final subjects = await subjectRepository.getAllSubjects();
      emit(SubjectLoaded(subjects));
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
      await subjectRepository.createSubject(subjectId, event.name);
      
      // Reload subjects after creation
      final subjects = await subjectRepository.getAllSubjects();
      emit(SubjectLoaded(subjects));
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
      
      // Reload subjects after update
      final subjects = await subjectRepository.getAllSubjects();
      emit(SubjectLoaded(subjects));
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
      
      // Also remove exams associated with the subject
      // This would be handled by cascading deletes or manually
      
      // Reload subjects after deletion
      final subjects = await subjectRepository.getAllSubjects();
      emit(SubjectLoaded(subjects));
    } catch (e) {
      emit(SubjectError('Failed to delete subject: $e'));
    }
  }
}
