import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import '../colorpalette/color_palette.dart';
import '../components/dashboard_card.dart';
import '../components/menu_button.dart';
import '../storage/storage_service.dart';
import '../storage/subject.dart';
import '../storage/exam.dart';
import '../components/my_app_drawer.dart';

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
  final StorageService storage = StorageService(); // Service for reading/writing data
  List<Subject> subjects = []; // List of subjects
  List<Exam> exams = []; // List of exams

  @override
  void initState() {
    super.initState();
    loadData(); // Load subjects and exams from storage
  }

  /// Loads subjects and exams from storage and refreshes UI
  void loadData() async {
    subjects = await storage.readSubjects();
    exams = await storage.readExams();
    if (!mounted) return;
    setState(() {});
  }

  /// Counts all unfinished tasks across all subjects
  int get taskCount =>
      subjects.fold(0, (sum, s) => sum + s.tasks.where((t) => !t.done).length);

  /// Counts all unfinished exams
  int get examCount => exams.where((e) => !e.done).length;

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
                  Row(
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
                          onTap: () {
                            Navigator.pushNamed(context, '/subjects').then((_) {
                              if (mounted) loadData(); // Refresh dashboard after returning
                            });
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Button to navigate to tasks page
                        MenuButton(
                          icon: Icons.checklist,
                          label: "Task",
                          onTap: () {
                            Navigator.pushNamed(context, '/tasks').then((_) {
                              if (mounted) loadData(); // Refresh dashboard after returning
                            });
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Button to navigate to exams page
                        MenuButton(
                          icon: Icons.folder,
                          label: "Exam",
                          onTap: () {
                            Navigator.pushNamed(context, '/exams').then((_) {
                              if (mounted) loadData(); // Refresh dashboard after returning
                            });
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
