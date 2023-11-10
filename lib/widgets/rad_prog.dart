import 'dart:math';
import 'package:flutter/material.dart';

class RadialProgress extends StatelessWidget {
  final double progress;
  final Color progressColor;
  final double strokeWidth;
  final Color backgroundColor;

  const RadialProgress({
    super.key,
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadialProgressPainter(
        progress: progress,
        progressColor: progressColor,
        strokeWidth: strokeWidth,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;
  final Color backgroundColor;

  RadialProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(RadialProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        progressColor != oldDelegate.progressColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
