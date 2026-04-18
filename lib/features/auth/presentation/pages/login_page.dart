// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/shared/animations/app_routes.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:ongdisphere/features/auth/presentation/cubits/auth/auth_states.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';

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

  late final authCubit = context.read<AuthCubit>();

  void login() {
    final String email = emailController.text;
    final String pw = passwordController.text;

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
    }
  }

  void openForgotPasswordBox() {
    showDialog(
      context: context,
      builder: (context) {
        final colors = AppTheme.colorsOf(context);

        return AnimatedFormDialog(
          title: 'Reset Password',
          icon: Icons.lock_reset_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your email to receive a reset link.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: colors.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              MyTextfield(
                controller: resetpwController,
                hintText: 'you@example.com',
                labeltext: 'Email address',
                obscureText: false,
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(
                          color: colors.primary.withValues(alpha: 0.28),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final message = await authCubit.forgotPassword(
                          resetpwController.text,
                        );

                        if (!context.mounted) return;

                        if (message == 'Password reset email sent! Check your email.') {
                          Navigator.pop(context);
                          resetpwController.clear();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Send Link',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    resetpwController.dispose();
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
    final logoHeight = screenWidth >= 768 ? 168.0 : 150.0;

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
              bottomColor: const Color(0xFFF7EAF4),
              preset: KuromiBackgroundPreset.ink,
              animate: true,
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
                                  'Welcome Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Login to continue planning your goals.',
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x1FF48FB1)),
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
                                  textInputAction: TextInputAction.done,
                                  onEditingComplete: login,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: openForgotPasswordBox,
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(color: colors.secondary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                MyButton(label: 'Login', onPressed: login),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account? ',
                                style: TextStyle(color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: widget.togglePages,
                                child: Text(
                                  'Sign Up',
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
                return AppAnimations.buildLoadingOverlay(context, 'Logging in...');
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }


}
