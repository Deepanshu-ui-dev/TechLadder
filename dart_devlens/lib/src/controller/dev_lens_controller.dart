import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A single rebuild event recorded by the controller.
class RebuildRecord {
  RebuildRecord({
    required this.widgetType,
    required this.timestamp,
    required this.totalCount,
  });

  final String widgetType;
  final DateTime timestamp;
  final int totalCount;
}

/// A state change event recorded from DevLensStateMixin.
class StateChangeEvent {
  StateChangeEvent({
    required this.widgetType,
    required this.timestamp,
    this.description,
  });

  final String widgetType;
  final DateTime timestamp;
  final String? description;
}

/// Frame timing sample.
class FrameSample {
  FrameSample({required this.buildMs, required this.rasterMs});
  final double buildMs;
  final double rasterMs;
  double get totalMs => buildMs + rasterMs;
  bool get isSlow => totalMs > 16.67;
  bool get isVerySlow => totalMs > 33.33;
}

/// Central controller — singleton, only active in debug mode.
///
/// Collect data via [recordRebuild] and [recordStateChange].
/// Listen to [rebuildStream], [stateStream], and [frameStream] for updates.
class DevLensController with WidgetsBindingObserver {
  DevLensController._();

  static final DevLensController instance = DevLensController._();

  // ── Internal state ──────────────────────────────────────────────────────────

  final Map<String, int> _rebuildCounts = {};
  final List<StateChangeEvent> _stateLog = [];
  final List<FrameSample> _frameSamples = [];
  int _maxLogEntries = 50;

  bool _active = false;
  bool get isActive => _active;

  // Performance throttling
  int _frameUpdateCounter = 0;
  static const int _frameUpdateInterval = 30; // Update UI every 30 frames
  int _rebuildUpdateCounter = 0;
  static const int _rebuildUpdateInterval = 10; // Update UI every 10 rebuilds

  // ── Public streams ──────────────────────────────────────────────────────────

  final _rebuildNotifier = ValueNotifier<Map<String, int>>({});
  final _stateNotifier = ValueNotifier<List<StateChangeEvent>>([]);
  final _frameNotifier = ValueNotifier<FrameSample?>(null);
  final _sessionNotifier = ValueNotifier<SessionSummary>(SessionSummary.empty);

  ValueListenable<Map<String, int>> get rebuildNotifier => _rebuildNotifier;
  ValueListenable<List<StateChangeEvent>> get stateNotifier => _stateNotifier;
  ValueListenable<FrameSample?> get frameNotifier => _frameNotifier;
  ValueListenable<SessionSummary> get sessionNotifier => _sessionNotifier;

  // Read-only snapshots
  UnmodifiableMapView<String, int> get rebuildCounts =>
      UnmodifiableMapView(_rebuildCounts);
  List<StateChangeEvent> get stateLog => List.unmodifiable(_stateLog);
  FrameSample? get latestFrame =>
      _frameSamples.isEmpty ? null : _frameSamples.last;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  void activate({int maxLogEntries = 50}) {
    if (!kDebugMode) return;
    if (_active) return;
    _active = true;
    _maxLogEntries = maxLogEntries;
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
    debugPrint('[DevLens] activated');
  }

  void deactivate() {
    if (!_active) return;
    _active = false;
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[DevLens] deactivated');
  }

  void reset() {
    _rebuildCounts.clear();
    _stateLog.clear();
    _frameSamples.clear();
    _rebuildUpdateCounter = 0;
    _frameUpdateCounter = 0;
    _notify();
    debugPrint('[DevLens] session reset');
  }

  // ── Data recording ───────────────────────────────────────────────────────────

  /// Called by the DevLensRebuildTracker widget mixin.
  void recordRebuild(String widgetType) {
    if (!_active) return;
    _rebuildCounts[widgetType] = (_rebuildCounts[widgetType] ?? 0) + 1;
    
    // Throttle UI updates to avoid excessive rebuilds
    _rebuildUpdateCounter++;
    if (_rebuildUpdateCounter >= _rebuildUpdateInterval) {
      _rebuildNotifier.value = Map.unmodifiable(_rebuildCounts);
      _updateSession();
      _rebuildUpdateCounter = 0;
    }
  }

