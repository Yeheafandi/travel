import 'package:flutter/material.dart';
import 'package:syriatravel/core/constants/app_colors.dart';
import '../../controllers/search_trip_controller.dart';

class SearchHeader extends StatelessWidget {
  final SearchTripController controller;

  const SearchHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(color: AppColors.shadowMedium, blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            _buildField(
              "من (مدينة الانطلاق)",
              Icons.location_on_rounded,
              (v) => controller.fromCity.value = v,
            ),
            const Divider(color: AppColors.divider),
            _buildField(
              "إلى (الوجهة المقصودة)",
              Icons.navigation_rounded,
              (v) => controller.toCity.value = v,
            ),
            const SizedBox(height: 12),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.foreground),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.foregroundMuted),
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => controller.searchTrips(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          "بحث عن الرحلات",
          style: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
