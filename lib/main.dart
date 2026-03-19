import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/shared/animations/app_routes.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/data/repositories/repositories.dart';
import 'package:ongdisphere/features/auth/auth.dart';
import 'package:ongdisphere/features/done/done.dart';
import 'package:ongdisphere/features/exam/exam.dart';
import 'package:ongdisphere/features/home/home.dart';
import 'package:ongdisphere/features/profile/profile.dart';
import 'package:ongdisphere/features/subject/subject.dart';
import 'package:ongdisphere/features/task/task.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  //auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  // Repositories
  final subjectRepository = SubjectRepository();
  final taskRepository = TaskRepository();
  final examRepository = ExamRepository();

  // Helper function to map named routes to their Widgets
  Widget? _getPage(String? routeName) {
    switch (routeName) {
      case '/home':
        return const HomePage();
      case '/subjects':
        return const SubjectPage();
      case '/tasks':
        return const TaskPage();
      case '/exams':
        return const ExamPage();
      case '/done':
        return const DonePage();
      case '/profile':
        return ProfilePage();
      default:
        return null; // Route not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //provide cubits to the app
      providers: [
        //app cubit
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        // Subject BLoC
        BlocProvider<SubjectBloc>(
          create: (context) => SubjectBloc(
            subjectRepository: subjectRepository,
            examRepository: examRepository,
          ),
        ),
        // Task BLoC
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(taskRepository: taskRepository),
        ),
        // Exam BLoC
        BlocProvider<ExamBloc>(
          create: (context) => ExamBloc(examRepository: examRepository),
        ),
      ],
      //app
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // --- CUSTOM ROUTE IMPLEMENTATION ---
        // This function handles navigation and applies the slide animation.
        onGenerateRoute: (settings) {
          final page = _getPage(settings.name);

          if (page != null) {
            // Apply the custom transition for all named routes
            return slideTransitionRoute(page);
          }
          // Fallback route if the path is unrecognized
          return MaterialPageRoute(builder: (_) => const AuthPage());
        },

        //Bloc Auth
        home: BlocConsumer<AuthCubit, AuthStates>(
          builder: (context, state) {
            //if unaunthenticated go to auth page(login/sign up)
            if (state is Unauntenticated) {
              return const AuthPage();
            }
            //if aunthenticated to homepage
            if (state is Autheticated) {
              return const HomePage();
            }
            //loading
            else {
              return const LoadingScreen();
            }
          },
          //listen for state change
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }
}
