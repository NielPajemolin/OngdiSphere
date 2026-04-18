import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.isComplete,
    this.completedLabel = 'Completed',
    this.pendingLabel = 'Pending',
  });

  final bool isComplete;
  final String completedLabel;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.withValues(alpha: 0.12)
            : colors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isComplete
              ? Colors.green.withValues(alpha: 0.3)
              : colors.secondary.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        isComplete ? completedLabel : pendingLabel,
        style: TextStyle(
          color: isComplete ? Colors.green : colors.tertiaryText,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}