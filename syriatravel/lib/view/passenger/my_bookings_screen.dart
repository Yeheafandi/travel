import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syriatravel/bot/bot_widget.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  // اللون الأخضر الرسمي للتطبيق
  final Color primaryGreen = const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "حجوزاتي",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
      ),
      body: currentUserId == null
          ? const Center(child: Text("يرجى تسجيل الدخول لعرض الحجوزات"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("حدث خطأ ما: ${snapshot.error}"));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                        _buildNoBookingsFound()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data!.docs[index];
                            var booking = doc.data() as Map<String, dynamic>;
                            String bookingId = doc.id;
                            return _buildBookingCard(
                              context,
                              booking,
                              bookingId,
                            );
                          },
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            // الخط الأيمن
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors
                                    .black26, // لون أسود خفيف جداً أو رمادي
                              ),
                            ),

                            // النص مع مسافة بسيطة من الطرفين
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ), // المسافة بين النص والخطوط
                              child: Text(
                                'حجوزات البوت',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black54, // لون النص بوضوح أخف من الأسود الكامل
                                ),
                              ),
                            ),

                            // الخط الأيسر
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.black26, // لون مطابق للخط الأول
                              ),
                            ),
                          ],
                        ),
                      ),
                      const BotWidget(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Map<String, dynamic> booking,
    String bookingId,
  ) {
    // جلب البيانات الأساسية
    List<dynamic> seats = booking['selectedSeats'] ?? [];
    int seatsCount = seats.length;
    String seatsText = seats.join(' , ');

    double totalPrice = 0.0;
    var priceData = booking['price'];

    if (priceData is String) {
      totalPrice = double.tryParse(priceData) ?? 0.0;
    } else if (priceData is num) {
      totalPrice = priceData.toDouble();
    }
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
                    _buildStatusBadge(booking['status'] ?? 'pending'),
                    // عرض السعر الإجمالي الفعلي هنا
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$totalPrice ل.س",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryGreen,
                          ),
                        ),
                        Text(
                          "إجمالي $seatsCount مقاعد",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 0.8),
                // ... (باقي تفاصيل من/إلى والتاريخ كما هي في كودك)

                // عرض تفاصيل المقاعد
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryGreen.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chair_alt, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "أرقام المقاعد: ${seatsText.isEmpty ? 'غير محدد' : seatsText}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // زر الإلغاء المحدث
          InkWell(
            onTap: () =>
                _showCancelDialog(context, bookingId, booking['tripId'], seats),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: const Text(
                "إلغاء هذا الحجز",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة الإلغاء المحدثة (تحذف الحجز وتفتح المقاعد في الرحلة)
  void _showCancelDialog(
    BuildContext context,
    String bookingId,
    String tripId,
    List<dynamic> seats,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الإلغاء"),
        content: const Text(
          "عند إلغاء الحجز سيتم إتاحة المقاعد للآخرين مرة أخرى.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تراجع"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              WriteBatch batch = FirebaseFirestore.instance.batch();

              // 1. حذف وثيقة الحجز
              batch.delete(
                FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(bookingId),
              );

              // 2. تحديث وثيقة الرحلة لإزالة المقاعد المحجوزة
              batch.update(
                FirebaseFirestore.instance.collection('trips').doc(tripId),
                {'bookedSeats': FieldValue.arrayRemove(seats)},
              );

              await batch.commit();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم إلغاء الحجز وإعادة توفر المقاعد"),
                ),
              );
            },
            child: const Text(
              "تأكيد الإلغاء",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'confirmed' ? Colors.blue : Colors.orange;
    String text = status == 'confirmed' ? "مؤكد" : "قيد الانتظار";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNoBookingsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 15),
          const Text(
            "لا توجد حجوزات حالية",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
