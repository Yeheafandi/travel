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
  var bookedSeats = <int>[].obs;
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
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['bookedSeats'] != null) {
          bookedSeats.value = List<int>.from(data['bookedSeats']);
        }
        if (data['totalSeats'] != null) {
          totalSeats.value = data['totalSeats'];
        }
      }
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
    });
  }

  bool isBooked(int seatNumber) => bookedSeats.contains(seatNumber);
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

  // الدالة المصححة
  Future<void> confirmBooking() async {
    if (selectedSeats.isEmpty) return;

    try {
      isLoading.value = true; // إظهار التحميل أثناء الحجز
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference tripRef = FirebaseFirestore.instance
            .collection('trips')
            .doc(tripId); // استخدام tripId الموجود في الكلاس مباشرة
            
        DocumentSnapshot snapshot = await transaction.get(tripRef);

        if (!snapshot.exists) throw "الرحلة غير موجودة";

        List<int> currentBooked = List<int>.from(snapshot['bookedSeats'] ?? []);

        for (var seat in selectedSeats) {
          if (currentBooked.contains(seat)) {
            throw "المقعد $seat تم حجزه بالفعل من قبل شخص آخر!";
          }
        }

        transaction.update(tripRef, {
          'bookedSeats': FieldValue.arrayUnion(selectedSeats),
        });
      });

      Get.snackbar("نجاح", "تم تأكيد حجزك للمقاعد: ${selectedSeats.join(', ')}");
      selectedSeats.clear();
      Get.back();
    } catch (e) {
      Get.snackbar("فشل الحجز", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}