import 'package:flutter/material.dart';
import 'dart:convert';
import '../controller/dev_lens_controller.dart';

/// Floating button that opens a session summary sheet.
class DevLensSessionButton extends StatelessWidget {
  const DevLensSessionButton({super.key});

  void _openSheet(BuildContext context) {
    try {
      // Verify Navigator exists by attempting to access it
      Navigator.of(context);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const _SessionSheet(),
      );
    } catch (e) {
      debugPrint('[DevLens] Warning: Could not open bottom sheet - $e');
      // Silently fail if Navigator is not found
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 12,
      child: GestureDetector(
        onTap: () => _openSheet(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.analytics_outlined,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _SessionSheet extends StatelessWidget {
  const _SessionSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              _SheetHeader(),
              Expanded(
                child: ValueListenableBuilder<SessionSummary>(
                  valueListenable:
                      DevLensController.instance.sessionNotifier,
                  builder: (context, summary, _) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MetricsRow(summary: summary),
                          const SizedBox(height: 16),
                          _SectionTitle('Rebuild counts'),
                          _RebuildTable(),
                          const SizedBox(height: 16),
                          _SectionTitle('Recent state events'),
                          _StateEventList(),
                          const SizedBox(height: 16),
                          _ExportButton(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined,
              color: Color(0xFF5DCAA5), size: 16),
          const SizedBox(width: 8),
          const Text(
            'DevLens session report',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close,
                color: Colors.white.withOpacity(0.4), size: 18),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.summary});
  final SessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final avgFps = summary.averageFrameMs > 0 ? (1000 / summary.averageFrameMs).toStringAsFixed(0) : 'N/A';
    final performanceStatus = summary.averageFrameMs > 16 ? '⚠ Needs optimization' : '✓ Good performance';
    
    return Column(
      children: [
        Row(
          children: [
            _Metric(
                label: 'Total rebuilds',
                value: '${summary.totalRebuilds}',
                icon: Icons.refresh,
                color: const Color(0xFFAFA9EC)),
            const SizedBox(width: 10),
            _Metric(
                label: 'Avg frame',
                value: '${summary.averageFrameMs.toStringAsFixed(1)}ms',
                icon: Icons.speed,
                color: summary.averageFrameMs > 16
                    ? const Color(0xFFE24B4A)
                    : const Color(0xFF5DCAA5)),
            const SizedBox(width: 10),
            _Metric(
                label: 'FPS',
                value: '$avgFps fps',
                icon: Icons.videogame_asset,
                color: summary.averageFrameMs > 16
                    ? const Color(0xFFE24B4A)
                    : const Color(0xFF5DCAA5)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _Metric(
                label: 'Slow frames',
                value: '${summary.slowFramePercent.toStringAsFixed(0)}%',
                icon: Icons.warning_amber,
                color: summary.slowFramePercent > 10
                    ? const Color(0xFFEF9F27)
                    : const Color(0xFF5DCAA5)),
            const SizedBox(width: 10),
            _Metric(
                label: 'Hot widget',
                value: summary.hottestWidget ?? 'None',
                icon: Icons.local_fire_department,
                color: const Color(0xFFEF9F27)),
            const SizedBox(width: 10),
            _Metric(
                label: 'Status',
                value: performanceStatus,
                icon: Icons.info_outline,
                color: summary.averageFrameMs > 16
                    ? const Color(0xFFE24B4A)
                    : const Color(0xFF5DCAA5)),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 9)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RebuildTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: DevLensController.instance.rebuildNotifier,
      builder: (context, counts, _) {
        if (counts.isEmpty) {
          return _EmptyHint(
              'No rebuild data yet. Use DevLens.track() to wrap widgets.');
        }
        final sorted = counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return Column(
          children: sorted.take(10).map((e) {
            final pct = sorted.first.value > 0
                ? e.value / sorted.first.value
                : 0.0;
            return _RebuildRow(name: e.key, count: e.value, percent: pct);
          }).toList(),
        );
      },
    );
  }
}

class _RebuildRow extends StatelessWidget {
  const _RebuildRow(
      {required this.name, required this.count, required this.percent});
  final String name;
  final int count;
  final double percent;

  Color get _barColor {
    if (count > 15) return const Color(0xFFE24B4A);
    if (count > 5) return const Color(0xFFEF9F27);
    return const Color(0xFF1D9E75);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  color: _barColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(_barColor),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StateEventList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<StateChangeEvent>>(
      valueListenable: DevLensController.instance.stateNotifier,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return _EmptyHint(
              'Add DevLensStateMixin to your State classes to see events.');
        }
        return Column(
          children: events.take(8).map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5DCAA5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.widgetType,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (e.description != null)
                    Expanded(
                      child: Text(
                        e.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ExportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final data = DevLensController.instance.exportSession();
        final json = const JsonEncoder.withIndent('  ').convert(data);
        showDialog(
          context: context,
          builder: (_) => _ExportDialog(json: json),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color(0xFF534AB7).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_outlined, color: Color(0xFFAFA9EC), size: 14),
            SizedBox(width: 6),
            Text(
              'Export session JSON',
              style: TextStyle(
                color: Color(0xFFAFA9EC),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportDialog extends StatelessWidget {
  const _ExportDialog({required this.json});
  final String json;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Session JSON',
          style: TextStyle(color: Colors.white, fontSize: 14)),
      content: SingleChildScrollView(
        child: SelectableText(
          json,
          style: const TextStyle(
            color: Color(0xFF9FE1CB),
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close',
              style: TextStyle(color: Color(0xFF5DCAA5))),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
            color: Colors.white.withOpacity(0.3), fontSize: 11),
      ),
    );
  }
}
