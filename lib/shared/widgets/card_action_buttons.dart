import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/animations/press_scale.dart';

class CardActionButtons extends StatelessWidget {
  const CardActionButtons({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          PressScale(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        if (onEdit != null && onDelete != null) const SizedBox(width: 6),
        if (onDelete != null)
          PressScale(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}