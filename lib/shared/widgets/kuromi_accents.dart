import 'package:flutter/material.dart';

class KuromiDecoratedContainer extends StatelessWidget {
  const KuromiDecoratedContainer({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.decoration,
    this.padding,
    this.patternColor,
    this.patternOpacity = 0.14,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final BoxDecoration decoration;
  final EdgeInsetsGeometry? padding;
  final Color? patternColor;
  final double patternOpacity;

  @override
  Widget build(BuildContext context) {
    final Color resolvedPatternColor =
        patternColor ?? Theme.of(context).colorScheme.tertiary;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: decoration,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -8,
              top: -10,
              child: _PatternRing(
                diameter: 52,
                color: resolvedPatternColor,
                opacity: patternOpacity,
              ),
            ),
            Positioned(
              left: 14,
              bottom: 10,
              child: _PatternDot(
                diameter: 14,
                color: resolvedPatternColor,
                opacity: patternOpacity,
              ),
            ),
            Positioned(
              left: 24,
              top: 12,
              child: _PatternCross(
                color: resolvedPatternColor,
                opacity: patternOpacity,
              ),
            ),
            Positioned(
              right: 26,
              bottom: 12,
              child: _PatternCross(
                color: resolvedPatternColor,
                opacity: patternOpacity * 0.9,
              ),
            ),
            if (padding == null) child else Padding(padding: padding!, child: child),
          ],
        ),
      ),
    );
  }
}

class _PatternRing extends StatelessWidget {
  const _PatternRing({
    required this.diameter,
    required this.color,
    required this.opacity,
  });

  final double diameter;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity * 1.2),
          width: 1.7,
        ),
      ),
      child: Center(
        child: _PatternDot(
          diameter: diameter * 0.2,
          color: color,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _PatternDot extends StatelessWidget {
  const _PatternDot({
    required this.diameter,
    required this.color,
    required this.opacity,
  });

  final double diameter;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _PatternCross extends StatelessWidget {
  const _PatternCross({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final strokeColor = color.withValues(alpha: opacity * 1.2);

    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        children: [
          _CrossLine(angle: 0.7, color: strokeColor),
          _CrossLine(angle: -0.7, color: strokeColor),
        ],
      ),
    );
  }
}

class _CrossLine extends StatelessWidget {
  const _CrossLine({required this.angle, required this.color});

  final double angle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 14,
          height: 1.8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
