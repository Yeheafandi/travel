import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/driver_controller.dart';

void showAddBusDialog(BuildContext context) {
  final controller = Get.find<DriverController>();
  final nameC = TextEditingController();
  final seatsC = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("إضافة باص جديد", textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameC,
            decoration: const InputDecoration(
              labelText: "اسم الباص (مثلاً: بولمان 1)",
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: seatsC,
            decoration: const InputDecoration(labelText: "عدد المقاعد"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
          ),
          onPressed: () async {
            if (nameC.text.isNotEmpty && seatsC.text.isNotEmpty) {
              await controller.addBus(nameC.text, int.parse(seatsC.text));
              Navigator.pop(context);
            } else {
              Get.snackbar("تنبيه", "يرجى ملء كافة البيانات");
            }
          },
          child: const Text("إضافة", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
