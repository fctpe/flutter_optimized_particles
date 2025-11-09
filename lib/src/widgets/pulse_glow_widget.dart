import 'package:flutter/material.dart';

/// A widget that shows a brief, soft pulse of light at a specific position.
class PulseGlowWidget extends StatefulWidget {
  final Offset position; // Global position for the center of the glow
  final VoidCallback onComplete;
  final Color color;
  final Size size;

  const PulseGlowWidget({
    required this.position,
    required this.onComplete,
    this.color = Colors.lightBlueAccent, // Default color
    this.size = const Size(70, 70), // Slightly larger default size
    super.key,
  });

  @override
  State<PulseGlowWidget> createState() => _PulseGlowWidgetState();
}

class _PulseGlowWidgetState extends State<PulseGlowWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Slower glow duration
      vsync: this,
    );

    // Fade in/out, maybe scale slightly
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.6), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 0.0), weight: 3),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.1), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 3),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
    return Positioned(
      left: widget.position.dx - widget.size.width / 2,
      top: widget.position.dy - widget.size.height / 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: child,
            ),
          );
        },
        child: IgnorePointer(
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // boxShadow: [ // <-- Temporarily remove boxShadow
              //   BoxShadow(
              //     color: widget.color.withAlpha((0.8 * 255).round()), // Use widget color
              //     blurRadius: 15.0,
              //     spreadRadius: 8.0,
              //   ),
              // ],
            ),
          ),
        ),
      ),
    );
  }
} 