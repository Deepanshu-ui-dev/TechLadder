/// dart_devlens — Live debug overlay for Flutter apps.
///
/// Usage:
/// ```dart
/// void main() {
///   runApp(DevLens.wrap(child: MyApp()));
/// }
/// ```
///
/// All panels are hidden automatically in release builds.
library dart_devlens;

export 'src/dev_lens.dart';
export 'src/controller/dev_lens_controller.dart';
export 'src/hooks/state_mixin.dart';
export 'src/overlay/dev_lens_config.dart';
