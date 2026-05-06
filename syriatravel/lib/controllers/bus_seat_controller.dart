import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart' show Inst;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class BusSeatController extends GetxController {
  final String tripId;
  final double tripPrice;
  BusSeatController({required this.tripId, required this.tripPrice});

  var isLoading = true.obs;
  var totalSeats = 40.obs;
  var reservedSeats = <int>[].obs;
  var selectedSeats = <int>[].obs;

  int get rowCount => (totalSeats.value / 4).ceil();
  double get totalPrice => selectedSeats.length * tripPrice;

  @override
  void onInit() {
    super.onInit();
    _listenToTripUpdates();
  }

  void _listenToTripUpdates() {
    FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>;

              // التحقق من وجود الحقل قبل القراءة
              if (data.containsKey('bookedSeats') &&
                  data['bookedSeats'] != null) {
                reservedSeats.value = List<int>.from(data['bookedSeats']);
              } else {
                reservedSeats.value = []; // قيمة افتراضية إذا لم يوجد الحقل
              }

              if (data.containsKey('totalSeats') &&
                  data['totalSeats'] != null) {
                totalSeats.value = data['totalSeats'];
              } else {
                totalSeats.value =
                    40; // قيمة افتراضية لعدد المقاعد إذا لم يحدد في الداتابيز
              }
            }
            isLoading.value = false;
          },
          onError: (e) {
            isLoading.value = false;
          },
        );
  }

  bool isBooked(int seatNumber) => reservedSeats.contains(seatNumber);
  bool isSelected(int seatNumber) => selectedSeats.contains(seatNumber);

  void toggleSeat(int seatNumber) {
    if (isSelected(seatNumber)) {
      selectedSeats.remove(seatNumber);
    } else {
      if (selectedSeats.length < 5) {
        selectedSeats.add(seatNumber);
      } else {
        Get.snackbar("تنبيه", "لا يمكنك حجز أكثر من 5 مقاعد");
      }
    }
  }

  Future<void> confirmBooking(String userId) async {
    if (selectedSeats.isEmpty) return;

    try {
      isLoading.value = true; // 1. بدء التحميل

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference tripRef = FirebaseFirestore.instance
            .collection('trips')
            .doc(tripId);
        DocumentSnapshot snapshot = await transaction.get(tripRef);

        if (!snapshot.exists) throw "الرحلة غير موجودة";

        final data = snapshot.data() as Map<String, dynamic>?;
        List<int> currentBooked = List<int>.from(data?['bookedSeats'] ?? []);

        for (var seat in selectedSeats) {
          if (currentBooked.contains(seat)) throw "المقعد $seat محجوز بالفعل!";
        }

        // تحديث المقاعد وإنشاء الحجز
        transaction.update(tripRef, {
          'bookedSeats': FieldValue.arrayUnion(selectedSeats.toList()),
        });

        DocumentReference bookingRef = FirebaseFirestore.instance
            .collection('bookings')
            .doc();
        transaction.set(bookingRef, {
          'userId': userId,
          'tripId': tripId,
          'seats': selectedSeats.toList(),
          'totalPrice': totalPrice,
          'bookingDate': FieldValue.serverTimestamp(),
          'status': 'confirmed',
        });
      });

      // 2. إيقاف التحميل فور النجاح وقبل أي انتقال
      isLoading.value = false;
      final double savedPrice = totalPrice;
      selectedSeats.clear();

      // 3. إظهار رسالة النجاح للمستخدم وهو لا يزال في الشاشة
      Get.snackbar(
        "نجاح",
        "تم الحجز بمبلغ $savedPrice ل.س",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      // 4. إغلاق الديالوج والعودة بعد تأخير بسيط لضمان ثبات الحالة
      Future.delayed(const Duration(milliseconds: 600), () {
        if (Get.isDialogOpen ?? false) Get.back(); // إغلاق نافذة التأكيد
        Get.back(); // العودة لشاشة الرحلات
      });
    } catch (e) {
      isLoading.value = false; // إيقاف التحميل عند الخطأ
      Get.snackbar("فشل الحجز", e.toString(), backgroundColor: Colors.red);
    }
  }
}
