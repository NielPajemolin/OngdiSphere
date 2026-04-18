import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/shared/animations/app_routes.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_states.dart';
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
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 1024
        ? 26.0
        : screenWidth >= 768
        ? 22.0
        : 20.0;
    final topPadding = screenWidth >= 768 ? 18.0 : 14.0;
    final maxContentWidth = screenWidth >= 1280 ? 700.0 : 560.0;
    final useMaxWidth = screenWidth >= 700;
    final logoHeight = screenWidth >= 768 ? 156.0 : 140.0;

    return BlocListener<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: colors.surface,
            body: KuromiPageBackground(
              topColor: colors.surface,
              bottomColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF100C13)
                  : const Color(0xFFF7EAF4),
              preset: KuromiBackgroundPreset.plum,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: useMaxWidth ? maxContentWidth : double.infinity,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        topPadding,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        children: [
                          KuromiDecoratedContainer(
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF131015), Color(0xFF8F6EA8)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x30F48FB1),
                                  blurRadius: 24,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            patternColor: Colors.white,
                            patternOpacity: 0.18,
                            child: Column(
                              children: [
                                // Keep the existing logo image as requested.
                                Image.asset(
                                  'assets/images/logowithname.png',
                                  height: logoHeight,
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
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          KuromiDecoratedContainer(
                            borderRadius: BorderRadius.circular(20),
                            padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            patternColor: colors.secondary,
                            patternOpacity: 0.06,
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
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                                ),
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
              ),
            ),
          ),
          // Loading overlay with animation
          BlocBuilder<AuthCubit, AuthStates>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return AppAnimations.buildLoadingOverlay(context, 'Creating account...');
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }


}
