import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../colorpalette/color_palette.dart';
import '../storage/exam.dart';
import '../storage/subject.dart';
import '../components/exam_card.dart';
import '../components/add_task_dialog.dart';
import '../features/subject/presentation/bloc/subject_bloc.dart';
import '../features/subject/presentation/bloc/subject_event.dart';
import '../features/subject/presentation/bloc/subject_state.dart';
import '../features/exam/presentation/bloc/exam_bloc.dart';
import '../features/exam/presentation/bloc/exam_event.dart';
import '../features/exam/presentation/bloc/exam_state.dart';

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
    context.read<SubjectBloc>().add(const LoadSubjectsEvent());
    context.read<ExamBloc>().add(const LoadExamsEvent());
  }

  /// Opens a dialog to add a new exam and saves it
  Future<void> addExam(List<Subject> subjects) async {
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects available')),
      );
      return;
    }

    // Show the AddExam dialog
    final result = await showAddExamDialog(context: context, subjects: subjects);
    if (!mounted || result == null || result['error'] != null) return;

    final Exam newExam = result['exam'];

    // Add exam via BLoC
    if (mounted) {
      context.read<ExamBloc>().add(
        CreateExamEvent(
          newExam.title,
          newExam.subjectId,
          newExam.subjectName,
          newExam.dateTime,
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
      done: exam.done,
    );

    if (mounted) {
      context.read<ExamBloc>().add(UpdateExamEvent(updatedData));
    }
  }

  /// Deletes an exam after user confirmation
  Future<void> deleteExam(Exam exam) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete exam via BLoC
    if (mounted) {
      context.read<ExamBloc>().add(DeleteExamEvent(exam.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          "Exams",
          style: TextStyle(
            color: colors.primaryText,
            fontSize: screenWidth * 0.07, // Responsive font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<SubjectBloc, SubjectState>(
        builder: (context, state) {
          List<Subject> subjects = [];
          if (state is SubjectLoaded) {
            subjects = state.subjects;
          }
          return FloatingActionButton(
            onPressed: () => addExam(subjects),
            child: const Icon(Icons.add),
          );
        },
      ),
      body: BlocBuilder<SubjectBloc, SubjectState>(
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

              // Apply filter: show all exams or only those matching the selected subject and not done
              final filteredExams = selectedSubjectId == null
                  ? exams.where((e) => !e.done).toList()
                  : exams.where((e) => e.subjectId == selectedSubjectId && !e.done).toList();

              return Column(
                children: [
                  // Subject filter dropdown
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: DropdownButtonFormField<String>(
                      value: selectedSubjectId,
                      hint: const Text("Filter by Subject"),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text("All Subjects")), // Option to show all exams
                        ...subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                      ],
                      onChanged: (value) => setState(() => selectedSubjectId = value), // Apply filter
                    ),
                  ),

                  // Exams list
                  Expanded(
                    child: filteredExams.isEmpty
                        ? const Center(child: Text("No exams yet")) // Show message if no exams
                        : ListView.builder(
                            itemCount: filteredExams.length,
                            itemBuilder: (context, index) {
                              final exam = filteredExams[index];
                              return ExamCard(
                                exam: exam,
                                onDoneChanged: (value) {
                                  context.read<ExamBloc>().add(ToggleExamDoneEvent(exam.id));
                                },
                                // Edit exam
                                onEdit: () => editExam(subjects, exam),
                                onDelete: () => deleteExam(exam), // Delete exam
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
