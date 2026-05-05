import 'package:flutter/material.dart';

class RealisticSeatPainter extends CustomPainter {
  final Color baseColor;
  final bool isSelected;

  RealisticSeatPainter({required this.baseColor, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect seatBody = RRect.fromLTRBR(
      0, size.height * 0.25, size.width, size.height, const Radius.circular(10),
    );

    final RRect headRest = RRect.fromLTRBR(
      size.width * 0.15, 0, size.width * 0.85, size.height * 0.35, const Radius.circular(8),
    );

    // ظل خفيف جداً ليناسب الخلفية البيضاء
    canvas.drawRRect(seatBody.shift(const Offset(0, 3)), Paint()..color = Colors.black12..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    final Paint bodyPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(seatBody, bodyPaint);
    canvas.drawRRect(headRest, bodyPaint);

    // حدود المقعد (تصبح خضراء واضحة عند الاختيار)
    final Paint borderPaint = Paint()
      ..color = isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5;
    
    canvas.drawRRect(seatBody, borderPaint);
    canvas.drawRRect(headRest, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}