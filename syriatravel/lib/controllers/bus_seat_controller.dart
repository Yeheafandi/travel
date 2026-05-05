import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class BusSeatController extends GetxController {
  final String tripId;
  BusSeatController({required this.tripId});

  var isLoading = true.obs;
  var totalSeats = 40.obs;
  var reservedSeats = <int>[].obs;
  var selectedSeats = <int>[].obs;

  int get rowCount => (totalSeats.value / 4).ceil();

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

  Future<void> confirmBooking() async {
    if (selectedSeats.isEmpty) return;

    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference tripRef = FirebaseFirestore.instance
            .collection('trips')
            .doc(tripId);

        DocumentSnapshot snapshot = await transaction.get(tripRef);

        if (!snapshot.exists) throw "الرحلة غير موجودة";

        final data = snapshot.data() as Map<String, dynamic>?;

        // إذا كان الحقل غير موجود في الصورة، نعتبره قائمة فارغة حالياً
        List<int> currentBooked = [];
        if (data != null && data.containsKey('bookedSeats')) {
          currentBooked = List<int>.from(data['bookedSeats']);
        }

        for (var seat in selectedSeats) {
          if (currentBooked.contains(seat)) {
            throw "المقعد $seat تم حجزه بالفعل من قبل مستخدم آخر!";
          }
        }

        // التحديث سيقوم بإنشاء الحقل تلقائياً في Firebase إذا لم يكن موجوداً
        transaction.update(tripRef, {
          'bookedSeats': FieldValue.arrayUnion(selectedSeats),
        });
      });

      Get.snackbar("نجاح", "تم تأكيد الحجز بنجاح");
      selectedSeats.clear();
      Get.back();
    } catch (e) {
      Get.snackbar("خطأ في الحجز", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
