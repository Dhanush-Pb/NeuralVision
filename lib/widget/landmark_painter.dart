
import 'package:flutter/material.dart';

class LandmarkPainter extends CustomPainter {
  final List<List<double>> points;
  final bool mirror;

  LandmarkPainter({
    required this.points,
    this.mirror = false,
  });

  static const connections = [
    [0, 1], [1, 2], [2, 3], [3, 4],
    [0, 5], [5, 6], [6, 7], [7, 8],
    [0, 9], [9, 10], [10, 11], [11, 12],
    [0, 13], [13, 14], [14, 15], [15, 16],
    [0, 17], [17, 18], [18, 19], [19, 20],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length != 21) return;

    final side = size.shortestSide * 0.8;
    final left = (size.width - side) / 2;
    final top = (size.height - side) / 2;

    Offset position(int index) {
      final x = mirror ? 1 - points[index][0] : points[index][0];
      final y = points[index][1];

      return Offset(left + x * side, top + y * side);
    }

    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    for (final connection in connections) {
      canvas.drawLine(
        position(connection[0]),
        position(connection[1]),
        linePaint,
      );
    }

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(position(i), 5, pointPaint);
    }

    final boxPaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(
      Rect.fromLTWH(left, top, side, side),
      boxPaint,
    );
  }

  @override
  bool shouldRepaint(covariant LandmarkPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.mirror != mirror;
  }
}
