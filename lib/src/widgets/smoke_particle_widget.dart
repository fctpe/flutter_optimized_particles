import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_optimized_particles/flutter_optimized_particles.dart';

/// Represents a single smoke particle (similar to SparkParticle)
class SmokeParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double lifespan; // 0.0 to 1.0
  double rotation;
  double rotationSpeed;

  SmokeParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    this.lifespan = 1.0,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double dt) {
    position += velocity * dt;
    lifespan -= dt * 0.8; // Slower decay for smoke
    velocity *= 0.985; // Less slowdown
    rotation += rotationSpeed * dt;
  }

  bool get isAlive => lifespan > 0;
}

/// 🔥 OPTIMIZED: Custom Painter for drawing smoke particles with minimal repaints
class SmokePainter extends OptimizedParticlePainter {
  final List<SmokeParticle> particles;

  SmokePainter(this.particles, double animationValue, DateTime frameTime) 
    : super(animationValue, frameTime);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      if (particle.isAlive) {
        final currentOpacity = math.max(0, particle.lifespan);
        paint.color = particle.color.withAlpha((currentOpacity * 0.6 * 255).round()); // Lower opacity for smoke

        // Draw soft circles for smoke puffs
        canvas.save();
        canvas.translate(particle.position.dx, particle.position.dy);
        canvas.rotate(particle.rotation);
        // Simple scaling effect as it fades
        double scale = 1.0 + (1.0 - particle.lifespan) * 0.5;
        canvas.scale(scale, scale);
        // Draw circle centered at (0,0) after translation/rotation/scale
        canvas.drawCircle(Offset.zero, particle.size * currentOpacity, paint);
        canvas.restore();
      }
    }
  }
}

/// Widget that displays a burst of smoke particles.
class SmokeParticleWidget extends StatefulWidget {
  final Offset position; // Global position for the center of the burst
  final VoidCallback onComplete;
  final int count;
  final double initialSpeed;
  final double spread;
  final Duration duration;

  const SmokeParticleWidget({
    required this.position,
    required this.onComplete,
    this.count = 25,
    this.initialSpeed = 30.0, // Slower initial speed
    this.spread = 2.0, // Wider spread
    this.duration = const Duration(milliseconds: 1200), // Longer duration
    super.key,
  });

  @override
  State<SmokeParticleWidget> createState() => _SmokeParticleWidgetState();
}

class _SmokeParticleWidgetState extends State<SmokeParticleWidget> with SingleTickerProviderStateMixin {
  // 🔥 OPTIMIZED: Using OptimizedParticleController instead of regular AnimationController
  late OptimizedParticleController _optimizedController;
  final List<SmokeParticle> _particles = [];
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

    // Create initial particles
    for (int i = 0; i < widget.count; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      // More variation in speed, generally lower
      final speed = widget.initialSpeed * (0.2 + _random.nextDouble() * 0.8);
      final velocity = Offset(math.cos(angle), math.sin(angle)) * speed;
      // Dark grey/purple colors
      final color = Color.lerp(
          Colors.grey.shade800,
          const Color.fromARGB(255, 48, 0, 60),
          _random.nextDouble()
      )!;
      final size = 5.0 + _random.nextDouble() * 5.0; // Larger base size
      final rotation = _random.nextDouble() * 2 * math.pi;
      final rotationSpeed = (_random.nextDouble() - 0.5) * 2.0; // Random rotation speed/direction

      _particles.add(SmokeParticle(
        position: Offset.zero, // Start at the center relative to the CustomPaint
        velocity: velocity * widget.spread, // Apply spread
        color: color,
        size: size,
        rotation: rotation,
        rotationSpeed: rotationSpeed,
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
    for (int i = _particles.length - 1; i >= 0; i--) {
       final particle = _particles[i];
       if (particle.isAlive) {
         particle.update(dt);
         // Optional: Add slight upward drift
         particle.position += const Offset(0, -2.0) * dt;
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
        child: IgnorePointer( // Smoke shouldn't block interactions
          child: AnimatedBuilder(
            animation: _optimizedController.controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.zero, // Painter uses relative coordinates
                painter: SmokePainter(_particles, _optimizedController.value, DateTime.now()),
              );
            },
          ),
        ),
      ),
    );
  }
} 