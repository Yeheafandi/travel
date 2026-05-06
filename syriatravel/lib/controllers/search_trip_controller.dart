import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchTripController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var searchResults = <QueryDocumentSnapshot>[].obs;
  var isLoading = false.obs;

  var fromCity = "".obs;
  var toCity = "".obs;

  // تحديث القيم الافتراضية للفلاتر
  var selectedFilter = "الكل".obs; 
  var driverQuery = "".obs; 

  void searchTrips() async {
    if (fromCity.value.trim().isEmpty || toCity.value.trim().isEmpty) {
      Get.snackbar("تنبيه", "يرجى إدخال مدينة الانطلاق والوجهة");
      return;
    }

    try {
      isLoading.value = true;

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

  List<QueryDocumentSnapshot> get filteredTrips {
    List<QueryDocumentSnapshot> list = [...searchResults];

    // 1. الفلترة حسب اسم السائق
    if (driverQuery.value.isNotEmpty) {
      list = list.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return (data['driverName'] ?? "").toString().toLowerCase().contains(
          driverQuery.value.toLowerCase(),
        );
      }).toList();
    }

    // 2. الترتيب حسب السعر (الأرخص والأغلى)
    if (selectedFilter.value == "الأرخص") {
      list.sort((a, b) {
        var dataA = a.data() as Map<String, dynamic>;
        var dataB = b.data() as Map<String, dynamic>;
        // تحويل السعر لرقم لضمان دقة المقارنة
        num priceA = num.tryParse(dataA['price']?.toString() ?? '0') ?? 0;
        num priceB = num.tryParse(dataB['price']?.toString() ?? '0') ?? 0;
        return priceA.compareTo(priceB);
      });
    } 
    else if (selectedFilter.value == "الأغلى") {
      list.sort((a, b) {
        var dataA = a.data() as Map<String, dynamic>;
        var dataB = b.data() as Map<String, dynamic>;
        num priceA = num.tryParse(dataA['price']?.toString() ?? '0') ?? 0;
        num priceB = num.tryParse(dataB['price']?.toString() ?? '0') ?? 0;
        // الترتيب التنازلي للأغلى
        return priceB.compareTo(priceA);
      });
    }

    return list;
  }
}