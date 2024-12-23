import 'package:flutter/material.dart';

import '../utils/colors.dart';

class CirclePainter extends CustomPainter {
  final double radius;
  final Color color;

  CirclePainter(this.radius, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
