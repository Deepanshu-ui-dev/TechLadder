import 'package:flutter/material.dart';

/// Configuration for which DevLens panels are visible.
class DevLensConfig {
  const DevLensConfig({
    this.showRebuildBadges = true,
    this.showPerfBar = true,
    this.showStateLog = true,
    this.showTapInspector = true,
    this.showFloatingButton = true,
    this.rebuildWarningThreshold = 5,
    this.rebuildDangerThreshold = 15,
    this.perfBarPosition = Alignment.topCenter,
    this.stateLogPosition = Alignment.centerRight,
    this.maxStateLogEntries = 50,
  });

  /// Show per-widget rebuild count badges.
  final bool showRebuildBadges;

  /// Show the frame-time performance bar at the top.
  final bool showPerfBar;

  /// Show the sliding state change log panel.
  final bool showStateLog;

  /// Enable tap-to-inspect any widget.
  final bool showTapInspector;

  /// Show the floating toggle button.
  final bool showFloatingButton;

  /// Rebuild count that turns badge amber.
  final int rebuildWarningThreshold;

  /// Rebuild count that turns badge red.
  final int rebuildDangerThreshold;

  /// Where the perf bar sits on screen.
  final Alignment perfBarPosition;

  /// Where the state log panel docks.
  final Alignment stateLogPosition;

  /// Max entries kept in the state log.
  final int maxStateLogEntries;

  DevLensConfig copyWith({
    bool? showRebuildBadges,
    bool? showPerfBar,
    bool? showStateLog,
    bool? showTapInspector,
    bool? showFloatingButton,
    int? rebuildWarningThreshold,
    int? rebuildDangerThreshold,
    Alignment? perfBarPosition,
    Alignment? stateLogPosition,
    int? maxStateLogEntries,
  }) {
    return DevLensConfig(
      showRebuildBadges: showRebuildBadges ?? this.showRebuildBadges,
      showPerfBar: showPerfBar ?? this.showPerfBar,
      showStateLog: showStateLog ?? this.showStateLog,
      showTapInspector: showTapInspector ?? this.showTapInspector,
      showFloatingButton: showFloatingButton ?? this.showFloatingButton,
      rebuildWarningThreshold:
          rebuildWarningThreshold ?? this.rebuildWarningThreshold,
      rebuildDangerThreshold:
          rebuildDangerThreshold ?? this.rebuildDangerThreshold,
      perfBarPosition: perfBarPosition ?? this.perfBarPosition,
      stateLogPosition: stateLogPosition ?? this.stateLogPosition,
      maxStateLogEntries: maxStateLogEntries ?? this.maxStateLogEntries,
    );
  }
}
