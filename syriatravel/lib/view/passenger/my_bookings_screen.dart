import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syriatravel/widgets/passenger_widgets/booking_widgets/booking_card.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});
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
                            return BookingCard(
                              booking: doc.data() as Map<String, dynamic>,
                              bookingId: doc.id,
                              primaryGreen: primaryGreen,
                            );
                          },
                        ),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //     vertical: 10,
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: Container(
                      //           height: 1,
                      //           color: Colors.black26,
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 12,
                      //         ),
                      //         child: Text(
                      //           'حجوزات البوت',
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.black54,
                      //           ),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         child: Container(
                      //           height: 1,
                      //           color: Colors.black26,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const BotWidget(),
                    ],
                  ),
                );
              },
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
