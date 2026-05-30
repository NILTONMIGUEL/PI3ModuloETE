import 'package:flutter/material.dart';

class NeonBorderPainter extends CustomPainter {
  final double progress;

  NeonBorderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(6), const Radius.circular(10)),
      );

    // brilho externo
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = Colors.cyanAccent;

    canvas.drawPath(path, glowPaint);

    // neon animado
    final animatedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 6.28,
        transform: GradientRotation(progress * 6.28),
        colors: const [
          Color.fromARGB(239, 241, 2, 201),
          Color.fromARGB(255, 228, 5, 153),
          Color.fromARGB(255, 218, 4, 4),
          Color.fromARGB(255, 240, 77, 2),
          Color.fromARGB(230, 90, 218, 4),
        ],
        stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawPath(path, animatedPaint);
  }

  @override
  bool shouldRepaint(covariant NeonBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
