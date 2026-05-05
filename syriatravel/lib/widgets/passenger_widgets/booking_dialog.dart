import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/view/bus_screen/bus_seat_screen.dart';
import '../../../models/trip_model.dart';
import '../../../controllers/booking_controller.dart';

class BookingDialog {
  static void show(BuildContext context, TripModel trip) {
    final BookingController bookingController = Get.find<BookingController>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController idController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                const SizedBox(height: 20),
                const Text(
                  "تأكيد تفاصيل الحجز",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, "الاسم الكامل", Icons.person),
                const SizedBox(height: 15),
                _buildTextField(
                  phoneController,
                  "رقم الهاتف",
                  Icons.phone,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  idController,
                  "رقم الهوية",
                  Icons.badge,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 25),
                _buildActionButtons(
                  trip,
                  nameController,
                  phoneController,
                  idController,
                  bookingController,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHandle() {
    return Container(
      width: 50,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  static Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget _buildActionButtons(
    TripModel trip,
    TextEditingController name,
    TextEditingController phone,
    TextEditingController id,
    BookingController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("إلغاء"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (name.text.isEmpty || phone.text.isEmpty || id.text.isEmpty) {
                Get.snackbar(
                  "تنبيه",
                  "يرجى إكمال كافة البيانات",
                  backgroundColor: Colors.redAccent,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();

              await controller.bookTrip(
                trip,
                name.text,
                phone: phone.text,
                idNumber: id.text,
              );

              Get.to(() => BusSeatScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("تأكيد الحجز"),
          ),
        ),
      ],
    );
  }
}
