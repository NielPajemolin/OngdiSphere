import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';

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
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      }
    }
    //fields empty show error
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
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

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surface, const Color(0xFFE7F2FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x301565C0),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Keep the existing logo image as requested.
                      Image.asset(
                        'assets/images/logowithname.png',
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Start organizing your studies in minutes.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x1F1565C0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      MyTextfield(
                        controller: userNameController,
                        hintText: 'Username',
                        labeltext: 'Username',
                        obscureText: false,
                        prefixIcon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      MyTextfield(
                        controller: emailController,
                        hintText: 'you@example.com',
                        labeltext: 'Email',
                        obscureText: false,
                        prefixIcon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      MyTextfield(
                        controller: passwordController,
                        hintText: 'Password',
                        labeltext: 'Password',
                        obscureText: true,
                        prefixIcon: Icons.lock_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      MyTextfield(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        labeltext: 'Confirm Password',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: register,
                      ),
                      const SizedBox(height: 8),
                      MyButton(label: 'Create Account', onPressed: register),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
