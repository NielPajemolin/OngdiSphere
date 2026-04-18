import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ongdisphere/features/auth/auth.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';
import 'package:ongdisphere/features/profile/presentation/widgets/edit_profile_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 1024
        ? 26.0
        : screenWidth >= 768
        ? 22.0
        : 18.0;
    final maxContentWidth = screenWidth >= 1280 ? 900.0 : 760.0;
    final useMaxWidth = screenWidth >= 900;
    final headerPadding = screenWidth >= 768 ? 20.0 : 18.0;
    Widget animatedSection({
      required Widget child,
      required int milliseconds,
      double yOffset = 12,
    }) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: milliseconds),
        curve: Curves.easeOutCubic,
        builder: (context, value, animatedChild) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * yOffset),
            child: Opacity(opacity: value, child: animatedChild),
          );
        },
        child: child,
      );
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: colors.tertiaryText,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthStates>(
        builder: (context, state) {
          final authCubit = context.read<AuthCubit>();
          final currentUser = state is Autheticated
              ? state.user
              : authCubit.currenUser;

          final rawName = currentUser?.name?.trim() ?? '';
          final rawEmail = currentUser?.email.trim() ?? '';
          final userName = rawName.isNotEmpty ? rawName : 'No name';
          final userEmail = rawEmail.isNotEmpty ? rawEmail : 'No email';
          final userInitial = userName.isNotEmpty
              ? userName.characters.first.toUpperCase()
              : 'U';
          final profilePictureValue = currentUser?.profilePictureUrl;

          MemoryImage? profileMemoryImage;
          if (profilePictureValue != null && profilePictureValue.isNotEmpty) {
            try {
              profileMemoryImage = MemoryImage(base64Decode(profilePictureValue));
            } catch (_) {
              profileMemoryImage = null;
            }
          }

          return KuromiPageBackground(
            topColor: colors.surface,
            bottomColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF110D14)
                : const Color(0xFFF8EAF4),
            preset: KuromiBackgroundPreset.moon,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: useMaxWidth ? maxContentWidth : double.infinity,
                  ),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                  animatedSection(
                    milliseconds: 260,
                    child: Container(
                      padding: EdgeInsets.all(headerPadding),
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: profileMemoryImage,
                              child: profileMemoryImage == null
                                  ? Text(
                                      userInitial,
                                      style: const TextStyle(
                                        color: Color(0xFF131015),
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userEmail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  animatedSection(
                    milliseconds: 340,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF48FB1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colors.tertiaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ProfileInfoTile(
                            icon: Icons.person_rounded,
                            label: 'Name',
                            value: userName,
                          ),
                          const SizedBox(height: 12),
                          _ProfileInfoTile(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: userEmail,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  animatedSection(
                    milliseconds: 420,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF48FB1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colors.tertiaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          BlocBuilder<ThemeCubit, ThemeMode>(
                            builder: (context, themeMode) {
                              final isDarkMode = themeMode == ThemeMode.dark;

                              return SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Dark Mode'),
                                subtitle: const Text(
                                  'Use darker colors across the app interface.',
                                ),
                                value: isDarkMode,
                                onChanged: (value) {
                                  context.read<ThemeCubit>().toggleDarkMode(value);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          MyButton(
                            label: 'Edit Profile',
                            onPressed: () {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Edit Profile',
                                barrierColor: Colors.black54,
                                transitionDuration:
                                    const Duration(milliseconds: 260),
                                pageBuilder: (dialogContext, animation, secondaryAnimation) {
                                  return const EditProfileDialog();
                                },
                                transitionBuilder:
                                    (dialogContext, animation, secondaryAnimation, child) {
                                  final eased = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  );

                                  return FadeTransition(
                                    opacity: eased,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.92, end: 1.0)
                                          .animate(eased),
                                      child: child,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2230)
            : const Color(0xFFFFF6FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.colorsOf(context).tertiaryText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.colorsOf(context).tertiaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
