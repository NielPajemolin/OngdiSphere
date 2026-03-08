import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import '../colorpalette/color_palette.dart';
import '../components/dashboard_card.dart';
import '../components/menu_button.dart';
import '../components/my_app_drawer.dart';
import '../features/subject/presentation/bloc/subject_bloc.dart';
import '../features/subject/presentation/bloc/subject_event.dart';
import '../features/task/presentation/bloc/task_bloc.dart';
import '../features/task/presentation/bloc/task_event.dart';
import '../features/task/presentation/bloc/task_state.dart';
import '../features/exam/presentation/bloc/exam_bloc.dart';
import '../features/exam/presentation/bloc/exam_event.dart';
import '../features/exam/presentation/bloc/exam_state.dart';

/// The main home page of the app showing the dashboard and menu
/// Displays the number of unfinished tasks and exams,
/// and provides navigation to Subjects, Tasks, and Exams pages.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  /// Logs out the currently authenticated Firebase user
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load all data from BLoCs on init
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<SubjectBloc>().add(LoadSubjectsEvent(userId));
      context.read<TaskBloc>().add(LoadTasksEvent(userId));
      context.read<ExamBloc>().add(LoadExamsEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final authCubit = context.read<AuthCubit>();
    final userName = authCubit.currenUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        elevation: 0,
        title: Text("Hello, $userName!",
          style: TextStyle(
            color: colors.primaryText,
            fontSize: screenWidth * 0.07, // Responsive font size
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: colors.primaryText),
            onPressed: () => Scaffold.of(context).openDrawer(), // Open the drawer
          ),
        ),
      ),
      drawer: const AppDrawer(), // Custom navigation drawer
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dashboard section: shows count of tasks and exams
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(thickness: 0.5, color: colors.primary),
                  SizedBox(height: screenHeight * 0.02),
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, taskState) {
                      return BlocBuilder<ExamBloc, ExamState>(
                        builder: (context, examState) {
                          int taskCount = 0;
                          int examCount = 0;

                          if (taskState is TaskLoaded) {
                            taskCount = taskState.tasks.where((t) => !t.done).length;
                          }

                          if (examState is ExamLoaded) {
                            examCount = examState.exams.where((e) => !e.done).length;
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DashboardCard(
                                title: "Task",
                                count: taskCount, // Shows unfinished tasks
                                icon: Icons.calendar_today,
                              ),
                              DashboardCard(
                                title: "Exam",
                                count: examCount, // Shows unfinished exams
                                icon: Icons.description,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Menu section: navigation buttons to other pages
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(thickness: 0.5, color: colors.primary),
                  SizedBox(height: screenHeight * 0.02),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Column(
                      children: [
                        // Button to navigate to subjects page
                        MenuButton(
                          icon: Icons.list,
                          label: "Subjects",
                          onTap: () async {
                            final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
                            final taskBloc = context.read<TaskBloc>();
                            final examBloc = context.read<ExamBloc>();
                            
                            await Navigator.pushNamed(context, '/subjects');
                            
                            // Reload data when returning from subjects page
                            if (mounted && userId.isNotEmpty) {
                              taskBloc.add(LoadTasksEvent(userId));
                              examBloc.add(LoadExamsEvent(userId));
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Button to navigate to tasks page
                        MenuButton(
                          icon: Icons.checklist,
                          label: "Task",
                          onTap: () async {
                            final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
                            final taskBloc = context.read<TaskBloc>();
                            
                            await Navigator.pushNamed(context, '/tasks');
                            
                            // Reload data when returning
                            if (mounted && userId.isNotEmpty) {
                              taskBloc.add(LoadTasksEvent(userId));
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Button to navigate to exams page
                        MenuButton(
                          icon: Icons.folder,
                          label: "Exam",
                          onTap: () async {
                            final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
                            final examBloc = context.read<ExamBloc>();
                            
                            await Navigator.pushNamed(context, '/exams');
                            
                            // Reload data when returning
                            if (mounted && userId.isNotEmpty) {
                              examBloc.add(LoadExamsEvent(userId));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
