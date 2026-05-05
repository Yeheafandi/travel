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
              (doc) => TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
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

  // --- التعديل الجوهري هنا ---
  // دالة حجز الرحلة المحدثة لاستقبال المقاعد والبيانات بنظام الأقواس المجعدة { }
  Future<void> bookTrip({
    required TripModel trip,
    required String passengerName,
    required String phone,
    required String idNumber,
    required List<int> seats, // إضافة قائمة المقاعد
  }) async {
    try {
      isLoading.value = true;
      
      String? currentUserId = _auth.currentUser?.uid;
      
      if (currentUserId == null) {
        Get.snackbar("خطأ", "يجب تسجيل الدخول أولاً");
        return;
      }

      // 1. إضافة سجل الحجز في مجموعة 'bookings'
      await _firestore.collection('bookings').add({
        'tripId': trip.id,
        'passengerId': currentUserId,
        'passengerName': passengerName,
        'phoneNumber': phone,
        'identityNumber': idNumber,
        'selectedSeats': seats, // حفظ المقاعد التي اختارها المستخدم
        'fromCity': trip.fromCity,
        'toCity': trip.toCity,
        'price': trip.price * seats.length, // حساب السعر الإجمالي بناءً على عدد المقاعد
        'status': 'pending', 
        'bookingDate': FieldValue.serverTimestamp(),
      });

      // 2. تحديث المقاعد المحجوزة في مستند الرحلة (Trips) لمنع الآخرين من حجزها
      // نستخدم arrayUnion لإضافة المقاعد الجديدة للمصفوفة الموجودة مسبقاً
      await _firestore.collection('trips').doc(trip.id).update({
        'bookedSeats': FieldValue.arrayUnion(seats),
      });

      Get.snackbar(
        "تم الحجز بنجاح",
        "تم حجز المقاعد: ${seats.join(', ')}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // العودة للشاشة الرئيسية بعد الحجز
      Get.offAllNamed('/home'); 

    } catch (e) {
      Get.snackbar(
        "خطأ في الحجز",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}