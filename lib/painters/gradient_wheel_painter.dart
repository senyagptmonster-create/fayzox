import 'dart:math';
import 'package:flutter/material.dart';

class GradientWheelPainter extends CustomPainter {
  final Color baseColor;
  final double angleDegrees;

  GradientWheelPainter({required this.baseColor, required this.angleDegrees});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.44;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFEBE4F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius, bgPaint);

    // Conic gradient ring
    final hsl = HSLColor.fromColor(baseColor);
    final hues = List.generate(12, (i) {
      final hue = (hsl.hue + (i * 30)) % 360;
      return hsl.withHue(hue).toColor();
    });

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: hues,
        stops: List.generate(12, (i) => i / 11),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;

    canvas.drawCircle(center, radius, sweepPaint);

    // Inner disc showing current shade ramp
    final innerRadius = radius - 30;
    for (int step = 1; step <= 5; step++) {
      final stepLightness = (step * 0.15).clamp(0.1, 0.95);
      final stepColor = hsl.withLightness(stepLightness).toColor();
      final stepPaint = Paint()..color = stepColor;
      canvas.drawCircle(center, innerRadius * (1.0 - (step - 1) * 0.18), stepPaint);
    }

    // Indicator needle / dot along angleDegrees
    final rad = angleDegrees * pi / 180;
    final needlePoint = Offset(
      center.dx + radius * cos(rad),
      center.dy + radius * sin(rad),
    );

    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final needleStroke = Paint()
      ..color = const Color(0xFF280A3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(needlePoint, 9, needlePaint);
    canvas.drawCircle(needlePoint, 9, needleStroke);
  }

  @override
  bool shouldRepaint(covariant GradientWheelPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.angleDegrees != angleDegrees;
  }
}
