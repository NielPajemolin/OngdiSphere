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
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: decoration,
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}
