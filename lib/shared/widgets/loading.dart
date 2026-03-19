import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  final bool isFullScreen;

  const LoadingScreen({
    super.key,
    this.message = 'Loading...',
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: colors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (isFullScreen) {
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
          child: content,
        ),
      );
    }

    return content;
  }
}
