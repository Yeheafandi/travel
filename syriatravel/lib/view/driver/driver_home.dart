import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/controllers/driver_controller.dart';
import 'package:syriatravel/models/trip_model.dart';
import 'package:syriatravel/widgets/driver_widgets/add_bus_dialog.dart'
    show showAddBusDialog;
import 'package:syriatravel/widgets/driver_widgets/add_trip_dialog.dart';

class DriverHomeScreen extends StatelessWidget {
  DriverHomeScreen({super.key});
  final DriverController driverController = Get.put(DriverController());

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Column(
        children: [
          _buildDriverHeader(primaryGreen, driverController, context),
          Transform.translate(
            offset: const Offset(0, -30),
            child: _buildStatsCard(driverController),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "رحلاتك الحالية",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (driverController.myTrips.isEmpty) {
                return const Center(child: Text("لا توجد رحلات مضافة بعد"));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: driverController.myTrips.length,
                itemBuilder: (context, index) {
                  final trip = driverController.myTrips[index];
                  return _buildTripCard(trip, driverController);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTripDialog(context),
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("إضافة رحلة", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- مكونات الواجهة ---

  Widget _buildDriverHeader(
    Color color,
    DriverController controller,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 60),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "أهلاً بك،",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Obx(
                () => Text(
                  controller.driverName.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // إضافة زر الباص هنا
          IconButton(
            onPressed: () => showAddBusDialog(context),
            icon: const Icon(
              Icons.directions_bus_filled,
              color: Colors.white,
              size: 28,
            ),
            tooltip: "إضافة باص جديد",
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(DriverController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => _statItem("${controller.myTrips.length}", "الرحلات")),
          Obx(() => _statItem("${controller.myBuses.length}", "الباصات")),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTripCard(TripModel trip, DriverController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text("${trip.fromCity} ➔ ${trip.toCity}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("الوقت: ${trip.date} | ${trip.time}"),
            Text("السائق: ${trip.driverName}"), // إظهار اسم صاحب الباص هنا
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => controller.deleteTrip(trip.id!),
        ),
      ),
    );
  }
}
