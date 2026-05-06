import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../models/trip_model.dart';
import '../../../controllers/booking_controller.dart';

class BookingDialog {
  static void show(
    BuildContext context,
    TripModel trip,
    List<int> selectedSeats,
  ) {
    final BookingController bookingController = Get.find<BookingController>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    final TextEditingController transactionController = TextEditingController();

    final String paymentReference = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    final String shamCashNumber = "09xxxxxxxx";

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

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(),
                ),
                const Text(
                  "تعليمات الدفع (شام كاش)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 15),

                // عرض رقم الحساب مع زر نسخ
                _buildCopyableField(
                  context,
                  "رقم حساب التحويل",
                  shamCashNumber,
                ),
                const SizedBox(height: 10),

                _buildCopyableField(
                  context,
                  "رمز الدفع (يوضع في الملاحظات)",
                  paymentReference,
                  isHighlight: true,
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  transactionController,
                  "أدخل رقم العملية بعد التحويل",
                  Icons.receipt_long,
                  keyboard: TextInputType.number,
                ),

                const SizedBox(height: 25),

                // 3. أزرار العمليات
                _buildActionButtons(
                  trip,
                  nameController,
                  phoneController,
                  idController,
                  transactionController,
                  bookingController,
                  selectedSeats,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCopyableField(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFFE8F5E9) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlight ? const Color(0xFF1B5E20) : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? const Color(0xFF1B5E20) : Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  size: 20,
                  color: Color(0xFF1B5E20),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Get.snackbar(
                    "تم النسخ",
                    "تم نسخ $label إلى الحافظة",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1B5E20),
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ),
        ),
      ],
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
    TextEditingController transaction,
    BookingController controller,
    List<int> selectedSeats,
  ) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            return controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      if (name.text.isEmpty ||
                          phone.text.isEmpty ||
                          id.text.isEmpty ||
                          transaction.text.isEmpty) {
                        Get.snackbar(
                          "تنبيه",
                          "يرجى إكمال البيانات وإدخال رقم عملية الدفع",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      await controller.bookTrip(
                        trip: trip,
                        passengerName: name.text,
                        phone: phone.text,
                        idNumber: id.text,
                        seats: selectedSeats,
                        transactionId: transaction.text,
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
                    child: const Text("تأكيد الدفع والحجز"),
                  );
          }),
        ),
      ],
    );
  }
}
