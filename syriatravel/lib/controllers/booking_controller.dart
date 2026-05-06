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

  // تحديث دالة البحث لتكون متوافقة مع التغييرات
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
        Get.snackbar("تنبيه", "لا توجد رحلات متاحة حالياً");
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء البحث: $e");
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> bookTrip({
    required TripModel trip,
    required String passengerName,
    required String phone,
    required String idNumber,
    required List<int> seats,
  }) async {
    try {
      isLoading.value = true;
      String? currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null) {
        Get.snackbar("خطأ", "يجب تسجيل الدخول أولاً");
        isLoading.value = false; // مهم جداً إيقافه هنا
        return;
      }

      await _firestore.runTransaction((transaction) async {
        DocumentReference tripRef = _firestore.collection('trips').doc(trip.id);
        DocumentSnapshot tripSnapshot = await transaction.get(tripRef);

        if (!tripSnapshot.exists) throw Exception("الرحلة غير موجودة");

        // إنشاء سجل الحجز
        DocumentReference bookingRef = _firestore.collection('bookings').doc();
        transaction.set(bookingRef, {
          'tripId': trip.id,
          'userId': currentUserId,
          'passengerName': passengerName,
          'phoneNumber': phone,
          'identityNumber': idNumber,
          'selectedSeats': seats,
          'fromCity': trip.fromCity,
          'toCity': trip.toCity,
          'price': trip.price * seats.length,
          'status':
              'confirmed', // اجعلها confirmed مباشرة إذا لم تكن تحتاج مراجعة
          'bookingDate': FieldValue.serverTimestamp(),
        });

        // تحديث المقاعد في الرحلة
        transaction.update(tripRef, {
          'bookedSeats': FieldValue.arrayUnion(seats),
        });
      });

      // إيقاف التحميل قبل إغلاق الواجهة
      isLoading.value = false;

      Get.snackbar(
        "نجاح",
        "تم حجز المقاعد: ${seats.join(', ')}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // العودة من الديالوج
      Get.back();
      // العودة من شاشة المقاعد إلى الرئيسية (اختياري)
      Future.delayed(const Duration(milliseconds: 500), () => Get.back());
    } catch (e) {
      isLoading.value = false; // مهم جداً في حالة الخطأ
      Get.snackbar(
        "خطأ في الحجز",
        "فشلت العملية: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
