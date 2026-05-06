import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/search_trip_controller.dart';

class DriverSearchField extends StatelessWidget {
  final SearchTripController controller;
  final Color primaryGreen;

  const DriverSearchField({super.key, required this.controller, required this.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedFilter.value == "السائق") {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: TextField(
            onChanged: (v) => controller.driverQuery.value = v,
            decoration: InputDecoration(
              hintText: "اكتب اسم السائق المفضل...",
              prefixIcon: Icon(Icons.person_search, color: primaryGreen),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}