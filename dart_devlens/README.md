# dart_devlens

A live debug overlay for Flutter apps. Shows widget rebuild counts, frame performance, state change logs, and a tap inspector — all floating on top of your running app. Zero config, zero production overhead.

---

## Quick start

```dart
void main() {
  runApp(
    DevLens.wrap(child: MyApp()),
  );
}
```

That's it. In release builds, `DevLens.wrap()` is a no-op — no code ships to production.

---

## Features

| Feature | What it does |
|---|---|
| **Perf bar** | Slim top bar showing current frame time. Green / amber / red. |
| **State log** | Slide-in panel with live setState event feed. |
| **Tap inspector** | Tap any widget to see its type, rebuild count, and position. |
| **Session report** | Bottom sheet with rebuild rankings and avg frame time. |
| **Export** | Dumps session data as JSON for sharing with teammates. |

---

## Track widget rebuilds

Wrap any widget with `DevLens.track()` to see a rebuild count badge on it:

```dart
DevLens.track(
  name: 'ProductCard',
  child: ProductCard(product: product),
)
```

---

## Track state changes

Add `DevLensStateMixin` to your `State<T>` class. Every `setState()` call is automatically recorded:

```dart
class _CounterState extends State<Counter> with DevLensStateMixin {
  int _count = 0;

  void _increment() {
    // Use setStateTracked for a description, or plain setState — both work
    setStateTracked(() => _count++, description: 'incremented');
  }
}
```

---

## Log state from providers / blocs

Works with any state manager:

```dart
// Riverpod, Bloc, Provider — anywhere
DevLens.logState('CartBloc', description: 'item added to cart');
```

---

## Configuration

```dart
DevLens.wrap(
  config: DevLensConfig(
    showRebuildBadges: true,
    showPerfBar: true,
    showStateLog: true,
    showTapInspector: true,
    rebuildWarningThreshold: 5,   // amber at 5+ rebuilds
    rebuildDangerThreshold: 15,   // red at 15+ rebuilds
    maxStateLogEntries: 50,
  ),
  child: MyApp(),
)
```

---

## Overlay controls

| Control | Location | Action |
|---|---|---|
| Circle icon | Top-left | Toggle all overlays on/off |
| STATE tab | Right edge | Slide out the state log |
| Purple circle | Bottom-right | Toggle tap-inspector mode |
| Gear icon | Bottom-right | Open session summary sheet |

---

## Export session data

```dart
final json = DevLens.exportSession();
// Contains: rebuild_counts, state_events, frame_samples, summary
```

Or tap the gear icon in your app → "Export session JSON" to copy it.

---

## Reset counters

```dart
DevLens.reset(); // Clears all rebuild counts and state events
```

---

## Package structure

```
lib/
├── dart_devlens.dart              ← public API barrel
└── src/
    ├── dev_lens.dart              ← DevLens.wrap() / .track() / .logState()
    ├── controller/
    │   └── dev_lens_controller.dart   ← singleton, all metrics
    ├── hooks/
    │   └── state_mixin.dart           ← DevLensStateMixin + RebuildTracker
    └── overlay/
        ├── dev_lens_config.dart       ← DevLensConfig
        ├── perf_bar.dart              ← frame time indicator
        ├── rebuild_badge.dart         ← per-widget rebuild counter
        ├── state_log_panel.dart       ← sliding state event feed
        ├── tap_inspector.dart         ← tap-to-inspect layer
        └── session_panel.dart         ← bottom sheet summary + export
```
