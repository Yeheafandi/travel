import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/controllers/bus_seat_controller.dart';
import 'package:syriatravel/view/bus_screen/bus_seat_painter.dart';

class BusSeatScreen extends StatelessWidget {
  final BusSeatController controller = Get.put(BusSeatController());

  // الهوية البصرية: الأخضر الداكن والأبيض
  final Color primaryGreen = const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // خلفية بيضاء نقية
      appBar: AppBar(
        title: Text(
          "اختيار المقاعد",
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryGreen),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildLegend(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 30),
              itemCount: 10, // عدد الصفوف
              itemBuilder: (context, index) {
                // أنيميشن ظهور الصفوف بشكل متسلسل
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildSeatRow(index),
                );
              },
            ),
          ),
          _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildSeatRow(int rowIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        children: [
          _buildSingleSeat(rowIndex * 4 + 1),
          const SizedBox(width: 12),
          _buildSingleSeat(rowIndex * 4 + 2),
          const Spacer(), // الممر
          _buildSingleSeat(rowIndex * 4 + 3),
          const SizedBox(width: 12),
          _buildSingleSeat(rowIndex * 4 + 4),
        ],
      ),
    );
  }

  Widget _buildSingleSeat(int seatNumber) {
    return Obx(() {
      bool isSelected = controller.isSelected(seatNumber);
      return GestureDetector(
        onTap: () => controller.toggleSeat(seatNumber),
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0, // أنيميشن نبض عند الاختيار
          duration: const Duration(milliseconds: 200),
          child: CustomPaint(
            size: const Size(50, 55),
            painter: RealisticSeatPainter(
              baseColor: isSelected ? primaryGreen : Colors.white,
              isSelected: isSelected,
            ),
            child: SizedBox(
              width: 50,
              height: 55,
              child: Center(
                child: Text(
                  "$seatNumber",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem("متاح", Colors.white, Colors.grey[300]!),
          const SizedBox(width: 30),
          _legendItem("مختار", primaryGreen, primaryGreen),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color fill, Color border) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Obx(() {
        bool hasSelection = controller.selectedSeats.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ملخص عدد المقاعد
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "عدد المقاعد المختارة:",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasSelection
                          ? const Color(0xFF1B5E20).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${controller.seatCount}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hasSelection
                            ? const Color(0xFF1B5E20)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // أزرار التحكم
            Row(
              children: [
                // زر إلغاء الرحلة
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => _showCancelConfirmation(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "إلغاء الرحلة",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // زر تأكيد الحجز
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: hasSelection ? () => Get.back() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      hasSelection
                          ? "تأكيد الحجز (${controller.seatCount})"
                          : "اختر مقعداً",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  // نافذة تأكيد الإلغاء
  void _showCancelConfirmation() {
    Get.defaultDialog(
      title: "تنبيه",
      middleText: "هل أنت متأكد من رغبتك في إلغاء الرحلة؟",
      textConfirm: "نعم، إلغاء",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () => controller.cancelTrip(),
    );
  }
}
