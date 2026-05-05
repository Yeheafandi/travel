import 'package:flutter/material.dart';

class RealisticSeatPainter extends CustomPainter {
  final Color baseColor;
  final bool isSelected;

  RealisticSeatPainter({required this.baseColor, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. رسم الظل السفلي (تأثير الارتفاع)
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

    // 2. إعدادات الألوان (التدرج اللوني)
    // عند الاختيار نستخدم تدرجاً أخضر، وعند التوفر نستخدم تدرجاً رمادياً/أبيض
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSelected
            ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)] // تدرج أخضر
            : [Colors.white, Colors.grey.shade100], // تدرج أبيض/رمادي
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // 3. رسم جسم المقعد (Seat Body)
    final RRect seatBody = RRect.fromLTRBR(
      0,
      size.height * 0.25,
      size.width,
      size.height,
      const Radius.circular(10),
    );
    canvas.drawRRect(seatBody, bodyPaint);

    // 4. رسم مسند الرأس (Headrest)
    final RRect headRest = RRect.fromLTRBR(
      size.width * 0.15,
      0,
      size.width * 0.85,
      size.height * 0.38,
      const Radius.circular(8),
    );
    canvas.drawRRect(headRest, bodyPaint);

    // 5. رسم الحدود (Borders)
    final Paint borderPaint = Paint()
      ..color = isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.2;

    canvas.drawRRect(seatBody, borderPaint);
    canvas.drawRRect(headRest, borderPaint);

    // 6. إضافة لمسة "العمق" (خط فاصل خفيف بين المسند والجسم)
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
    // إعادة الرسم فقط إذا تغيرت حالة الاختيار أو اللون
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.baseColor != baseColor;
  }
}