  /// Called by DevLensStateMixin on setState.
  void recordStateChange(String widgetType, {String? description}) {
    if (!_active) return;
    final event = StateChangeEvent(
      widgetType: widgetType,
      timestamp: DateTime.now(),
      description: description,
    );
    _stateLog.insert(0, event);
    if (_stateLog.length > _maxLogEntries) {
      _stateLog.removeLast();
    }
    _stateNotifier.value = List.unmodifiable(_stateLog);
  }

  // ── Frame timing ─────────────────────────────────────────────────────────────

  Duration? _lastFrameTime;

  void _onFrame(Duration timestamp) {
    if (!_active) return;
    if (_lastFrameTime != null) {
      final elapsed =
          (timestamp - _lastFrameTime!).inMicroseconds / 1000.0;
      // Approximate build vs raster split (60/40 heuristic when not profiling)
      final sample = FrameSample(
        buildMs: elapsed * 0.6,
        rasterMs: elapsed * 0.4,
      );
      _frameSamples.add(sample);
      if (_frameSamples.length > 120) _frameSamples.removeAt(0);
      
      // Throttle UI updates to avoid excessive rebuilds
      _frameUpdateCounter++;
      if (_frameUpdateCounter >= _frameUpdateInterval) {
        _frameNotifier.value = sample;
        _updateSession();
        _frameUpdateCounter = 0;
      }
    }
    _lastFrameTime = timestamp;
  }

  // ── Session summary ──────────────────────────────────────────────────────────

  void _updateSession() {
    if (_frameSamples.isEmpty) return;
    final totalRebuilds =
        _rebuildCounts.values.fold(0, (a, b) => a + b);
    final avgFrame = _frameSamples.isEmpty
        ? 0.0
        : _frameSamples.map((f) => f.totalMs).reduce((a, b) => a + b) /
            _frameSamples.length;
    final slowFrames =
        _frameSamples.where((f) => f.isSlow).length;
    final hottestWidget = _rebuildCounts.isEmpty
        ? null
        : _rebuildCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    _sessionNotifier.value = SessionSummary(
      totalRebuilds: totalRebuilds,
      averageFrameMs: avgFrame,
      slowFrameCount: slowFrames,
      totalFrames: _frameSamples.length,
      hottestWidget: hottestWidget,
      uniqueWidgetTypes: _rebuildCounts.length,
    );
  }

  void _notify() {
    _rebuildNotifier.value = Map.unmodifiable(_rebuildCounts);
    _stateNotifier.value = List.unmodifiable(_stateLog);
    _frameNotifier.value = null;
  }

  // ── Export ────────────────────────────────────────────────────────────────────

  Map<String, dynamic> exportSession() {
    return {
      'exported_at': DateTime.now().toIso8601String(),
      'rebuild_counts': Map<String, int>.from(_rebuildCounts),
      'state_events': _stateLog
          .map((e) => {
                'widget': e.widgetType,
                'time': e.timestamp.toIso8601String(),
                'description': e.description,
              })
          .toList(),
      'frame_samples': _frameSamples
          .map((f) => {
                'build_ms': f.buildMs,
                'raster_ms': f.rasterMs,
                'total_ms': f.totalMs,
                'slow': f.isSlow,
              })
          .toList(),
      'summary': {
        'total_rebuilds': _sessionNotifier.value.totalRebuilds,
        'average_frame_ms': _sessionNotifier.value.averageFrameMs,
        'slow_frames': _sessionNotifier.value.slowFrameCount,
        'hottest_widget': _sessionNotifier.value.hottestWidget,
      },
    };
  }
}

/// Snapshot of the session metrics.
class SessionSummary {
  const SessionSummary({
    required this.totalRebuilds,
    required this.averageFrameMs,
    required this.slowFrameCount,
    required this.totalFrames,
    required this.hottestWidget,
    required this.uniqueWidgetTypes,
  });

  static const empty = SessionSummary(
    totalRebuilds: 0,
    averageFrameMs: 0,
    slowFrameCount: 0,
    totalFrames: 0,
    hottestWidget: null,
    uniqueWidgetTypes: 0,
  );

  final int totalRebuilds;
  final double averageFrameMs;
  final int slowFrameCount;
  final int totalFrames;
  final String? hottestWidget;
  final int uniqueWidgetTypes;

  double get slowFramePercent =>
      totalFrames == 0 ? 0 : (slowFrameCount / totalFrames) * 100;
}
