import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/widgets/passenger_widgets/action_panel.dart';
import 'package:syriatravel/widgets/passenger_widgets/seat_legend.dart';
import 'package:syriatravel/widgets/passenger_widgets/seat_widget.dart';
import '../../controllers/bus_seat_controller.dart';
import '../../models/trip_model.dart';

class BusSeatScreen extends StatelessWidget {
  final TripModel trip;
  final Color primaryGreen = const Color(0xFF1B5E20);

  BusSeatScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final BusSeatController controller = Get.put(
      BusSeatController(
        tripId: trip.id.toString(),
        tripPrice: double.tryParse(trip.price.toString()) ?? 0.0,
      ),
      tag: trip.id,
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
        if (controller.isLoading.value)
          return Center(child: CircularProgressIndicator(color: primaryGreen));

        return Column(
          children: [
            SeatLegend(primaryGreen: primaryGreen),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 30),
                itemCount: controller.rowCount,
                itemBuilder: (context, index) => _buildRow(index, controller),
              ),
            ),
            ActionPanel(
              controller: controller,
              trip: trip,
              primaryGreen: primaryGreen,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRow(int rowIndex, BusSeatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSeatPair(rowIndex * 4 + 1, rowIndex * 4 + 2, controller),
          const Spacer(),
          _buildSeatPair(rowIndex * 4 + 3, rowIndex * 4 + 4, controller),
        ],
      ),
    );
  }

  Widget _buildSeatPair(int s1, int s2, BusSeatController controller) {
    return Row(
      children: [
        SeatWidget(
          seatNumber: s1,
          controller: controller,
          primaryGreen: primaryGreen,
        ),
        const SizedBox(width: 12),
        SeatWidget(
          seatNumber: s2,
          controller: controller,
          primaryGreen: primaryGreen,
        ),
      ],
    );
  }
}
