import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/bus_seat_controller.dart';
import '../../../models/trip_model.dart';
import '../../../widgets/passenger_widgets/booking_dialog.dart';

class ActionPanel extends StatelessWidget {
  final BusSeatController controller;
  final TripModel trip;
  final Color primaryGreen;

  const ActionPanel({
    super.key,
    required this.controller,
    required this.trip,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 35),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Obx(() {
        bool hasSelection = controller.selectedSeats.isNotEmpty;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow("المقاعد المختارة:", hasSelection ? controller.selectedSeats.join(", ") : "لم يتم الاختيار"),
            const SizedBox(height: 10),
            _buildInfoRow("إجمالي المبلغ:", "${controller.totalPrice} ل.س", isBold: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("رجوع"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _handleBooking(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("تأكيد الحجز الآن", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            color: primaryGreen,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }

  void _handleBooking() {
    if (controller.selectedSeats.isEmpty) {
      Get.snackbar("تنبيه", "يرجى اختيار مقعد واحد على الأقل");
    } else {
      BookingDialog.show(Get.context!, trip, controller.selectedSeats.toList());
    }
  }
}