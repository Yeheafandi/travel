import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/widgets/passenger_widgets/driver_search_field.dart';
import 'package:syriatravel/widgets/passenger_widgets/filter_section.dart';
import 'package:syriatravel/widgets/passenger_widgets/search_header.dart';
import 'package:syriatravel/widgets/passenger_widgets/trip_ticket.dart';
import '../../controllers/search_trip_controller.dart';

class SearchTripScreen extends StatelessWidget {
  SearchTripScreen({super.key});

  final SearchTripController controller = Get.put(SearchTripController());
  final Color primaryGreen = const Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "استكشف رحلتك",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          SearchHeader(controller: controller, primaryGreen: primaryGreen),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  FilterSection(
                    controller: controller,
                    primaryGreen: primaryGreen,
                  ),

                  DriverSearchField(
                    controller: controller,
                    primaryGreen: primaryGreen,
                  ),

                  _buildSectionTitle(),

                  _buildResults(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "الرحلات المتاحة لك",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Center(child: CircularProgressIndicator(color: primaryGreen)),
        );
      }

      if (controller.filteredTrips.isEmpty) {
        return Column(
          children: [
            const SizedBox(height: 50),
            Icon(Icons.bus_alert_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text(
              "عذراً، لا توجد رحلات تطابق بحثك",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredTrips.length,
        itemBuilder: (context, index) {
          var data =
              controller.filteredTrips[index].data() as Map<String, dynamic>;
          return TripTicket(trip: data, primaryGreen: primaryGreen);
        },
      );
    });
  }
}
