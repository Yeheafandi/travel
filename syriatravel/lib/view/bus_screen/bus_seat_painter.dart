import 'package:flutter/material.dart';

class RealisticSeatPainter extends CustomPainter {
  final Color baseColor;
  final bool isSelected;

  RealisticSeatPainter({required this.baseColor, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect shadowRect = RRect.fromLTRBR(
      2,
      size.height * 0.28,
      size.width - 2,
      size.height + 2,
      const Radius.circular(10),
    );
    canvas.drawRRect(
      shadowRect,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSelected
            ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)] 
            : [Colors.white, Colors.grey.shade100], 
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final RRect seatBody = RRect.fromLTRBR(
      0,
      size.height * 0.25,
      size.width,
      size.height,
      const Radius.circular(10),
    );
    canvas.drawRRect(seatBody, bodyPaint);

    final RRect headRest = RRect.fromLTRBR(
      size.width * 0.15,
      0,
      size.width * 0.85,
      size.height * 0.38,
      const Radius.circular(8),
    );
    canvas.drawRRect(headRest, bodyPaint);

    final Paint borderPaint = Paint()
      ..color = isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.2;

    canvas.drawRRect(seatBody, borderPaint);
    canvas.drawRRect(headRest, borderPaint);

    final Paint linePaint = Paint()
      ..color = isSelected ? Colors.white24 : Colors.black12
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.35),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant RealisticSeatPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.baseColor != baseColor;
  }
}
