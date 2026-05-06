import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/search_trip_controller.dart';

class FilterSection extends StatelessWidget {
  final SearchTripController controller;
  final Color primaryGreen;

  const FilterSection({super.key, required this.controller, required this.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: ["الكل", "الأرخص", "الأغلى", "السائق"].map((filter) {
          return Obx(() {
            bool isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () => controller.selectedFilter.value = filter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: isSelected ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                  border: Border.all(color: isSelected ? primaryGreen : Colors.grey[300]!),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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