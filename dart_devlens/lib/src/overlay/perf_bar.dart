import 'package:flutter/material.dart';
import '../controller/dev_lens_controller.dart';

/// Slim bar at the top showing real-time frame metrics and FPS.
/// Displays: Current frame time, FPS, Build/Raster split
/// Green = smooth (60fps), Amber = warning (30-60fps), Red = janky (<30fps).
class DevLensPerfBar extends StatelessWidget {
  const DevLensPerfBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FrameSample?>(
      valueListenable: DevLensController.instance.frameNotifier,
      builder: (context, frame, _) {
        if (frame == null) return const SizedBox.shrink();
        return _PerfBarPainter(frame: frame);
      },
    );
  }
}

class _PerfBarPainter extends StatelessWidget {
  const _PerfBarPainter({required this.frame});
  final FrameSample frame;

  Color get _barColor {
    final fps = 1000 / frame.totalMs;
    if (fps < 30) return const Color(0xFFE24B4A); // Red - very slow
    if (fps < 50) return const Color(0xFFEF9F27); // Amber - warning
    return const Color(0xFF1D9E75); // Green - smooth
  }

  String get _fpsLabel {
    final fps = (1000 / frame.totalMs).toStringAsFixed(0);
    return '$fps fps';
  }

  String get _timeLabel {
    final ms = frame.totalMs.toStringAsFixed(1);
    return '${ms}ms';
  }

  String get _statusLabel {
    final fps = 1000 / frame.totalMs;
    if (fps < 30) return '⚠ JANK';
    if (fps < 50) return '⚡ SLOW';
    return '✓ SMOOTH';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          height: 26,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _barColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10),
              // Status indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _barColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _barColor.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Frame time display
              Text(
                _timeLabel,
                style: TextStyle(
                  color: _barColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6),
              // FPS indicator
              Text(
                _fpsLabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6),
              // Status label
              Text(
                _statusLabel,
                style: TextStyle(
                  color: _barColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
