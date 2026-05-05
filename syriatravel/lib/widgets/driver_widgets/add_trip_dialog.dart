import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/driver_controller.dart';
import '../../models/trip_model.dart';

void showAddTripDialog(BuildContext context) {
  final controller = Get.find<DriverController>();
  final fromC = TextEditingController();
  final toC = TextEditingController();
  final priceC = TextEditingController();
  final dateC = TextEditingController();
  final timeC = TextEditingController();
  String? selectedBusId;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "إضافة رحلة جديدة",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Obx(
              () => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "اختر الباص"),
                items: controller.myBuses
                    .map(
                      (bus) => DropdownMenuItem<String>(
                        value: bus['busId'],
                        child: Text(
                          "${bus['busName']} (${bus['totalSeats']} مقعد)",
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => selectedBusId = val,
              ),
            ),
            TextField(
              controller: fromC,
              decoration: const InputDecoration(labelText: "من مدينة"),
            ),
            TextField(
              controller: toC,
              decoration: const InputDecoration(labelText: "إلى مدينة"),
            ),
            TextField(
              controller: dateC,
              decoration: const InputDecoration(
                labelText: "التاريخ (مثلاً: 2026/05/10)",
              ),
            ),
            TextField(
              controller: timeC,
              decoration: const InputDecoration(
                labelText: "الوقت (مثلاً: 10:00 AM)",
              ),
            ),
            TextField(
              controller: priceC,
              decoration: const InputDecoration(labelText: "السعر"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (selectedBusId == null ||
                              fromC.text.isEmpty ||
                              toC.text.isEmpty) {
                            Get.snackbar("تنبيه", "يرجى ملء جميع الحقول");
                            return;
                          }
                          final bus = controller.myBuses.firstWhere(
                            (b) => b['busId'] == selectedBusId,
                          );

                          // داخل ElevatedButton في نافذة إضافة رحلة
                          await controller.addTrip(
                            TripModel(
                              fromCity: fromC.text,
                              toCity: toC.text,
                              date: dateC.text.trim(),
                              time: timeC.text.trim(),
                              price: priceC.text,
                              driverName: controller
                                  .driverName
                                  .value, // هذا هو اسم صاحب الباص
                              driverId: controller.currentUid,
                              busId: selectedBusId!,
                              totalSeats: bus['totalSeats'],
                              reservedSeats: [],
                            ),
                          );
                          Navigator.pop(context);
                        },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "حفظ الرحلة",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
