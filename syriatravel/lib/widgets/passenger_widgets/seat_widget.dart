import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/view/bus_screen/bus_seat_painter.dart';
import '../../../controllers/bus_seat_controller.dart';

class SeatWidget extends StatelessWidget {
  final int seatNumber;
  final BusSeatController controller;
  final Color primaryGreen;

  const SeatWidget({
    super.key,
    required this.seatNumber,
    required this.controller,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
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
}
