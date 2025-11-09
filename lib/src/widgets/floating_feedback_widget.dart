import 'package:flutter/material.dart';
// Corrected Import Path
import 'dart:math' as math;

/// NEW: A widget that displays floating text feedback for damage or buffs
class FloatingFeedbackWidget extends StatefulWidget {
  final Offset position; // Global position for the center
  final VoidCallback onComplete;
  final String text; // The text to display (e.g., "-5", "+2")
  final Color color; // Color of the text
  final Duration duration;
  final IconData? icon; // NEW: Optional icon to display
  final String? iconAssetPath; // NEW: Optional asset path for custom icons

  const FloatingFeedbackWidget({
    required this.position,
    required this.onComplete,
    required this.text,
    this.color = Colors.white,
    this.duration = const Duration(milliseconds: 1500),
    this.icon, // NEW: Optional icon parameter
    this.iconAssetPath, // NEW: Optional asset path parameter
    super.key,
  });

  @override
  State<FloatingFeedbackWidget> createState() => _FloatingFeedbackWidgetState();
}

class _FloatingFeedbackWidgetState extends State<FloatingFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Opacity: starts at 1.0, stays visible for most of the duration, then fades out
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    // Position: floats upward with some randomness
    final randomOffset = (math.Random().nextDouble() - 0.5) * 40; // Random horizontal drift
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(randomOffset, -60), // Float up and slightly sideways
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Scale: simple pop-in effect
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx + _positionAnimation.value.dx - 50, // Center the widget
          top: widget.position.dy + _positionAnimation.value.dy - 25, // Center the widget
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.7 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.color,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withAlpha((0.4 * 255).round()),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NEW: Display icon if provided
                    if (widget.iconAssetPath != null) ...[
                      Image.asset(
                        widget.iconAssetPath!,
                        width: 16,
                        height: 16,
                        // Removed color overlay to show original icon instead of color tint
                      ),
                      const SizedBox(width: 4),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 16,
                        color: widget.color,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withAlpha((0.8 * 255).round()),
                            blurRadius: 3,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 