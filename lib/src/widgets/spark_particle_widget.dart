import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_optimized_particles/flutter_optimized_particles.dart';

/// Represents a single spark particle.
class SparkParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifespan; // 0.0 to 1.0

  SparkParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    this.lifespan = 1.0,
  });

  void update(double dt) {
    position += velocity * dt;
    lifespan -= dt * 1.8; // Slower decay rate
    velocity *= 0.98; // Simple air resistance/slowdown
  }

  bool get isAlive => lifespan > 0;
}

/// 🔥 OPTIMIZED: Custom Painter for drawing spark particles with minimal repaints
class SparkPainter extends OptimizedParticlePainter {
  final List<SparkParticle> particles;

  SparkPainter(this.particles, double animationValue, DateTime frameTime) 
    : super(animationValue, frameTime);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      if (particle.isAlive) {
        paint.color = particle.color.withAlpha((math.max(0, particle.lifespan) * 255).round());
        // Draw simple circles for sparks
        canvas.drawCircle(particle.position, particle.size * particle.lifespan, paint);
      }
    }
  }
}

/// Widget that displays a burst of spark particles.
class SparkParticleWidget extends StatefulWidget {
  final Offset position; // Global position for the center of the burst
  final VoidCallback onComplete;
  final int count;
  final double speed;
  final double spread;
  final Color startColor;
  final Color endColor;
  final Duration duration;

  const SparkParticleWidget({
    required this.position,
    required this.onComplete,
    this.count = 20,
    this.speed = 80.0,
    this.spread = 1.5,
    this.startColor = Colors.yellow,
    this.endColor = Colors.orange,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  @override
  State<SparkParticleWidget> createState() => _SparkParticleWidgetState();
}

class _SparkParticleWidgetState extends State<SparkParticleWidget> with SingleTickerProviderStateMixin {
  // 🔥 OPTIMIZED: Using OptimizedParticleController instead of regular AnimationController
  late OptimizedParticleController _optimizedController;
  final List<SparkParticle> _particles = [];
  final math.Random _random = math.Random();
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    // 🔥 PERFORMANCE FIX: Create optimized controller that eliminates setState() calls
    _optimizedController = OptimizedParticleController(
      duration: widget.duration,
      vsync: this,
      onComplete: widget.onComplete,
      onUpdate: _updateParticles,
    );

    // Create initial particles with varied properties
    for (int i = 0; i < widget.count; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = widget.speed * (0.3 + _random.nextDouble() * 0.7);
      final velocity = Offset(math.cos(angle), math.sin(angle)) * speed * widget.spread;

      // Base color from the gradient with slight randomness
      final baseColorPosition = _random.nextDouble();
      final baseColor = Color.lerp(widget.startColor, widget.endColor, baseColorPosition)!;

      // Further variation by blending with white for some sparks
      final color = _random.nextDouble() < 0.3
          ? Color.lerp(baseColor, Colors.white, _random.nextDouble() * 0.7)!
          : baseColor;

      // Varied sizes for more visual interest
      final size = 1.5 + _random.nextDouble() * 3.0;

      // Initial lifespan to create staggered effect
      final initialLifespan = 0.8 + _random.nextDouble() * 0.2;

      _particles.add(SparkParticle(
        position: Offset(
          (_random.nextDouble() - 0.5) * 5.0, // Small initial spread
          (_random.nextDouble() - 0.5) * 5.0,
        ),
        velocity: velocity,
        color: color,
        size: size,
        lifespan: initialLifespan,
      ));
    }

    _optimizedController.forward();
  }

  /// 🔥 PERFORMANCE FIX: High-performance update without setState() calls
  void _updateParticles() {
    if (!mounted) return;
    
    final now = DateTime.now();
    final deltaTime = now.difference(_lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = now;
    
    // Cap delta time to prevent huge jumps
    final dt = deltaTime.clamp(0.005, 0.1); // 5ms to 100ms range
    
    bool anyAlive = false;

    for (final particle in _particles) {
      if (particle.isAlive) {
        particle.update(dt);

        // Add some gravity effect
        particle.velocity += const Offset(0, 2.0) * dt;

        anyAlive = true;
      }
    }

    if (!anyAlive && _optimizedController.isAnimating) {
       _optimizedController.stop();
    }

    // 🔥 CRITICAL: NO setState() call here - CustomPainter handles repainting
  }

  @override
  void dispose() {
    _optimizedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 FIX: Positioned must be the parent of OptimizedParticleWidget, not the child
    // This prevents the "ParentDataWidget inside RepaintBoundary" error
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: OptimizedParticleWidget(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _optimizedController.controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.zero,
                painter: SparkPainter(_particles, _optimizedController.value, DateTime.now()),
              );
            },
          ),
        ),
      ),
    );
  }
} 