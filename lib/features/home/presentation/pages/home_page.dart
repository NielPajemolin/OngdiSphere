import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/auth.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';
import 'package:ongdisphere/features/subject/subject.dart';
import 'package:ongdisphere/features/task/task.dart';
import 'package:ongdisphere/features/exam/exam.dart';

/// The main home page of the app showing the dashboard and menu
/// Displays the number of unfinished tasks and exams,
/// and provides navigation to Subjects, Tasks, and Exams pages.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..forward();

    // Load all data from BLoCs on init
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    if (userId.isNotEmpty) {
      context.read<SubjectBloc>().add(LoadSubjectsEvent(userId));
      context.read<TaskBloc>().add(LoadTasksEvent(userId));
      context.read<ExamBloc>().add(LoadExamsEvent(userId));
    }
  }

  Widget _buildAnimatedSection({
    required Widget child,
    required double begin,
    required double end,
  }) {
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.09),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _navigateAndReload({
    required String route,
    required bool refreshTasks,
    required bool refreshExams,
  }) async {
    final userId = context.read<AuthCubit>().currenUser?.uid ?? '';
    final taskBloc = context.read<TaskBloc>();
    final examBloc = context.read<ExamBloc>();

    await Navigator.pushNamed(context, route);

    if (!mounted || userId.isEmpty) {
      return;
    }

    if (refreshTasks) {
      taskBloc.add(LoadTasksEvent(userId));
    }

    if (refreshExams) {
      examBloc.add(LoadExamsEvent(userId));
    }
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
    final sectionSpacing = screenWidth >= 768 ? 18.0 : 16.0;
    final maxContentWidth = screenWidth >= 1280 ? 1040.0 : 920.0;
    final useMaxWidth = screenWidth >= 900;

    final authCubit = context.read<AuthCubit>();
    final userName = authCubit.currenUser?.name ?? 'User';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'OngdiSphere',
          style: TextStyle(
            color: colors.tertiaryText,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            icon: Icon(Icons.menu_rounded, color: colors.tertiaryText),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isDark = themeMode == ThemeMode.dark;

              return IconButton(
                tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                icon: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: colors.tertiaryText,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleDarkMode(!isDark);
                },
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(), // Custom navigation drawer
      body: KuromiPageBackground(
        topColor: colors.surface,
        bottomColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF120E15)
            : const Color(0xFFF3E4EF),
        preset: KuromiBackgroundPreset.orchid,
        animate: true,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: useMaxWidth ? maxContentWidth : double.infinity,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  22,
                ),
                children: [
                  _buildAnimatedSection(
                    begin: 0,
                    end: 0.45,
                    child: HomeWelcomeBanner(userName: userName),
                  ),
                  SizedBox(height: sectionSpacing),
                  _buildAnimatedSection(
                    begin: 0.15,
                    end: 0.62,
                    child: BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, taskState) {
                        return BlocBuilder<ExamBloc, ExamState>(
                          builder: (context, examState) {
                            int taskCount = 0;
                            int examCount = 0;

                            if (taskState is TaskLoaded) {
                              taskCount = taskState.tasks
                                  .where((task) => !task.done)
                                  .length;
                            }

                            if (examState is ExamLoaded) {
                              examCount = examState.exams
                                  .where((exam) => !exam.done)
                                  .length;
                            }

                            return HomeOverviewSection(
                              taskCount: taskCount,
                              examCount: examCount,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                  _buildAnimatedSection(
                    begin: 0.28,
                    end: 0.8,
                    child: const MotivationalQuoteSection(),
                  ),
                  SizedBox(height: sectionSpacing),
                  _buildAnimatedSection(
                    begin: 0.4,
                    end: 1,
                    child: HomeActionsSection(
                      onSubjectsTap: () => _navigateAndReload(
                        route: '/subjects',
                        refreshTasks: true,
                        refreshExams: true,
                      ),
                      onTasksTap: () => _navigateAndReload(
                        route: '/tasks',
                        refreshTasks: true,
                        refreshExams: false,
                      ),
                      onExamsTap: () => _navigateAndReload(
                        route: '/exams',
                        refreshTasks: false,
                        refreshExams: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
