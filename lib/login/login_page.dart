// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import '../colorpalette/color_palette.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetpwController = TextEditingController();

    //auth cubit
  late final authCubit = context.read<AuthCubit>();

  //log button pressed
  void login() {
    //prepare email &p w
    final String email = emailController.text;
    final String pw = passwordController.text;

    //make sure all the fields are filled
    if (email.isNotEmpty && pw.isNotEmpty) {
      //login
      authCubit.login(email, pw);
    }
    //field are empty
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
    }
  }

  //forgot password box
  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password?"),
        content: MyTextfield(
          controller: resetpwController, 
          hintText: "", 
          labeltext: "Enter email...", 
          obscureText: false,
          ),
          actions: [
            // cancel button
            TextButton(onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel"),
            ),

            //reset button
            TextButton(onPressed: () async {
              String message = 
                  await authCubit.forgotPassword(resetpwController.text);

              if (message == "Password reset email sent! Check your email.") {
                Navigator.pop(context);
                resetpwController.clear();
              }

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
            }, 
            child: const Text("Reset"),
            ),
          ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.03),

                // Logo
                Image.asset(
                  'assets/images/logowithname.png',
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.30,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: screenHeight * 0.03),

                // Welcome text
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: colors.tertiaryText,
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Email textfield
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  labeltext: "Email",
                  obscureText: false,
                ),

                SizedBox(height: screenHeight * 0.02),

                // Password textfield
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  labeltext: "Password",
                  obscureText: true,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => openForgotPasswordBox(),
                      child: Text(
                        '  Forgot Password?',
                        style: TextStyle(
                          color: colors.secondary,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                // Login button
                MyButton(label: 'Login', onPressed: login),
                SizedBox(height: screenHeight * 0.04),

                // Signup link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'dont have an account? ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
