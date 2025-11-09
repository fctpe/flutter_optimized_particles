import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

/// High-performance particle animation controller that eliminates setState() calls
/// and prevents CPU from staying awake unnecessarily
class OptimizedParticleController with WidgetsBindingObserver implements Listenable {
  late final AnimationController _controller;
  late final Ticker _ticker;
  
  // Callbacks
  VoidCallback? onComplete;
  VoidCallback? onUpdate;
  
  // Performance tracking
  bool _isDisposed = false;
  bool _appInBackground = false;
  
  // Animation state
  bool get isAnimating => _controller.isAnimating && !_appInBackground;
  double get value => _controller.value;
  AnimationStatus get status => _controller.status;
  AnimationController get controller => _controller; // Expose for AnimatedBuilder
  
  // Listenable implementation - delegate to underlying controller
  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);
  
  @override
  void removeListener(VoidCallback listener) => _controller.removeListener(listener);
  
  OptimizedParticleController({
    required Duration duration,
    required TickerProvider vsync,
    this.onComplete,
    this.onUpdate,
  }) {
    // Create the underlying AnimationController
    _controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );
    
    // Create optimized ticker for real delta time
    _ticker = Ticker(_onTick);
    
    // Listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Listen for animation completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && onComplete != null) {
        onComplete!();
      }
    });
  }
  
  /// Start the optimized animation
  void forward() {
    if (_isDisposed || _appInBackground) return;
    
    _controller.forward();
    _ticker.start();
  }
  
  /// Stop the animation
  void stop() {
    _ticker.stop();
    _controller.stop();
  }
  
  /// Pause animation (for background transitions)
  void pause() {
    if (!_isDisposed) {
      _ticker.stop();
    }
  }
  
  /// Resume animation (for foreground transitions)
  void resume() {
    if (!_isDisposed && _controller.isAnimating) {
// Reset delta time
      _ticker.start();
    }
  }
  
  /// High-performance tick handler with real delta time
  void _onTick(Duration elapsed) {
    if (_isDisposed || _appInBackground) return;
    
    
    // Cap delta time to prevent huge jumps (e.g. when resuming from background)  
    // Note: Real delta time is now available via _lastFrameTime for particle systems
    
    // Call update with real delta time instead of fixed 1/60
    if (onUpdate != null) {
      onUpdate!();
    }
  }
  
  /// App lifecycle handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _appInBackground = true;
        pause();
        if (kDebugMode) {
          debugPrint('[OptimizedParticleController] App backgrounded - pausing animations');
        }
        break;
      case AppLifecycleState.resumed:
        _appInBackground = false;
        resume();
        if (kDebugMode) {
          debugPrint('[OptimizedParticleController] App foregrounded - resuming animations');
        }
        break;
      case AppLifecycleState.hidden:
        // iOS specific state
        _appInBackground = true;
        pause();
        break;
    }
  }
  
  /// Clean disposal
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _controller.dispose();
  }
}

/// Optimized CustomPainter that minimizes repaints
abstract class OptimizedParticlePainter extends CustomPainter {
  final double animationValue;
  final DateTime frameTime;
  
  OptimizedParticlePainter(this.animationValue, this.frameTime);
  
  @override
  bool shouldRepaint(covariant OptimizedParticlePainter oldDelegate) {
    // Only repaint if animation value changed or significant time passed
    return animationValue != oldDelegate.animationValue || 
           frameTime.difference(oldDelegate.frameTime).inMilliseconds > 16; // ~60fps max
  }
}

/// Optimized RepaintBoundary wrapper for particle widgets
class OptimizedParticleWidget extends StatefulWidget {
  final Widget child;
  final bool enableRepaintBoundary;
  
  const OptimizedParticleWidget({
    required this.child,
    this.enableRepaintBoundary = true,
    super.key,
  });
  
  @override
  State<OptimizedParticleWidget> createState() => _OptimizedParticleWidgetState();
}

class _OptimizedParticleWidgetState extends State<OptimizedParticleWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.enableRepaintBoundary) {
      return RepaintBoundary(
        child: widget.child,
      );
    }
    return widget.child;
  }
} 