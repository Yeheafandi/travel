import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/constants/app_colors.dart';
import '../../controllers/search_trip_controller.dart';

class DriverSearchField extends StatelessWidget {
  final SearchTripController controller;

  const DriverSearchField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedFilter.value == "السائق") {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
          child: TextField(
            onChanged: (v) => controller.driverQuery.value = v,
            style: const TextStyle(color: AppColors.foreground),
            decoration: InputDecoration(
              hintText: "اكتب اسم السائق المفضل...",
              hintStyle: const TextStyle(color: AppColors.foregroundMuted),
              prefixIcon: const Icon(
                Icons.person_search,
                color: AppColors.primary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
