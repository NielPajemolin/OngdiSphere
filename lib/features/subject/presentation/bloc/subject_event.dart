import 'package:equatable/equatable.dart';

abstract class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubjectsEvent extends SubjectEvent {
  final String userId;
  
  const LoadSubjectsEvent(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class CreateSubjectEvent extends SubjectEvent {
  final String name;
  final String userId;

  const CreateSubjectEvent(this.name, this.userId);

  @override
  List<Object?> get props => [name, userId];
}

class UpdateSubjectEvent extends SubjectEvent {
  final String id;
  final String name;

  const UpdateSubjectEvent(this.id, this.name);

  @override
  List<Object?> get props => [id, name];
}

class DeleteSubjectEvent extends SubjectEvent {
  final String id;

  const DeleteSubjectEvent(this.id);

  @override
  List<Object?> get props => [id];
}
