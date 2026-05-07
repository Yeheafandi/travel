import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/constants/app_colors.dart';
import 'package:syriatravel/models/trip_model.dart';
import 'package:syriatravel/view/bus_screen/bus_seat_screen.dart';
import 'package:syriatravel/widgets/passenger_widgets/driver_search_field.dart';
import 'package:syriatravel/widgets/passenger_widgets/filter_section.dart';
import 'package:syriatravel/widgets/passenger_widgets/search_header.dart';
import 'package:syriatravel/widgets/passenger_widgets/trip_ticket.dart';

import '../../controllers/search_trip_controller.dart';

class SearchTripScreen extends StatelessWidget {
  SearchTripScreen({super.key});

  final SearchTripController controller = Get.put(SearchTripController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "استكشف رحلتك",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(controller: controller),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    FilterSection(controller: controller),
                    DriverSearchField(controller: controller),
                    _buildSectionTitle(),
                    _buildResults(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "الرحلات المتاحة لك",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 50),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (controller.filteredTrips.isEmpty) {
        return const Column(
          children: [
            SizedBox(height: 50),
            Icon(Icons.bus_alert_rounded, size: 80, color: AppColors.grey300),
            SizedBox(height: 10),
            Text(
              "عذراً، لا توجد رحلات تطابق بحثك",
              style: TextStyle(color: AppColors.grey500),
            ),
          ],
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredTrips.length,
        itemBuilder: (context, index) {
          var doc = controller.filteredTrips[index];
          var data = doc.data() as Map<String, dynamic>;

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              TripModel selectedTrip = TripModel.fromMap(data, doc.id);

              Get.to(
                () => BusSeatScreen(trip: selectedTrip),
                transition: Transition.cupertino,
              );
            },
            child: TripTicket(trip: data, primaryGreen: AppColors.primary),
          );
        },
      );
    });
  }
}
