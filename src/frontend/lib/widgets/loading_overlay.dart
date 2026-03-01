import 'package:flutter/material.dart';
import 'package:bouh/theme/base_themes/colors.dart';

/// Full-screen circular loading overlay using the app's three primary colors.
/// Use in any loading context (login, API calls, etc.) like normal applications.
class BouhLoadingOverlay extends StatefulWidget {
  const BouhLoadingOverlay({
    super.key,
    this.barrierColor,
    this.size = 56,
  });

  final Color? barrierColor;
  final double size;

  @override
  State<BouhLoadingOverlay> createState() => _BouhLoadingOverlayState();
}

class _BouhLoadingOverlayState extends State<BouhLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: barrierColor,
      child: Center(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _CircularGradientProgressPainter(
                  progress: _controller.value,
                  colors: const [
                    BColors.primary,
                    BColors.accent,
                    BColors.secondary,
                    BColors.primary,
                  ],
                  strokeWidth: 3,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color get barrierColor =>
      widget.barrierColor ?? Colors.black.withOpacity(0.35);
}

class _CircularGradientProgressPainter extends CustomPainter {
  _CircularGradientProgressPainter({
    required this.progress,
    required this.colors,
    this.strokeWidth = 3,
  });

  final double progress;
  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - strokeWidth;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * 3.14159265359,
      colors: colors,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const sweepLength = 0.25;
    final startAngle = progress * 2 * 3.14159265359;
    final sweepAngle = sweepLength * 2 * 3.14159265359;
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularGradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
