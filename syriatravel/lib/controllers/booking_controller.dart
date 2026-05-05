import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/models/trip_model.dart';

class BookingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;
  var searchResults = <TripModel>[].obs;
  var isSearching = false.obs;

  // هذه هي الدالة التي يستدعيها زر "تأكيد" في الواجهة (UI)
  void confirmBooking(TripModel trip) {
    // جلب اسم المستخدم الحالي من Firebase Auth
    String? passengerName = _auth.currentUser?.displayName ?? "مسافر غير معروف";

    // استدعاء دالة الحجز الفعلية
    bookTrip(trip, passengerName);
  }

  Future<void> searchTrips(String from, String to) async {
    try {
      isSearching.value = true;
      searchResults.clear();

      QuerySnapshot querySnapshot = await _firestore
          .collection('trips')
          .where('fromCity', isEqualTo: from)
          .where('toCity', isEqualTo: to)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        searchResults.value = querySnapshot.docs
            .map(
              (doc) =>
                  TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
            )
            .toList();
      } else {
        Get.snackbar(
          "تنبيه",
          "لا توجد رحلات متاحة بين هاتين المدينتين حالياً",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
        );
      }
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "حدث خطأ أثناء البحث: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> bookTrip(TripModel trip, String passengerName) async {
    try {
      isLoading.value = true;
      String? uid = _auth.currentUser?.uid;

      if (uid == null) {
        Get.snackbar("تنبيه", "يجب تسجيل الدخول أولاً");
        return;
      }

      await _firestore.collection('bookings').add({
        'tripId': trip.id,
        'passengerId': uid,
        'driverId': trip.driverId,
        'fromCity': trip.fromCity,
        'toCity': trip.toCity,
        'price': trip.price,
        'driverName': trip.driverName,
        'passengerName': passengerName,
        'bookingDate':
            FieldValue.serverTimestamp(), 
        'status': 'pending',
      });

      Get.snackbar(
        "تم الحجز",
        "تم إرسال طلب حجزك بنجاح لسائق الرحلة",
        backgroundColor: Colors.green.withOpacity(0.1),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل الحجز: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
