import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom Painter for the ripple effect.
class RipplePainter extends CustomPainter {
  final double animationValue; // 0.0 to 1.0
  final Color color;
  final int rippleCount;
  final double maxRadius;

  RipplePainter({
    required this.animationValue,
    required this.color,
    this.rippleCount = 3,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < rippleCount; i++) {
      // Stagger the start of each ripple
      double rippleProgress = (animationValue * rippleCount) - i;
      rippleProgress = rippleProgress.clamp(0.0, 1.0);

      if (rippleProgress > 0) {
        final double radius = rippleProgress * maxRadius;
        // Fade out ripples as they expand and over time
        final double opacity = (1.0 - rippleProgress) * (1.0 - animationValue * 0.5);
        paint.color = color.withAlpha((opacity.clamp(0.0, 1.0) * 255).round());
        // Make ripples thinner as they expand
        paint.strokeWidth = math.max(0.5, (1.0 - rippleProgress) * 3.0);

        canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
           color != oldDelegate.color ||
           rippleCount != oldDelegate.rippleCount ||
           maxRadius != oldDelegate.maxRadius;
  }
}

/// Widget that displays an expanding ripple effect.
class RippleEffectWidget extends StatefulWidget {
  final Offset position; // Global position for the center of the ripple
  final VoidCallback onComplete;
  final Color color;
  final double maxRadius;
  final Duration duration;

  const RippleEffectWidget({
    required this.position,
    required this.onComplete,
    this.color = Colors.blueGrey,
    this.maxRadius = 40.0,
    this.duration = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<RippleEffectWidget> createState() => _RippleEffectWidgetState();
}

class _RippleEffectWidgetState extends State<RippleEffectWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We need a size for the CustomPaint canvas
    final canvasSize = widget.maxRadius * 2;
    return Positioned(
      left: widget.position.dx - widget.maxRadius, // Adjust position for canvas size
      top: widget.position.dy - widget.maxRadius,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(canvasSize, canvasSize),
              painter: RipplePainter(
                animationValue: _controller.value,
                color: widget.color,
                maxRadius: widget.maxRadius,
              ),
            );
          }
      ),
    );
  }
} 