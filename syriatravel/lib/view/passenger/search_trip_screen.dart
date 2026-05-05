import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/controllers/search_trip_controller.dart';

class SearchTripScreen extends StatelessWidget {
  SearchTripScreen({super.key});
  final SearchTripController controller = Get.put(SearchTripController());

  @override
  Widget build(BuildContext context) {
    // حقن المتحكم

    return Scaffold(
      appBar: AppBar(title: const Text("البحث عن رحلة"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) => controller.fromCity.value = v,
                      decoration: const InputDecoration(
                        labelText: "من (مدينة الانطلاق)",
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    TextField(
                      onChanged: (v) => controller.toCity.value = v,
                      decoration: const InputDecoration(
                        labelText: "إلى (الوجهة)",
                        prefixIcon: Icon(Icons.directions_bus),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.searchTrips,
                      child: const Text("ابحث الآن"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // عرض النتائج
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.searchResults.isEmpty) {
                return const Center(child: Text("لا توجد رحلات متاحة حالياً"));
              }
              return ListView.builder(
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  var trip =
                      controller.searchResults[index].data()
                          as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        "رحلة من ${trip['fromCity']} إلى ${trip['toCity']}",
                      ),
                      subtitle: Text(
                        "السعر: ${trip['price']} ل.س | الموعد: ${trip['time']}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // هنا ننتقل لصفحة تفاصيل الرحلة وحجز المقاعد
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
