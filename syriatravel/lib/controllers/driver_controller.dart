import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // أضفنا مكتبة auth
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/models/trip_model.dart';

class DriverController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  var isLoading = false.obs;
  var myTrips = <TripModel>[].obs;
  var driverName = "".obs;

  // 1. قائمة لحفظ باصات السائق
  var myBuses = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // جلب البيانات تلقائياً بمجرد تشغيل المتحكم
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      getDriverProfile(uid);
      fetchMyBuses(uid); // جلب الباصات
      fetchMyTrips(uid); // جلب الرحلات
    }
  }

  // 2. دالة لجلب باصات السائق من Firestore
  Future<void> fetchMyBuses(String uid) async {
    try {
      var doc = await _firestore.collection('drivers').doc(uid).get();
      if (doc.exists && doc.data()?['buses'] != null) {
        myBuses.value = List<Map<String, dynamic>>.from(doc.data()!['buses']);
      }
    } catch (e) {
      print("خطأ في جلب الباصات: $e");
    }
  }

  Future<void> addTrip(TripModel trip) async {
  try {
    isLoading.value = true;

    // 1. فحص تضارب المواعيد: هل الباص محجوز في نفس التاريخ والوقت؟
    final existingTrips = await _firestore
        .collection('trips')
        .where('busId', isEqualTo: trip.busId)
        .where('date', isEqualTo: trip.date)
        .where('time', isEqualTo: trip.time)
        .get();

    if (existingTrips.docs.isNotEmpty) {
      Get.snackbar(
        "تنبيه", 
        "هذا الباص لديه رحلة أخرى في نفس هذا الوقت والتاريخ!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return; // توقف عن الإضافة
    }

    // 2. إذا لم يوجد تضارب، نقوم بالإضافة
    await _firestore.collection('trips').add(trip.toMap());
    Get.snackbar("نجاح", "تمت إضافة الرحلة بنجاح");
    
  } catch (e) {
    Get.snackbar("خطأ", "فشل إضافة الرحلة: $e");
  } finally {
    isLoading.value = false;
  }
}

  void fetchMyTrips(String driverId) {
    _firestore
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .listen((snapshot) {
          myTrips.value = snapshot.docs
              .map((doc) => TripModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).delete();
      _showSnackbar("تم الحذف", "تم إلغاء الرحلة بنجاح", Colors.orange);
    } catch (e) {
      _showSnackbar("خطأ", "لم يتم الحذف: $e", Colors.red);
    }
  }

  // 3. تعديل جلب الاسم ليكون من مجموعة 'drivers' إذا كان الحساب خاصاً بسائق
  Future<void> getDriverProfile(String uid) async {
    try {
      // جرب البحث في مجموعة 'users' أولاً، ثم 'drivers'
      var doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        doc = await _firestore.collection('drivers').doc(uid).get();
      }

      if (doc.exists) {
        driverName.value = doc.data()?['name'] ?? "كابتن";
      }
    } catch (e) {
      print("خطأ في جلب الملف الشخصي: $e");
    }
  }

  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> addBus(String busName, int totalSeats) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> newBus = {
        'busId': DateTime.now().millisecondsSinceEpoch.toString(),
        'busName': busName,
        'totalSeats': totalSeats,
      };

      await _firestore.collection('drivers').doc(currentUid).set({
        'buses': FieldValue.arrayUnion([newBus]),
      }, SetOptions(merge: true));

      myBuses.add(newBus);
      Get.snackbar("نجاح", "تمت إضافة الباص بنجاح");
    } catch (e) {
      Get.snackbar("خطأ", "فشل العملية: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
