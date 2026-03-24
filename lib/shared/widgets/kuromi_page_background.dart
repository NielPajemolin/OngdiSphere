import 'package:flutter/material.dart';

/// Shared atmospheric background for Kuromi-themed pages.
enum KuromiBackgroundPreset {
  orchid,
  candy,
  twilight,
  mist,
  ink,
  plum,
  moon,
  blush,
}

class KuromiPageBackground extends StatelessWidget {
  const KuromiPageBackground({
    super.key,
    required this.child,
    required this.topColor,
    required this.bottomColor,
    this.preset = KuromiBackgroundPreset.orchid,
    this.animate = false,
  });

  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final KuromiBackgroundPreset preset;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return _AnimatedKuromiPageBackground(
        topColor: topColor,
        bottomColor: bottomColor,
        preset: preset,
        child: child,
      );
    }

    return _KuromiPageBackgroundBase(
      topColor: topColor,
      bottomColor: bottomColor,
      preset: preset,
      animationValue: 0,
      child: child,
    );
  }
}

class _AnimatedKuromiPageBackground extends StatefulWidget {
  const _AnimatedKuromiPageBackground({
    required this.child,
    required this.topColor,
    required this.bottomColor,
    required this.preset,
  });

  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final KuromiBackgroundPreset preset;

  @override
  State<_AnimatedKuromiPageBackground> createState() =>
      _AnimatedKuromiPageBackgroundState();
}

class _AnimatedKuromiPageBackgroundState
    extends State<_AnimatedKuromiPageBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _KuromiPageBackgroundBase(
          topColor: widget.topColor,
          bottomColor: widget.bottomColor,
          preset: widget.preset,
          animationValue: _controller.value,
          child: widget.child,
        );
      },
    );
  }
}

class _KuromiPageBackgroundBase extends StatelessWidget {
  const _KuromiPageBackgroundBase({
    required this.child,
    required this.topColor,
    required this.bottomColor,
    required this.preset,
    required this.animationValue,
  });

  final Widget child;
  final Color topColor;
  final Color bottomColor;
  final KuromiBackgroundPreset preset;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final shortSide = screenSize.shortestSide;
    final blobScale = shortSide >= 768 ? 1.2 : 1.0;
    final blobs = _specsForPreset(preset);
    final progress = (animationValue * 2) - 1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ...blobs.map(
            (blob) => Positioned(
              left:
                  (screenSize.width * blob.xFactor) +
                  (progress * blob.motionX),
              top:
                  (screenSize.height * blob.yFactor) +
                  (progress * blob.motionY),
              child: _GlowBlob(
                size: blob.size * blobScale,
                color: blob.color,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  List<_BlobSpec> _specsForPreset(KuromiBackgroundPreset preset) {
    switch (preset) {
      case KuromiBackgroundPreset.candy:
        return const [
          _BlobSpec(-0.18, -0.12, 230, Color(0x44F48FB1), 10, 7),
          _BlobSpec(0.62, 0.06, 190, Color(0x2FD7A5C7), -8, 6),
          _BlobSpec(0.58, 0.74, 300, Color(0x34131015), 7, -8),
          _BlobSpec(0.16, 0.58, 120, Color(0x23FFFFFF), -6, 8),
        ];
      case KuromiBackgroundPreset.twilight:
        return const [
          _BlobSpec(0.62, -0.12, 250, Color(0x3D8E24AA), 8, 9),
          _BlobSpec(-0.2, 0.2, 210, Color(0x319B6BAA), -10, 7),
          _BlobSpec(0.12, 0.72, 290, Color(0x2F131015), 6, -8),
          _BlobSpec(0.76, 0.62, 130, Color(0x20FFFFFF), -7, 8),
        ];
      case KuromiBackgroundPreset.mist:
        return const [
          _BlobSpec(0.68, -0.1, 220, Color(0x33FFFFFF), 9, 7),
          _BlobSpec(-0.24, 0.32, 250, Color(0x2CF48FB1), -9, 8),
          _BlobSpec(0.52, 0.7, 280, Color(0x2D9B6BAA), 7, -7),
          _BlobSpec(0.2, 0.84, 130, Color(0x28131015), -6, 7),
        ];
      case KuromiBackgroundPreset.ink:
        return const [
          _BlobSpec(0.58, -0.14, 260, Color(0x2F131015), 9, 8),
          _BlobSpec(-0.22, 0.24, 220, Color(0x399B6BAA), -8, 7),
          _BlobSpec(0.62, 0.66, 320, Color(0x2EF48FB1), 7, -9),
          _BlobSpec(0.14, 0.56, 110, Color(0x1FFFFFFF), -7, 8),
        ];
      case KuromiBackgroundPreset.plum:
        return const [
          _BlobSpec(-0.14, -0.08, 240, Color(0x3C9B6BAA), -9, 8),
          _BlobSpec(0.66, 0.1, 210, Color(0x32F48FB1), 8, 7),
          _BlobSpec(0.5, 0.72, 300, Color(0x2C131015), 6, -8),
          _BlobSpec(0.18, 0.66, 125, Color(0x22FFFFFF), -7, 9),
        ];
      case KuromiBackgroundPreset.moon:
        return const [
          _BlobSpec(0.62, -0.14, 250, Color(0x3FFFFFFF), 8, 8),
          _BlobSpec(-0.2, 0.22, 230, Color(0x2C9B6BAA), -9, 7),
          _BlobSpec(0.62, 0.74, 310, Color(0x2E131015), 7, -9),
          _BlobSpec(0.08, 0.6, 130, Color(0x2AF48FB1), -6, 8),
        ];
      case KuromiBackgroundPreset.blush:
        return const [
          _BlobSpec(0.58, -0.12, 235, Color(0x42F48FB1), 8, 7),
          _BlobSpec(-0.16, 0.22, 225, Color(0x319B6BAA), -8, 8),
          _BlobSpec(0.56, 0.74, 295, Color(0x2E131015), 7, -8),
          _BlobSpec(0.2, 0.62, 118, Color(0x23FFFFFF), -6, 8),
        ];
      case KuromiBackgroundPreset.orchid:
        return const [
          _BlobSpec(0.62, -0.12, 240, Color(0x40F48FB1), 8, 7),
          _BlobSpec(-0.18, 0.3, 200, Color(0x359B6BAA), -9, 8),
          _BlobSpec(0.6, 0.76, 300, Color(0x2D131015), 7, -8),
          _BlobSpec(0.22, 0.58, 110, Color(0x26FFFFFF), -7, 8),
        ];
    }
  }
}

class _BlobSpec {
  const _BlobSpec(
    this.xFactor,
    this.yFactor,
    this.size,
    this.color,
    this.motionX,
    this.motionY,
  );

  final double xFactor;
  final double yFactor;
  final double size;
  final Color color;
  final double motionX;
  final double motionY;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.06), Colors.transparent],
            stops: const [0.0, 0.58, 1.0],
          ),
        ),
      ),
    );
  }
}