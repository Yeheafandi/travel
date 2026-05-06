import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
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
              if (data.containsKey('bookedSeats') &&
                  data['bookedSeats'] != null) {
                reservedSeats.value = List<int>.from(data['bookedSeats']);
              } else {
                reservedSeats.value = [];
              }
              if (data.containsKey('totalSeats') &&
                  data['totalSeats'] != null) {
                totalSeats.value = data['totalSeats'];
              } else {
                totalSeats.value = 40;
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

  Future<void> confirmBooking({
    required String userId,
    required String passengerName,
    required String phone,
    required String idNumber,
    required String transactionId,
  }) async {
    if (selectedSeats.isEmpty) return;

    try {
      isLoading.value = true;
      String bookingReference = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(7);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference tripRef = FirebaseFirestore.instance
            .collection('trips')
            .doc(tripId);
        DocumentSnapshot snapshot = await transaction.get(tripRef);

        if (!snapshot.exists) throw "الرحلة غير موجودة";

        final data = snapshot.data() as Map<String, dynamic>?;
        List<int> currentBooked = List<int>.from(data?['bookedSeats'] ?? []);

        for (var seat in selectedSeats) {
          if (currentBooked.contains(seat))
            throw "المقعد $seat تم حجزه للتو من قبل مستخدم آخر!";
        }

        transaction.update(tripRef, {
          'bookedSeats': FieldValue.arrayUnion(selectedSeats.toList()),
        });
        DocumentReference bookingRef = FirebaseFirestore.instance
            .collection('bookings')
            .doc();
        transaction.set(bookingRef, {
          'userId': userId,
          'tripId': tripId,
          'passengerName': passengerName,
          'phoneNumber': phone,
          'identityNumber': idNumber,
          'transactionId': transactionId,
          'bookingReference': bookingReference,
          'seats': selectedSeats.toList(),
          'totalPrice': totalPrice,
          'bookingDate': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
      });

      isLoading.value = false;
      final double savedPrice = totalPrice;
      selectedSeats.clear();

      Get.snackbar(
        "تم استلام طلب الحجز",
        "بانتظار تأكيد عملية الدفع للرمز: $bookingReference",
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        Get.close(2);
      });
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "فشل الحجز",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
