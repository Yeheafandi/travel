import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/trip_model.dart';
import '../../../controllers/booking_controller.dart';

class BookingDialog {
  // أضفنا selectedSeats كبارامتر مطلوب هنا
  static void show(
    BuildContext context,
    TripModel trip,
    List<int> selectedSeats,
  ) {
    final BookingController bookingController = Get.find<BookingController>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController idController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 25,
            right: 25,
            top: 15,
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
                const SizedBox(height: 10),
                // عرض المقاعد المختارة للتأكيد
                Text(
                  "المقاعد المختارة: ${selectedSeats.join(', ')}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                  selectedSeats, // تمرير المقاعد للدالة
                ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
    );
  }

  static Widget _buildActionButtons(
    TripModel trip,
    TextEditingController name,
    TextEditingController phone,
    TextEditingController id,
    BookingController controller,
    List<int> selectedSeats,
  ) {
    return Row(
      children: [
        Expanded(
          // استخدام Obx هنا لمراقبة حالة التحميل
          child: Obx(() {
            return controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      if (name.text.isEmpty ||
                          phone.text.isEmpty ||
                          id.text.isEmpty) {
                        Get.snackbar(
                          "تنبيه",
                          "يرجى إكمال كافة البيانات",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      // استدعاء دالة الحجز
                      await controller.bookTrip(
                        trip: trip,
                        passengerName: name.text,
                        phone: phone.text,
                        idNumber: id.text,
                        seats: selectedSeats,
                      );
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
                  );
          }),
        ),
      ],
    );
  }
}
