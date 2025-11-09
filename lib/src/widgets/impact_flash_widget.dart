import 'package:flutter/material.dart';

/// A widget that shows a brief, white flash at a specific position.
class ImpactFlashWidget extends StatefulWidget {
  final Offset position; // Global position for the center of the flash
  final VoidCallback onComplete;
  final Size size; // Size of the flash area

  const ImpactFlashWidget({
    required this.position,
    required this.onComplete,
    this.size = const Size(60, 60), // Default size
    super.key,
  });

  @override
  State<ImpactFlashWidget> createState() => _ImpactFlashWidgetState();
}

class _ImpactFlashWidgetState extends State<ImpactFlashWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350), // Slower flash
      vsync: this,
    );

    // Fade in quickly, then fade out
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.7), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.0), weight: 3),
    ]).animate(_controller);

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
      // Adjust position so the center of the flash aligns with widget.position
      left: widget.position.dx - widget.size.width / 2,
      top: widget.position.dy - widget.size.height / 2,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: IgnorePointer( // Flash should not block interactions
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle, // Use circle for a softer flash
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha((0.5 * 255).round()),
                  blurRadius: 10.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 