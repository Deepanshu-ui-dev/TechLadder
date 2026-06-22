import 'package:flutter/material.dart';
import '../controller/dev_lens_controller.dart';
import '../overlay/dev_lens_config.dart';

/// Wraps [child] and shows a floating badge with rebuild count.
///
/// Use [DevLens.track] to wrap specific widgets, or let the
/// automatic instrumentation handle it.
class RebuildBadge extends StatelessWidget {
  const RebuildBadge({
    super.key,
    required this.child,
    required this.widgetName,
    required this.config,
  });

  final Widget child;
  final String widgetName;
  final DevLensConfig config;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: DevLensController.instance.rebuildNotifier,
      builder: (context, counts, _) {
        final count = counts[widgetName] ?? 0;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              child,
              if (count > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _Badge(
                    count: count,
                    config: config,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.config});
  final int count;
  final DevLensConfig config;

  Color get _color {
    if (count >= config.rebuildDangerThreshold) {
      return const Color(0xFFE24B4A);
    }
    if (count >= config.rebuildWarningThreshold) {
      return const Color(0xFFEF9F27);
    }
    return const Color(0xFF1D9E75);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
