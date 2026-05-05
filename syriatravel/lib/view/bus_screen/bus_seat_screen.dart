import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/controllers/bus_seat_controller.dart';
import 'package:syriatravel/models/trip_model.dart';
import 'package:syriatravel/view/bus_screen/bus_seat_painter.dart';

class BusSeatScreen extends StatelessWidget {
  final TripModel trip;
  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color occupiedRed = const Color(0xFFB71C1C);

  BusSeatScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final BusSeatController controller = Get.put(
      BusSeatController(tripId: trip.id.toString()),
      tag: trip.id,
      permanent: false,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: primaryGreen));
        }

        if (controller.totalSeats.value == 0) {
          return const Center(child: Text("لا توجد مقاعد متاحة حالياً"));
        }

        bool isFull =
            controller.bookedSeats.length >= controller.totalSeats.value;

        return Column(
          children: [
            if (isFull)
              Container(
                width: double.infinity,
                color: occupiedRed.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
                child: Text(
                  "هذه الرحلة مكتملة العدد",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: occupiedRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            _buildLegend(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 30),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.rowCount,
                itemBuilder: (context, index) =>
                    _buildSeatRow(index, controller),
              ),
            ),
            _buildActionPanel(controller),
          ],
        );
      }),
    );
  }

  // تمرير الكنترول للدوال الفرعية للوصول للبيانات
  Widget _buildSeatRow(int rowIndex, BusSeatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildSingleSeat(rowIndex * 4 + 1, controller),
              const SizedBox(width: 12),
              _buildSingleSeat(rowIndex * 4 + 2, controller),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildSingleSeat(rowIndex * 4 + 3, controller),
              const SizedBox(width: 12),
              _buildSingleSeat(rowIndex * 4 + 4, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSeat(int seatNumber, BusSeatController controller) {
    return Obx(() {
      if (seatNumber > controller.totalSeats.value) {
        return const SizedBox(width: 50, height: 55);
      }

      bool isBooked = controller.isBooked(seatNumber);
      bool isSelected = controller.isSelected(seatNumber);

      return GestureDetector(
        onTap: isBooked ? null : () => controller.toggleSeat(seatNumber),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: CustomPaint(
            size: const Size(50, 55),
            painter: RealisticSeatPainter(
              baseColor: isBooked
                  ? Colors.grey.shade400
                  : (isSelected ? primaryGreen : Colors.white),
              isSelected: isSelected,
            ),
            child: SizedBox(
              width: 50,
              height: 55,
              child: Center(
                child: isBooked
                    ? const Icon(Icons.close, size: 20, color: Colors.white70)
                    : Text(
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
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem("متاح", Colors.white, Colors.grey[300]!),
          const SizedBox(width: 20),
          _legendItem("مختار", primaryGreen, primaryGreen),
          const SizedBox(width: 20),
          _legendItem("محجوز", Colors.grey.shade400, Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color fill, Color border) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildActionPanel(BusSeatController controller) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "المقاعد المختارة:",
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  hasSelection
                      ? controller.selectedSeats.join(", ")
                      : "لم يتم الاختيار",
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text("رجوع"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: hasSelection
                        ? () => controller.confirmBooking()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "تأكيد الحجز الآن",
                      style: TextStyle(color: Colors.white),
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
}
