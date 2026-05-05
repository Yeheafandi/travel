import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusSeatController extends GetxController {
  // قائمة المقاعد المختارة
  var selectedSeats = <int>[].obs;

  // إضافة أو إزالة مقعد
  void toggleSeat(int seatNumber) {
    if (selectedSeats.contains(seatNumber)) {
      selectedSeats.remove(seatNumber);
    } else {
      selectedSeats.add(seatNumber);
    }
  }

  bool isSelected(int seatNumber) => selectedSeats.contains(seatNumber);
  
  // عدد المقاعد المحجوزة حالياً
  int get seatCount => selectedSeats.length;

  // دالة لإلغاء الرحلة بالكامل
  void cancelTrip() {
    selectedSeats.clear();
    Get.back(); // العودة للشاشة السابقة
    Get.snackbar(
      "تم الإلغاء",
      "تم إلغاء عملية الحجز بنجاح",
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}