import 'package:flutter/material.dart';
import 'package:ongdisphere/login/signup_page.dart';
import '../../../../login/login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  //show log in page
  bool showLoginPage = true;

  //toggle beween app
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return  LoginPage(
        togglePages: togglePages,
      );
    } else {
      return SignupPage(
        togglePages: togglePages,
      );
    }
  }
}