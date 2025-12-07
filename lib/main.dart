import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/components/loading.dart';
import 'package:ongdisphere/features/auth/data/firebase_auth_repo.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_states.dart';
import 'package:ongdisphere/pages/home_page.dart';
import 'package:ongdisphere/pages/profile_page.dart';
import 'firebase_options.dart';


import 'features/auth/presentation/pages/auth_page.dart';
import 'colorpalette/app_theme.dart';
import 'pages/subject_page.dart';
import 'pages/task_page.dart';
import 'pages/exam_page.dart';
import 'pages/done_page.dart';


void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
 MyApp({super.key});

  //auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //provide cubits to the app
      providers: [
        //app cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: firebaseAuthRepo)
          ..checkAuth(),
        ),
      ], 
      //app
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,


        //routes
        routes: {
          '/home': (context) => const HomePage(),
          '/subjects': (context) => const SubjectPage(),
          '/tasks': (context) => const TaskPage(),
          '/exams': (context) => const ExamPage(),
          '/done': (context) => const DonePage(),
          '/profile': (context) =>  ProfilePage()
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
            return const
             LoadingScreen();
          }
        },
        //listen for state change
        listener: (context ,state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message)));
          }
        }
      )
      ),
    );
  }
}