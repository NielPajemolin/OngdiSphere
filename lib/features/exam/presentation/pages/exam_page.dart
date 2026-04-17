import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/models/models.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';
import 'package:ongdisphere/features/subject/subject.dart';
import 'package:ongdisphere/features/exam/presentation/bloc/exam_bloc.dart';
import 'package:ongdisphere/features/exam/presentation/bloc/exam_event.dart';
import 'package:ongdisphere/features/exam/presentation/bloc/exam_state.dart';
import 'package:ongdisphere/features/auth/auth.dart';

/// Page displaying all exams, with filtering, adding, deleting, and marking done.
class ExamPage extends StatefulWidget {
  const ExamPage({super.key});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  String? selectedSubjectId; // Currently selected subject filter

  @override
  void initState() {
    super.initState();
    // Load exams and subjects when the page initializes
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<SubjectBloc>().add(LoadSubjectsEvent(userId));
      context.read<ExamBloc>().add(LoadExamsEvent(userId));
    }
  }

  /// Opens a dialog to add a new exam and saves it
  Future<void> addExam(List<Subject> subjects) async {
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No subjects available')));
      return;
    }

    // Show the AddExam dialog
    final result = await showAddExamDialog(
      context: context,
      subjects: subjects,
    );
    if (!mounted || result == null || result['error'] != null) return;

    final Exam newExam = result['exam'];

    // Add exam via BLoC
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (mounted && userId.isNotEmpty) {
      context.read<ExamBloc>().add(
        CreateExamEvent(
          newExam.title,
          newExam.subjectId,
          newExam.subjectName,
          newExam.dateTime,
          newExam.reminderMinutes ?? 10,
          userId,
        ),
      );
    }
  }

  /// Opens the edit dialog for an exam
  Future<void> editExam(List<Subject> subjects, Exam exam) async {
    if (subjects.isEmpty) return;

    final result = await showAddExamDialog(
      context: context,
      subjects: subjects,
      exam: exam,
    );

    if (!mounted || result == null || result['error'] != null) return;

    final Exam updatedExam = result['exam'];

    // Update exam via BLoC
    final updatedData = Exam(
      id: exam.id,
      title: updatedExam.title,
      subjectId: updatedExam.subjectId,
      subjectName: updatedExam.subjectName,
      dateTime: updatedExam.dateTime,
      reminderMinutes: updatedExam.reminderMinutes,
      done: exam.done,
    );

    if (mounted) {
      context.read<ExamBloc>().add(UpdateExamEvent(updatedData));
    }
  }

  /// Deletes an exam after user confirmation
  Future<void> deleteExam(Exam exam) async {
    final confirm = await showDeleteConfirmationDialog(
      context: context,
      title: 'Delete Exam',
      message: 'Remove "${exam.title}" permanently?',
    );

    if (!mounted || !confirm) return;

    // Delete exam via BLoC
    context.read<ExamBloc>().add(DeleteExamEvent(exam.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 1024
        ? 26.0
        : screenWidth >= 768
        ? 22.0
        : 18.0;
    final listHorizontalPadding = screenWidth >= 768 ? 16.0 : 12.0;
    final maxContentWidth = screenWidth >= 1280 ? 1040.0 : 920.0;
    final useMaxWidth = screenWidth >= 900;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Exams',
          style: TextStyle(
            color: colors.tertiaryText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, state) {
          List<Subject> subjects = [];
          if (state is SubjectLoaded) {
            subjects = state.subjects;
          }
          return PressAnimatedFab(
            onPressed: () => addExam(subjects),
            tooltip: 'Add exam',
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
      body: KuromiPageBackground(
        topColor: colors.surface,
        bottomColor: const Color(0xFFF5E9F8),
        preset: KuromiBackgroundPreset.twilight,
        child: BlocBuilder<SubjectBloc, SubjectState>(
          builder: (context, subjectState) {
            List<Subject> subjects = [];
            if (subjectState is SubjectLoaded) {
              subjects = subjectState.subjects;
            }

            return BlocBuilder<ExamBloc, ExamState>(
              builder: (context, examState) {
                List<Exam> exams = [];
                if (examState is ExamLoaded) {
                  exams = examState.exams;
                }

                if (examState is ExamLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (examState is ExamError) {
                  return Center(child: Text(examState.message));
                }

                final filteredExams = selectedSubjectId == null
                    ? exams.where((exam) => !exam.done).toList()
                    : exams
                          .where(
                            (exam) =>
                                exam.subjectId == selectedSubjectId &&
                                !exam.done,
                          )
                          .toList();

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: useMaxWidth ? maxContentWidth : double.infinity,
                    ),
                    child: Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - value) * 10),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              10,
                              horizontalPadding,
                              8,
                            ),
                            child: SummaryHeaderCard(
                              icon: Icons.description_rounded,
                              iconColor: const Color(0xFF6A1B9A),
                              iconBackgroundColor: const Color(0x1A8E24AA),
                              title: 'Upcoming Exams',
                              subtitle: '${filteredExams.length} pending exam(s)',
                              titleColor: colors.tertiaryText,
                            ),
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - value) * 12),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              10,
                            ),
                            child: SubjectFilterDropdown(
                              value: selectedSubjectId,
                              subjects: subjects,
                              onChanged: (value) => setState(() {
                                selectedSubjectId = value;
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filteredExams.isEmpty
                              ? Center(
                                  child: TweenAnimationBuilder<double>(
                                    key: ValueKey(
                                      'exam-empty-$selectedSubjectId-${filteredExams.length}',
                                    ),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, (1 - value) * 12),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.event_note_rounded,
                                          size: 38,
                                          color: Color(0x666A1B9A),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'No pending exams',
                                          style: TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    listHorizontalPadding,
                                    0,
                                    listHorizontalPadding,
                                    120,
                                  ),
                                  itemCount: filteredExams.length,
                                  itemBuilder: (context, index) {
                                    final exam = filteredExams[index];
                                    final staggerIndex = index > 10 ? 10 : index;

                                    return TweenAnimationBuilder<double>(
                                      key: ValueKey('exam-${exam.id}'),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: Duration(
                                        milliseconds: 220 + (staggerIndex * 40),
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(0, (1 - value) * 12),
                                          child: Opacity(
                                            opacity: value,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: ExamCard(
                                        exam: exam,
                                        onDoneChanged: (value) {
                                          context.read<ExamBloc>().add(
                                            ToggleExamDoneEvent(exam.id),
                                          );
                                        },
                                        onEdit: () => editExam(subjects, exam),
                                        onDelete: () => deleteExam(exam),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
