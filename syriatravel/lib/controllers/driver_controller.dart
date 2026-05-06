import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/models/trip_model.dart';

class DriverController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  var isLoading = false.obs;
  var myTrips = <TripModel>[].obs;
  var driverName = "".obs;

  var myBuses = <Map<String, dynamic>>[].obs;

  StreamSubscription<QuerySnapshot>? _tripsSubscription;

  @override
  void onInit() {
    super.onInit();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      getDriverProfile(uid);
      fetchMyBuses(uid);
      fetchMyTrips(uid);
    }
  }

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
        return;
      }

      await _firestore.collection('trips').add(trip.toMap());
      Get.snackbar("نجاح", "تمت إضافة الرحلة بنجاح");
    } catch (e) {
      Get.snackbar("خطأ", "فشل إضافة الرحلة: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchMyTrips(String driverId) {
    _tripsSubscription?.cancel();
    _tripsSubscription = _firestore
        .collection('trips')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .listen(
          (snapshot) {
            myTrips.value = snapshot.docs
                .map((doc) => TripModel.fromMap(doc.data(), doc.id))
                .toList();
          },
          onError: (e) {
            myTrips.clear();
          },
        );
  }

  @override
  void onClose() {
    _tripsSubscription?.cancel();
    _tripsSubscription = null;
    super.onClose();
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      isLoading.value = true;

      final tripSnapshot = await _firestore
          .collection('trips')
          .doc(tripId)
          .get();
      if (!tripSnapshot.exists) {
        _showSnackbar("خطأ", "الرحلة غير موجودة", Colors.red);
        return;
      }
      final tripData = tripSnapshot.data() as Map<String, dynamic>;
      final fromCity = tripData['fromCity'] ?? '';
      final toCity = tripData['toCity'] ?? '';
      final date = tripData['date'] ?? '';

      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('tripId', isEqualTo: tripId)
          .get();

      final batch = _firestore.batch();

      for (final doc in bookingsSnapshot.docs) {
        final bookingData = doc.data();
        final passengerUserId = bookingData['userId'];

        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'userId': passengerUserId,
          'title': 'تم إلغاء الرحلة',
          'body':
              'تم إلغاء رحلتك من $fromCity إلى $toCity بتاريخ $date من قبل السائق.',
          'tripId': tripId,
          'type': 'trip_cancelled',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        batch.delete(doc.reference);
      }

      batch.delete(_firestore.collection('trips').doc(tripId));

      await batch.commit();

      final affected = bookingsSnapshot.docs.length;
      _showSnackbar(
        "تم الحذف",
        affected == 0
            ? "تم إلغاء الرحلة بنجاح"
            : "تم إلغاء الرحلة وإشعار $affected من المسافرين",
        Colors.orange,
      );
    } catch (e) {
      _showSnackbar("خطأ", "لم يتم الحذف: $e", Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDriverProfile(String uid) async {
    try {
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
