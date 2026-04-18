import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/animations/press_scale.dart';

class DialogActionButtons extends StatelessWidget {
  const DialogActionButtons({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.cancelLabel = 'Cancel',
    this.confirmBackgroundColor,
  });

  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final Color? confirmBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final buttonColor = confirmBackgroundColor ?? colors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PressScale(
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              cancelLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        PressScale(
          child: FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}