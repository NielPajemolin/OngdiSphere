import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';

Future<bool> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String deleteLabel = 'Delete',
}) async {
  final colors = Theme.of(context).extension<AppColors>()!;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 14,
      backgroundColor: colors.surface,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.92 + (0.08 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  color: colors.tertiaryText.withValues(alpha: 0.82),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(cancelLabel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(deleteLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return confirmed ?? false;
}