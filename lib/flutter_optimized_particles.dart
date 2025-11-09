/// High-performance particle system for Flutter with battery optimization
///
/// Built for Sultan's Gambit and generalized for the Flutter community.
/// This library provides optimized particle controllers and pre-built effects
/// that eliminate setState() calls and auto-pause when the app backgrounds.
library flutter_optimized_particles;

// Controllers
export 'src/controllers/optimized_particle_controller.dart';

// Mixins
export 'src/mixins/animation_lifecycle_mixin.dart';

// Particle Widgets
export 'src/widgets/spark_particle_widget.dart';
export 'src/widgets/smoke_particle_widget.dart';
export 'src/widgets/ripple_effect_widget.dart';
export 'src/widgets/shockwave_widget.dart';
export 'src/widgets/projectile_widget.dart';
export 'src/widgets/pulse_glow_widget.dart';
export 'src/widgets/impact_flash_widget.dart';
export 'src/widgets/floating_feedback_widget.dart';
