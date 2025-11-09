# Flutter Optimized Particles

High-performance particle system for Flutter games with automatic battery optimization.

**Built for [Sultan's Gambit](https://sultansgambit.com)** and generalized for the Flutter community.

## Features

- ✨ **Zero `setState()` calls** - Uses custom painters and animation controllers for maximum performance
- 🔋 **Automatic battery optimization** - Auto-pauses particles when app backgrounds
- 🎯 **Production-tested** - Battle-tested in a commercial card game with complex particle effects
- 🎨 **8 pre-built effects** - Sparks, smoke, ripples, shockwaves, projectiles, and more
- 📦 **Lightweight** - No external dependencies beyond Flutter SDK
- 🎮 **Game-ready** - Designed specifically for mobile game development

## Why Use This?

Standard Flutter animations can drain battery when apps are backgrounded. This package:

1. **Eliminates wasteful `setState()` calls** during particle updates
2. **Auto-pauses all animations** when app goes to background
3. **Auto-resumes** when app returns to foreground
4. **Provides real delta time** for smooth, frame-rate independent animations

## Installation

```yaml
dependencies:
  flutter_optimized_particles: ^0.1.0
```

## Quick Start

```dart
import 'package:flutter_optimized_particles/flutter_optimized_particles.dart';

// Add spark particles at a position
Stack(
  children: [
    SparkParticleWidget(
      position: Offset(100, 100),
      onComplete: () => print('Effect finished!'),
      count: 30,
      startColor: Colors.yellow,
      endColor: Colors.orange,
    ),
  ],
)
```

## Available Effects

### Spark Particles
Explosive burst of colored sparks - perfect for hits, explosions, or celebrations.

```dart
SparkParticleWidget(
  position: tapPosition,
  count: 20,
  speed: 80.0,
  spread: 1.5,
  startColor: Colors.yellow,
  endColor: Colors.orange,
  duration: Duration(milliseconds: 600),
  onComplete: () {},
)
```

### Smoke Particles
Drifting smoke effect - great for atmospheric effects or damage indicators.

```dart
SmokeParticleWidget(
  position: damagePosition,
  count: 15,
  color: Colors.grey.withValues(alpha: 0.5),
  onComplete: () {},
)
```

### Ripple Effect
Expanding circular ripple - useful for selection indicators or area effects.

```dart
RippleEffectWidget(
  center: Offset(150, 150),
  maxRadius: 100.0,
  color: Colors.blue.withValues(alpha: 0.5),
  onComplete: () {},
)
```

### Shockwave
Powerful expanding ring - perfect for impacts or explosions.

```dart
ShockwaveWidget(
  center: explosionPosition,
  color: Colors.white,
  onComplete: () {},
)
```

### Projectile
Moving particle from source to target - ideal for attack animations.

```dart
ProjectileWidget(
  start: attackerPosition,
  end: targetPosition,
  color: Colors.red,
  size: 8.0,
  onComplete: () {},
)
```

### Pulse Glow
Pulsating glow effect - great for highlighting or status indicators.

```dart
PulseGlowWidget(
  position: cardPosition,
  size: Size(100, 150),
  color: Colors.cyan,
  pulseCount: 3,
  onComplete: () {},
)
```

### Impact Flash
Brief flash of light - perfect for hit confirmation.

```dart
ImpactFlashWidget(
  position: hitPosition,
  color: Colors.white,
  onComplete: () {},
)
```

### Floating Feedback
Floating text/number feedback - ideal for damage numbers or score popups.

```dart
FloatingFeedbackWidget(
  position: feedbackPosition,
  text: '+10',
  textColor: Colors.green,
  fontSize: 24,
  onComplete: () {},
)
```

## Advanced Usage

### Custom Particle Controller

For custom effects, use `OptimizedParticleController` directly:

```dart
class _MyParticleState extends State<MyParticle>
    with SingleTickerProviderStateMixin {
  late OptimizedParticleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OptimizedParticleController(
      duration: Duration(seconds: 1),
      vsync: this,
      onUpdate: () {
        // Update particle positions (no setState needed!)
      },
      onComplete: () {
        // Cleanup when done
      },
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Animation Lifecycle Mixin

For widgets with multiple animations that need lifecycle management:

```dart
class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
    with TickerProviderStateMixin, AnimationLifecycleMixin {

  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    initializeAnimationLifecycle(); // Important!

    _controller1 = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller2 = AnimationController(vsync: this, duration: Duration(seconds: 2));

    // Animations will auto-pause when app backgrounds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (shouldAnimate) {
        startManagedAnimations();
      }
    });
  }

  @override
  void startManagedAnimations() {
    if (!mounted || !shouldAnimate) return;
    _controller1.repeat();
    _controller2.repeat();
  }

  @override
  void pauseManagedAnimations() {
    _controller1.stop();
    _controller2.stop();
  }

  @override
  void stopManagedAnimations() {
    _controller1.stop();
    _controller2.stop();
  }

  @override
  void dispose() {
    disposeManagedAnimations(); // Important!
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
}
```

## Performance Comparison

Traditional approach with `setState()`:
```dart
// ❌ Rebuilds entire widget tree every frame
void _updateParticles() {
  for (var particle in particles) {
    particle.update();
  }
  setState(() {}); // Expensive!
}
```

Optimized approach:
```dart
// ✅ Only repaints the CustomPainter
OptimizedParticleController(
  onUpdate: () {
    for (var particle in particles) {
      particle.update();
    }
    // No setState - CustomPainter handles it!
  },
)
```

## Credits

Built for **[Sultan's Gambit](https://sultansgambit.com)** - A strategic Ottoman-themed card game.

Open sourced to help the Flutter game development community build better, more battery-efficient games.

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions welcome! Please open an issue or PR on [GitHub](https://github.com/yourusername/flutter_optimized_particles).

---

**Made with ❤️ for Flutter game developers**
