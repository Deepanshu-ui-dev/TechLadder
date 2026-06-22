import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'controller/dev_lens_controller.dart';
import 'hooks/state_mixin.dart';
import 'overlay/dev_lens_config.dart';
import 'overlay/perf_bar.dart';
import 'overlay/rebuild_badge.dart';
import 'overlay/state_log_panel.dart';
import 'overlay/tap_inspector.dart';
import 'overlay/session_panel.dart';

/// The main entry point for dart_devlens.
///
/// ## Quick start
///
/// ```dart
/// void main() {
///   runApp(DevLens.wrap(child: MyApp()));
/// }
/// ```
///
/// ## Track specific widgets
///
/// ```dart
/// DevLens.track(child: MyExpensiveWidget(), name: 'MyExpensiveWidget')
/// ```
///
/// ## Track state changes
///
/// ```dart
/// class _MyState extends State<MyWidget> with DevLensStateMixin {
///   // setState() is now automatically tracked
/// }
/// ```
abstract class DevLens {
  /// Wraps [child] in the full DevLens overlay stack.
  ///
  /// - In **debug** mode: all panels are active.
  /// - In **release** mode: returns [child] unchanged — zero overhead.
  static Widget wrap({
    required Widget child,
    DevLensConfig config = const DevLensConfig(),
  }) {
    if (!kDebugMode) return child;

    DevLensController.instance.activate(
      maxLogEntries: config.maxStateLogEntries,
    );

    return _DevLensWrapper(config: config, child: child);
  }

  /// Wraps [child] in a rebuild tracker with an optional badge.
  ///
  /// ```dart
  /// DevLens.track(
  ///   name: 'ProductCard',
  ///   child: ProductCard(product: product),
  /// )
  /// ```
  static Widget track({
    required Widget child,
    required String name,
    DevLensConfig config = const DevLensConfig(),
  }) {
    if (!kDebugMode) return child;
    return DevLensRebuildTracker(
      trackedName: name,
      child: config.showRebuildBadges
          ? RebuildBadge(
              widgetName: name,
              config: config,
              child: child,
            )
          : child,
    );
  }

  /// Convenience: record a manual state event (e.g. from providers/blocs).
  static void logState(String widgetType, {String? description}) {
    if (!kDebugMode) return;
    DevLensController.instance.recordStateChange(
      widgetType,
      description: description,
    );
  }

  /// Resets all counters for the current session.
  static void reset() {
    if (!kDebugMode) return;
    DevLensController.instance.reset();
  }

  /// Export the current session as a JSON map.
  static Map<String, dynamic> exportSession() {
    return DevLensController.instance.exportSession();
  }
}

// ── Internal overlay widget ──────────────────────────────────────────────────

class _DevLensWrapper extends StatefulWidget {
  const _DevLensWrapper({required this.child, required this.config});
  final Widget child;
  final DevLensConfig config;

  @override
  State<_DevLensWrapper> createState() => _DevLensWrapperState();
}

class _DevLensWrapperState extends State<_DevLensWrapper> {
  bool _overlayVisible = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Localizations(
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        locale: Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'),
        child: Stack(
          children: [
            // ① The actual app (with all its Material/Navigator context)
            widget.config.showTapInspector
                ? TapInspectorLayer(child: widget.child)
                : widget.child,

            // ② All overlays (hidden when user toggles off)
            // These are positioned on top and can access the app's context below
            if (_overlayVisible) ...[
              if (widget.config.showPerfBar) const DevLensPerfBar(),
              if (widget.config.showStateLog) const DevLensStateLog(),
              if (widget.config.showFloatingButton)
                _OverlayContextBridge(
                  child: DevLensSessionButton(),
                ),
            ],

            // ③ Master toggle (always visible so user can restore)
            if (widget.config.showFloatingButton)
              _MasterToggle(
                visible: _overlayVisible,
                onToggle: () => setState(() => _overlayVisible = !_overlayVisible),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bridge widget that provides proper Material context to overlay widgets
/// by having them find the Navigator from the widget tree below
class _OverlayContextBridge extends StatelessWidget {
  const _OverlayContextBridge({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // By returning child here, we ensure it searches the tree for Navigator/Localizations
    // which will be found in the app hierarchy below in the Stack
    return child;
  }
}

class _MasterToggle extends StatelessWidget {
  const _MasterToggle({required this.visible, required this.onToggle});
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: visible
                ? const Color(0xFF534AB7).withOpacity(0.85)
                : Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white.withOpacity(visible ? 1 : 0.5),
            size: 15,
          ),
        ),
      ),
    );
  }
}
