import 'package:flutter/material.dart';

/// A widget that displays an expanding shockwave effect at a specific position.
class ShockwaveWidget extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;
  final Color color;
  final double size;
  final Duration duration;

  const ShockwaveWidget({
    required this.position,
    required this.onComplete,
    this.color = Colors.white,
    this.size = 100.0,
    this.duration = const Duration(milliseconds: 400),
    super.key,
  });

  @override
  State<ShockwaveWidget> createState() => _ShockwaveWidgetState();
}

class _ShockwaveWidgetState extends State<ShockwaveWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.7, end: 0.5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.5, end: 0.0), weight: 2),
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
      left: widget.position.dx - widget.size / 2,
      top: widget.position.dy - widget.size / 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return IgnorePointer(
            child: Container(
              width: widget.size * _sizeAnimation.value,
              height: widget.size * _sizeAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withAlpha((_opacityAnimation.value * 255).round()),
                  width: (1.0 + 4.0 * (1.0 - _controller.value)).clamp(1.0, 5.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 