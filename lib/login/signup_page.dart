import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import '../colorpalette/color_palette.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class SignupPage extends StatefulWidget {
  final void Function()? togglePages;
  const SignupPage({super.key, required this.togglePages});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //create account button pressed
  void register() {
    //prepare info
    final String name = userNameController.text;
    final String email = emailController.text;
    final String pw = passwordController.text;
    final String confirmpw = confirmPasswordController.text;

    //authc ubit
    final authCubit = context.read<AuthCubit>();

    //ensure fields aren't empty
    if (email.isNotEmpty &&
        name.isNotEmpty &&
        pw.isNotEmpty &&
        confirmpw.isNotEmpty) {
      //unsire pw match
      if (pw == confirmpw) {
        authCubit.register(name, email, pw);
      }
      //pw doesn't matcH
      else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password do not match')));
      }
    }
    //fields empty show error
    else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please complete all fields')));
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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

                // logo
                Image.asset(
                  'assets/images/logowithname.png',
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.25,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: screenHeight * 0.03),

                // title
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                //username textfield
                MyTextfield(
                  controller: userNameController,
                  hintText: 'Username',
                  labeltext: "Username",
                  obscureText: false,
                ),

                // email textfield
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  labeltext: "Email",
                  obscureText: false,
                ),

                // password textfield
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  labeltext: "Password",
                  obscureText: true,
                ),

                // confirm password textfield
                MyTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  labeltext: "Confirm Password",
                  obscureText: true,
                ),

                SizedBox(height: screenHeight * 0.03),

                // create account button
                MyButton(
                  label: 'Create Account',
                  onPressed: register,
                ),

                SizedBox(height: screenHeight * 0.04),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already have an account? ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        "Login",
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
