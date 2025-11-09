import 'package:flutter/material.dart';
import 'dart:math' as math;
import './spark_particle_widget.dart'; // Import needed helpers

/// Trail effect types for different projectile categories
enum TrailType {
  sparks,      // Default orange sparks (arrows, tools)
  smoke,       // Grey smoke trails (muskets, cannons)
  magic,       // Purple/blue magical sparkles (mystics, divine)
  poison,      // Green toxic particles (poison darts)
  ethereal,    // Cyan/white wispy trail (special/ethereal)
  scroll,      // Parchment-colored dust (diplomatic)
  none,        // No trail effect (for performance)
}

/// Properties for trail particle behavior
class TrailProperties {
  final double baseSize;
  final double sizeVariation;
  final double velocityScale;
  final double lifespan;

  const TrailProperties({
    required this.baseSize,
    required this.sizeVariation,
    required this.velocityScale,
    required this.lifespan,
  });
}

/// Represents a projectile moving from one point to another
class ProjectileWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;
  final Color color;
  final double size;
  final Duration duration;
  final Widget? projectileWidget; // Allow custom widget for projectile visual
  final TrailType trailType; // Category-specific trail effects

  const ProjectileWidget({
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
    this.color = Colors.white,
    this.size = 10.0,
    this.duration = const Duration(milliseconds: 300),
    this.projectileWidget,
    this.trailType = TrailType.sparks,
    super.key,
  });

  @override
  State<ProjectileWidget> createState() => _ProjectileWidgetState();
}

class _ProjectileWidgetState extends State<ProjectileWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  final List<SparkParticle> _trailParticles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Add listener to create trail particles
    _controller.addListener(_addTrailParticle);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  void _addTrailParticle() {
    // Skip trails for 'none' type
    if (widget.trailType == TrailType.none) {
      return;
    }
    
    // Category-specific particle frequency
    final frequency = _getTrailFrequency();
    if (_random.nextDouble() > frequency) return;

    final progress = _progressAnimation.value;
    final currentPosition = Offset.lerp(widget.startPosition, widget.endPosition, progress)!;

    // Category-specific particle properties
    final particleProps = _getTrailProperties();
    
    final particleSize = particleProps.baseSize + _random.nextDouble() * particleProps.sizeVariation;
    final velocity = Offset(
      (_random.nextDouble() - 0.5) * particleProps.velocityScale,
      (_random.nextDouble() - 0.5) * particleProps.velocityScale,
    );

    // Category-specific color variations
    final particleColor = _getTrailColor();

    _trailParticles.add(SparkParticle(
      position: currentPosition,
      velocity: velocity,
      color: particleColor,
      size: particleSize,
      lifespan: particleProps.lifespan + _random.nextDouble() * 0.4,
    ));

    // Update existing particles
    for (final particle in _trailParticles) {
      particle.update(1/60); // Approximate delta time
    }

    // Remove dead particles
    _trailParticles.removeWhere((particle) => !particle.isAlive);

    // Force rebuild to update particles
    setState(() {});
  }

  /// Get trail particle frequency based on type
  double _getTrailFrequency() {
    switch (widget.trailType) {
      case TrailType.sparks:
        return 0.4; // Moderate spark trail
      case TrailType.smoke:
        return 0.6; // Dense smoke trail
      case TrailType.magic:
        return 0.5; // Magical sparkles
      case TrailType.poison:
        return 0.3; // Subtle toxic particles
      case TrailType.ethereal:
        return 0.2; // Wispy ethereal trail
      case TrailType.scroll:
        return 0.35; // Parchment dust
      case TrailType.none:
        return 0.0; // No particles
    }
  }

  /// Get trail particle properties based on type
  TrailProperties _getTrailProperties() {
    switch (widget.trailType) {
      case TrailType.sparks:
        return TrailProperties(
          baseSize: 1.5,
          sizeVariation: 2.0,
          velocityScale: 25.0,
          lifespan: 0.6,
        );
      case TrailType.smoke:
        return TrailProperties(
          baseSize: 2.0,
          sizeVariation: 3.0,
          velocityScale: 15.0,
          lifespan: 0.8,
        );
      case TrailType.magic:
        return TrailProperties(
          baseSize: 1.2,
          sizeVariation: 2.5,
          velocityScale: 30.0,
          lifespan: 0.7,
        );
      case TrailType.poison:
        return TrailProperties(
          baseSize: 1.0,
          sizeVariation: 1.5,
          velocityScale: 18.0,
          lifespan: 0.9,
        );
      case TrailType.ethereal:
        return TrailProperties(
          baseSize: 0.8,
          sizeVariation: 1.8,
          velocityScale: 12.0,
          lifespan: 1.2,
        );
      case TrailType.scroll:
        return TrailProperties(
          baseSize: 1.3,
          sizeVariation: 2.2,
          velocityScale: 20.0,
          lifespan: 0.5,
        );
      case TrailType.none:
        return TrailProperties(
          baseSize: 0.0,
          sizeVariation: 0.0,
          velocityScale: 0.0,
          lifespan: 0.0,
        );
    }
  }

  /// Get category-specific trail color
  Color _getTrailColor() {
    switch (widget.trailType) {
      case TrailType.sparks:
        // Orange/yellow sparks with white highlights
        return Color.lerp(
          Colors.orange.shade600,
          Colors.yellow.shade300,
          _random.nextDouble()
        )!;
      case TrailType.smoke:
        // Grey smoke with dark variations
        return Color.lerp(
          Colors.grey.shade600,
          Colors.grey.shade300,
          _random.nextDouble()
        )!;
      case TrailType.magic:
        // Purple/blue magical sparkles
        return Color.lerp(
          Colors.purple.shade400,
          Colors.blue.shade300,
          _random.nextDouble()
        )!;
      case TrailType.poison:
        // Green toxic particles
        return Color.lerp(
          Colors.green.shade600,
          Colors.green.shade300,
          _random.nextDouble()
        )!;
      case TrailType.ethereal:
        // Cyan/white wispy particles
        return Color.lerp(
          Colors.cyan.shade200,
          Colors.white,
          _random.nextDouble()
        )!;
      case TrailType.scroll:
        // Parchment-colored dust
        return Color.lerp(
          Colors.brown.shade300,
          Colors.amber.shade200,
          _random.nextDouble()
        )!;
      case TrailType.none:
        return Colors.transparent;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_addTrailParticle);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _progressAnimation.value;
        final currentPosition = Offset.lerp(widget.startPosition, widget.endPosition, progress)!;

        return Stack(
          children: [
            // Draw trail particles
            if (_trailParticles.isNotEmpty)
              CustomPaint(
                size: Size.infinite,
                painter: SparkPainter(_trailParticles, _controller.value, DateTime.now()),
              ),

            // Draw the projectile
            Positioned(
              left: currentPosition.dx - widget.size / 2,
              top: currentPosition.dy - widget.size / 2,
              child: widget.projectileWidget ?? _defaultProjectile(),
            ),
          ],
        );
      },
    );
  }

  Widget _defaultProjectile() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withAlpha((0.7 * 255).round()),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
} 