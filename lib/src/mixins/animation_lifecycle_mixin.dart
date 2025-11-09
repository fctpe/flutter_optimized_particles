import 'package:flutter/material.dart';

/// A mixin that provides standardized animation lifecycle management for battery optimization.
/// 
/// This mixin automatically pauses animations when the app is backgrounded and resumes them
/// when the app becomes active again, preventing unnecessary battery drain.
/// 
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> 
///     with TickerProviderStateMixin, AnimationLifecycleMixin {
///   
///   late AnimationController _controller;
///   
///   @override
///   void initState() {
///     super.initState();
///     initializeAnimationLifecycle(); // Call this in initState
///     
///     _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
///     
///     // Start animations after frame callback
///     WidgetsBinding.instance.addPostFrameCallback((_) {
///       if (shouldAnimate) {
///         startManagedAnimations();
///       }
///     });
///   }
///   
///   @override
///   void startManagedAnimations() {
///     if (!mounted || !shouldAnimate) return;
///     _controller.repeat(reverse: true);
///   }
///   
///   @override
///   void pauseManagedAnimations() {
///     if (_controller.isAnimating) _controller.stop();
///   }
///   
///   @override
///   void stopManagedAnimations() {
///     _controller.stop();
///   }
///   
///   @override
///   void dispose() {
///     disposeManagedAnimations();
///     _controller.dispose();
///     super.dispose();
///   }
/// }
/// ```
mixin AnimationLifecycleMixin<T extends StatefulWidget> 
    on State<T>, TickerProviderStateMixin<T> 
    implements WidgetsBindingObserver {
  
  /// Whether animations should currently be running
  bool _shouldAnimate = true;
  bool get shouldAnimate => _shouldAnimate;
  
  /// Initialize the animation lifecycle management.
  /// Call this in your widget's initState() method.
  void initializeAnimationLifecycle() {
    WidgetsBinding.instance.addObserver(this);
  }
  
  /// Clean up the animation lifecycle management.
  /// Call this in your widget's dispose() method before calling super.dispose().
  void disposeManagedAnimations() {
    WidgetsBinding.instance.removeObserver(this);
    _shouldAnimate = false;
    stopManagedAnimations();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pauseAnimations();
        break;
      case AppLifecycleState.resumed:
        _resumeAnimations();
        break;
    }
  }
  
  void _pauseAnimations() {
    pauseManagedAnimations();
  }
  
  void _resumeAnimations() {
    if (_shouldAnimate) {
      startManagedAnimations();
    }
  }
  
  /// Override this method to start your animations.
  /// This will be called when the app is resumed or when animations should begin.
  void startManagedAnimations();
  
  /// Override this method to pause your animations.
  /// This will be called when the app is backgrounded.
  void pauseManagedAnimations();
  
  /// Override this method to completely stop your animations.
  /// This will be called during disposal.
  void stopManagedAnimations();
  
  /// Safely start animations with lifecycle checks.
  /// Use this helper method to start individual animation controllers.
  void startAnimationController(AnimationController controller, {bool reverse = false}) {
    if (!mounted || !_shouldAnimate) return;
    
    if (!controller.isAnimating) {
      if (reverse) {
        controller.repeat(reverse: true);
      } else {
        controller.repeat();
      }
    }
  }
  
  /// Safely stop an animation controller.
  /// Use this helper method to stop individual animation controllers.
  void stopAnimationController(AnimationController controller) {
    if (controller.isAnimating) {
      controller.stop();
    }
  }
  
  /// Permanently disable animations (useful for disposal or when animations should stop permanently).
  void disableAnimations() {
    _shouldAnimate = false;
    stopManagedAnimations();
  }
}