import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/widgets/passenger_widgets/home_header.dart';
import 'package:syriatravel/widgets/passenger_widgets/passenger_widgets.dart';
import 'package:syriatravel/widgets/passenger_widgets/search_card.dart';
import 'package:syriatravel/widgets/passenger_widgets/trip_list_item.dart';

import '../../../controllers/booking_controller.dart';
import '../../../controllers/navigation_controller.dart';
import '../../../models/trip_model.dart';

class PassengerHomeScreen extends StatelessWidget {
  PassengerHomeScreen({super.key});

  final BookingController bookingController = Get.put(BookingController());
  final NavigationController navController =  Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeHeader(
                backgroundColor: primaryGreen,
                userName: user?.displayName ?? "مسافر",
              ),

              Transform.translate(
                offset: const Offset(0, -40),
                child: const SearchCard(primaryColor: primaryGreen),
              ),

              PassengerWidgets.buildSectionHeader(
                title: "الرحلات المتاحة حالياً 🔥",
                actionText: "عرض الكل",
                onActionTap: () {},
              ),

              _buildTripsStream(),

              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return PassengerWidgets.buildNoTripsFound();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), 
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            TripModel trip = TripModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );

            return TripListItem(
              trip: trip,
              onTap: () => _showBookingConfirmDialog(context, trip),
            );
          },
        );
      },
    );
  }

  void _showBookingConfirmDialog(BuildContext context, TripModel trip) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "تأكيد حجز الرحلة",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Text(
                "هل أنت متأكد من رغبتك في حجز مقعد في الرحلة المتوجهة من ${trip.fromCity} إلى ${trip.toCity}؟",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              Row(
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
                      onPressed: () {
                        Get.back();
                        bookingController.bookTrip(
                          trip,
                          "",
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


 
}
