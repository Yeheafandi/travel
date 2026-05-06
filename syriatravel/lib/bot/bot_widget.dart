import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BotWidget extends StatelessWidget {
  const BotWidget({super.key});

  // نفس لون "مؤكد" في حجوزات التطبيق
  static const Color primaryBlue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bot_requests')
          .orderBy('savedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("حدث خطأ ما: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoBookingsFound();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 15),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var booking = doc.data() as Map<String, dynamic>;
            String bookingId = doc.id;
            return _buildBookingCard(context, booking, bookingId);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Map<String, dynamic> booking,
    String bookingId,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${booking['price'] ?? '12000'} ل.س",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryBlue,
                          ),
                        ),
                        const Text(
                          "1 مقعد",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 0.8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${booking['from'] ?? ''} → ${booking['to'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${booking['time'] ?? 'غير محدد'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBotSeatInfo(booking),
              ],
            ),
          ),

          // زر الحذف فقط وبعرض كامل
          Row(children: [Expanded(child: _buildDeleteButton(bookingId))]),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "مؤكد",
        style: TextStyle(
          color: primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBotSeatInfo(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text('الهاتف: ${booking['phone'] ?? ''}')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.badge, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text('الرقم الوطني: ${booking['nationalId'] ?? ''}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(String bookingId) {
    return InkWell(
      onTap: () => _showCancelDialog(bookingId),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            "إلغاء الحجز",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(String docId) {
    Get.dialog(
      AlertDialog(
        title: const Text("إلغاء الحجز"),
        content: const Text("هل أنت متأكد من حذف هذا الحجز؟"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("تراجع")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('bot_requests')
                    .doc(docId)
                    .delete();
                Get.back();
                Get.snackbar(
                  'تم الإلغاء',
                  'تم حذف الحجز بنجاح',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar('خطأ', 'فشل في الحذف: $e');
              }
            },
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBookingsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "لا توجد حجوزات من البوت",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            "احجز رحلتك الأولى من خلال البوت!",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
