import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../controller/dev_lens_controller.dart';

/// Wraps the app in a gesture detector that shows widget info on tap
/// when tap-inspector mode is active.
class TapInspectorLayer extends StatefulWidget {
  const TapInspectorLayer({super.key, required this.child});
  final Widget child;

  @override
  State<TapInspectorLayer> createState() => _TapInspectorLayerState();
}

class _TapInspectorLayerState extends State<TapInspectorLayer> {
  _InspectInfo? _info;
  Offset? _tapPosition;
  bool _inspectMode = false;

  void _onTap(TapUpDetails details) {
    if (!_inspectMode) return;
    final position = details.globalPosition;
    final result = BoxHitTestResult();
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    // Walk the element tree near the tap point
    final element = _findElement(context, position);
    if (element == null) return;

    setState(() {
      _tapPosition = position;
      _info = _InspectInfo(
        widgetType: element.widget.runtimeType.toString(),
        elementType: element.runtimeType.toString(),
        rebuildCount: DevLensController.instance.rebuildCounts[
                element.widget.runtimeType.toString()] ??
            0,
        position: position,
        hashCode: element.hashCode,
      );
    });
  }

  Element? _findElement(BuildContext context, Offset position) {
    Element? result;
    void visitor(Element element) {
      final renderObj = element.renderObject;
      if (renderObj is RenderBox && renderObj.attached) {
        try {
          final localPos = renderObj.globalToLocal(position);
          if (renderObj.size.contains(localPos)) {
            result = element;
          }
        } catch (_) {}
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          GestureDetector(
            onTapUp: _inspectMode ? _onTap : null,
            behavior: HitTestBehavior.translucent,
            child: widget.child,
          ),
          // Inspect mode toggle button
          Positioned(
            bottom: 80,
            right: 12,
            child: _InspectToggleButton(
              active: _inspectMode,
              onToggle: () {
                setState(() {
                  _inspectMode = !_inspectMode;
                  if (!_inspectMode) _info = null;
                });
              },
            ),
          ),
          // Info card
          if (_info != null && _tapPosition != null)
            _InfoCard(
              info: _info!,
              position: _tapPosition!,
              onDismiss: () => setState(() {
                _info = null;
                _tapPosition = null;
              }),
            ),
          // Inspect mode indicator
          if (_inspectMode)
            Positioned(
              bottom: 130,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF534AB7).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Tap any widget',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InspectToggleButton extends StatelessWidget {
  const _InspectToggleButton({
    required this.active,
    required this.onToggle,
  });
  final bool active;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF534AB7)
              : Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.center_focus_strong,
          color: Colors.white.withOpacity(active ? 1.0 : 0.7),
          size: 18,
        ),
      ),
    );
  }
}

class _InspectInfo {
  const _InspectInfo({
    required this.widgetType,
    required this.elementType,
    required this.rebuildCount,
    required this.position,
    required this.hashCode,
  });
  final String widgetType;
  final String elementType;
  final int rebuildCount;
  final Offset position;
  final int hashCode;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.info,
    required this.position,
    required this.onDismiss,
  });
  final _InspectInfo info;
  final Offset position;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Position card above the tap or below depending on available space
    final showAbove = position.dy > screenSize.height / 2;
    final cardTop = showAbove ? position.dy - 160.0 : position.dy + 20.0;
    final cardLeft = (position.dx - 110).clamp(8.0, screenSize.width - 228.0);

    return Positioned(
      top: cardTop,
      left: cardLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF534AB7).withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.widgets_outlined,
                      color: Color(0xFFAFA9EC), size: 13),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      info.widgetType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Icon(Icons.close,
                        color: Colors.white.withOpacity(0.4), size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Row(label: 'Element', value: info.elementType),
              _Row(
                  label: 'Rebuilds',
                  value: '${info.rebuildCount}',
                  valueColor: _rebuildColor(info.rebuildCount)),
              _Row(label: 'Hash', value: '#${info.hashCode}'),
              _Row(
                  label: 'Position',
                  value:
                      '(${position.dx.toInt()}, ${position.dy.toInt()})'),
            ],
          ),
        ),
      ),
    );
  }

  Color _rebuildColor(int count) {
    if (count > 15) return const Color(0xFFE24B4A);
    if (count > 5) return const Color(0xFFEF9F27);
    return const Color(0xFF5DCAA5);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
