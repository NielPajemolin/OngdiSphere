import 'package:flutter/material.dart';
import 'package:ongdisphere/shared/animations/app_routes.dart';
import 'package:ongdisphere/features/auth/presentation/pages/signup_page.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //show log in page
  bool showLoginPage = true;

  //toggle between pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPageSwitcher(
      showFirstPage: showLoginPage,
      firstPage: LoginPage(
        togglePages: togglePages,
      ),
      secondPage: SignupPage(
        togglePages: togglePages,
      ),
    );
  }
}