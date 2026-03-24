import 'package:flutter/material.dart';
import 'package:ongdisphere/core/theme/theme.dart';

class PressAnimatedFab extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Object? heroTag;
  final String? tooltip;

  const PressAnimatedFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.heroTag,
    this.tooltip,
  });

  @override
  State<PressAnimatedFab> createState() => _PressAnimatedFabState();
}

class _PressAnimatedFabState extends State<PressAnimatedFab> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF48FB1), Color(0xFF8F6EA8)],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.secondary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: widget.heroTag,
            tooltip: widget.tooltip,
            onPressed: widget.onPressed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            foregroundColor: const Color(0xFF211724),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}