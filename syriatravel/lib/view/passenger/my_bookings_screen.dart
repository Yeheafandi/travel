import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  .where('passengerId', isEqualTo: currentUserId)
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var booking = doc.data() as Map<String, dynamic>;
                    String bookingId = doc.id; // نحتاج الـ ID للإلغاء
                    return _buildBookingCard(context, booking, bookingId);
                  },
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
    // 1. جلب البيانات والتأكد أنها قائمة (List)
    var reservedData = booking['reservedSeats'];
    List<dynamic> seats = [];

    if (reservedData is List) {
      seats = reservedData;
    } else if (reservedData != null) {
      seats = [reservedData];
    }

    int seatsCount = seats.length;

    String seatsText = seats.map((s) => s.toString()).join(' , ');

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
                    Text(
                      "${booking['price']} ل.س",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 0.8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryGreen.withOpacity(0.1),
                      child: Icon(Icons.directions_bus, color: primaryGreen),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${booking['fromCity']} ➔ ${booking['toCity']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "التاريخ: ${booking['bookingDate']?.toDate().toString().split(' ')[0] ?? '---'}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // عرض تفاصيل المقاعد
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryGreen.withOpacity(0.05)),
                  ),
                  // داخل Container تفاصيل المقاعد
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        // أضفنا Expanded لضمان عدم حدوث Overflow إذا كانت المقاعد كثيرة
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chair_alt,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "المقاعد: ${seatsText.isEmpty ? 'غير محدد' : seatsText}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // لضمان عدم خروج النص عن الشاشة
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "$seatsCount مقاعد",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // زر إلغاء الرحلة
          InkWell(
            onTap: () => _showCancelDialog(context, bookingId),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "إلغاء هذا الحجز",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // نافذة تأكيد الإلغاء
  void _showCancelDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الإلغاء", textAlign: TextAlign.right),
        content: const Text(
          "هل أنت متأكد من رغبتك في إلغاء هذا الحجز؟",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تراجع", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(bookingId)
                  .delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم إلغاء الحجز بنجاح"),
                  backgroundColor: Colors.red,
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
