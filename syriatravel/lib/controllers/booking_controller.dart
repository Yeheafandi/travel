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

  void confirmBooking(TripModel trip, String name, String phone, String idNumber) {
    bookTrip(trip, name, phone: phone, idNumber: idNumber);
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
              (doc) => TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
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

  // 3. دالة حجز الرحلة (تصحيح المعاملات وإضافة حالة التحميل)
  Future<void> bookTrip(TripModel trip, String name, {required String phone, required String idNumber}) async {
    try {
      isLoading.value = true; // تفعيل مؤشر التحميل
      
      String? currentUserId = _auth.currentUser?.uid;
      
      if (currentUserId == null) {
        Get.snackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      await _firestore.collection('bookings').add({
        'tripId': trip.id,
        'passengerId': currentUserId,
        'passengerName': name,
        'phoneNumber': phone,
        'identityNumber': idNumber,
        'fromCity': trip.fromCity,
        'toCity': trip.toCity,
        'price': trip.price,
        'status': 'pending', 
        'bookingDate': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "تم الحجز",
        "تم إرسال طلب حجزك بنجاح لسائق الرحلة",
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل الحجز: $e",
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // إيقاف مؤشر التحميل
    }
  }
}