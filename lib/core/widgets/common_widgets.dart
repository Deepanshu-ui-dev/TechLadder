import 'package:flutter/material.dart';

import 'package:techladder/core/theme/color_tokens.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable flat card with border (no shadows)
class TLCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const TLCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Material(
        color: backgroundColor ?? ColorTokens.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: borderColor ?? ColorTokens.bgBorder,
            width: borderColor != null ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
    }
    
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? ColorTokens.bgSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? ColorTokens.bgBorder,
          width: borderColor != null ? 1.5 : 1,
        ),
      ),
      child: child,
    );
  }
}

/// Monospace badge chip (JetBrains Mono)
class TLBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? bg;

  const TLBadge(this.label, {super.key, this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? ColorTokens.bgElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ColorTokens.bgBorder, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: color ?? ColorTokens.textSecond,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Difficulty badge
class DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const DifficultyBadge(this.difficulty, {super.key});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = ColorTokens.accentGreen;
      case 'hard':
        color = ColorTokens.accentRed;
      default:
        color = ColorTokens.accentAmber;
    }
    return TLBadge(difficulty.toUpperCase(), color: color);
  }
}

/// Shimmer skeleton card
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ColorTokens.bgSurface,
      highlightColor: ColorTokens.bgElevated,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: ColorTokens.bgSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Error card with retry
class ErrorCard extends StatelessWidget {
  final String message;
  final bool showRetry;
  final VoidCallback? onRetry;

  const ErrorCard({
    super.key,
    required this.message,
    this.showRetry = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return TLCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: ColorTokens.accentRed, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.ibmPlexSans(
              color: ColorTokens.textSecond,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          if (showRetry && onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorTokens.accentCyan,
                side: const BorderSide(color: ColorTokens.accentCyan),
              ),
              child: Text('Retry', style: GoogleFonts.ibmPlexSans()),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated counter widget
class AnimatedCounter extends StatelessWidget {
  final int target;
  final String suffix;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.target,
    this.suffix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          '${value.round()}$suffix',
          style: style ??
              GoogleFonts.syne(
                color: ColorTokens.accentCyan,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
        );
      },
    );
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.syne(
            color: ColorTokens.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: GoogleFonts.ibmPlexSans(
                color: ColorTokens.accentCyan,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Progress ring (CustomPaint)
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;

  const ProgressRing({super.key, required this.progress, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: GoogleFonts.jetBrainsMono(
              color: ColorTokens.textPrimary,
              fontSize: size * 0.22,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;
    final bgPaint = Paint()
      ..color = ColorTokens.bgBorder
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final fgPaint = Paint()
      ..color = ColorTokens.accentGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 / 2,
      2 * 3.14159 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
