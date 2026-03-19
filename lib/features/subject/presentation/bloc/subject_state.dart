import 'package:equatable/equatable.dart';
import 'package:ongdisphere/data/models/models.dart';

abstract class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {
  const SubjectInitial();
}

class SubjectLoading extends SubjectState {
  const SubjectLoading();
}

class SubjectLoaded extends SubjectState {
  final List<Subject> subjects;
  final String userId;

  const SubjectLoaded(this.subjects, this.userId);

  @override
  List<Object?> get props => [subjects, userId];
}

class SubjectError extends SubjectState {
  final String message;

  const SubjectError(this.message);

  @override
  List<Object?> get props => [message];
}
