import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchTripController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // متغيرات لمراقبة حالة البحث والنتائج
  var searchResults = <QueryDocumentSnapshot>[].obs;
  var isLoading = false.obs;

  // متغيرات لتخزين قيم البحث
  var fromCity = "".obs;
  var toCity = "".obs;

  void searchTrips() async {
    if (fromCity.isEmpty || toCity.isEmpty) {
      Get.snackbar("تنبيه", "يرجى إدخال مدينة الانطلاق والوجهة");
      return;
    }

    try {
      isLoading.value = true;

      // جلب الرحلات التي تطابق مدينة الانطلاق والوجهة
      QuerySnapshot querySnapshot = await _firestore
          .collection('trips')
          .where('fromCity', isEqualTo: fromCity.value.trim())
          .where('toCity', isEqualTo: toCity.value.trim())
          .get();

      searchResults.value = querySnapshot.docs;
    } catch (e) {
      Get.snackbar("خطأ", "فشل جلب الرحلات: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
