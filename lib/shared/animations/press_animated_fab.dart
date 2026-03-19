import 'package:flutter/material.dart';

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
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: FloatingActionButton(
          heroTag: widget.heroTag,
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}