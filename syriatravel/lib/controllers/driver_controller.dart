import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/models/trip_model.dart';

class DriverController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  var myTrips = <TripModel>[].obs;

  Future<void> addTrip(TripModel trip) async {
    try {
      isLoading.value = true;
      await _firestore.collection('trips').add(trip.toMap());

      Get.snackbar("نجاح", "تمت إضافة الرحلة");

      fetchMyTrips(trip.driverId);
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
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

  var driverName = "".obs;

  Future<void> getDriverProfile(String uid) async {
    try {
      var doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        driverName.value = doc.data()?['name'] ?? "سائق غير معروف";
      }
    } catch (e) {
      print("خطأ في جلب الاسم: $e");
    }
  }
}
