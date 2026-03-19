import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';

class AnimatedFormDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const AnimatedFormDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      shadowColor: Colors.black26,
      backgroundColor: colors.surface,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, dialogChild) {
          return ScaleTransition(
            scale: AlwaysStoppedAnimation(0.85 + (value * 0.15)),
            child: FadeTransition(
              opacity: AlwaysStoppedAnimation(value),
              child: dialogChild,
            ),
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: colors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}