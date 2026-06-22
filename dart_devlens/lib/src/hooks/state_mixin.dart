import 'package:flutter/widgets.dart';
import '../controller/dev_lens_controller.dart';

/// Add this mixin to any [State] class to automatically report
/// [setState] calls to [DevLensController].
///
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with DevLensStateMixin {
///   void _increment() {
///     setStateTracked(() {
///       _counter++;
///     }, description: 'counter incremented');
///   }
/// }
/// ```
mixin DevLensStateMixin<T extends StatefulWidget> on State<T> {
  /// Drop-in replacement for [setState] that also records the event.
  void setStateTracked(VoidCallback fn, {String? description}) {
    DevLensController.instance.recordStateChange(
      widget.runtimeType.toString(),
      description: description,
    );
    // ignore: invalid_use_of_protected_member
    setState(fn);
  }

  @override
  void setState(VoidCallback fn) {
    DevLensController.instance.recordStateChange(
      widget.runtimeType.toString(),
    );
    super.setState(fn);
  }
}

/// Tracks rebuilds of a widget by wrapping it in a [StatefulWidget]
/// that notifies the controller each time [build] runs.
///
/// Used internally by [DevLens.track].
class DevLensRebuildTracker extends StatefulWidget {
  const DevLensRebuildTracker({
    super.key,
    required this.child,
    required this.trackedName,
  });

  final Widget child;
  final String trackedName;

  @override
  State<DevLensRebuildTracker> createState() => _DevLensRebuildTrackerState();
}

class _DevLensRebuildTrackerState extends State<DevLensRebuildTracker> {
  @override
  Widget build(BuildContext context) {
    DevLensController.instance.recordRebuild(widget.trackedName);
    return widget.child;
  }
}
