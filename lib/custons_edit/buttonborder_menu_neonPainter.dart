import 'dart:math';
import 'package:flutter/material.dart';

class ButtonNeonBorderPainter extends CustomPainter {
  final double progress;

  ButtonNeonBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        transform: GradientRotation(progress * 2 * pi),
        colors: const [
          Color.fromARGB(248, 70, 69, 69),
          Color.fromARGB(234, 231, 87, 3),
          Color.fromARGB(255, 255, 254, 253),
          Color.fromARGB(255, 218, 218, 218),
          Color.fromARGB(255, 233, 76, 4),
          Color.fromARGB(255, 68, 67, 67),
        ],
        stops: const [
          0.0,
          0.40,
          0.48,
          0.50,
          0.52,
          1.0,
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(1),
        const Radius.circular(16),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ButtonNeonBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}