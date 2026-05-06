import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/constants/app_colors.dart';
import '../../controllers/search_trip_controller.dart';

class FilterSection extends StatelessWidget {
  final SearchTripController controller;

  const FilterSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: ["الكل", "الأرخص", "الأغلى", "السائق"].map((filter) {
          return Obx(() {
            final bool isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.selectedFilter.value = filter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : const [],
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey300,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? AppColors.onPrimary : AppColors.grey700,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}
