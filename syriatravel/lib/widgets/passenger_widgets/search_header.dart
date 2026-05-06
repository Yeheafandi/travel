import 'package:flutter/material.dart';
import '../../controllers/search_trip_controller.dart';

class SearchHeader extends StatelessWidget {
  final SearchTripController controller;
  final Color primaryGreen;

  const SearchHeader({super.key, required this.controller, required this.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Column(
          children: [
            _buildField("من (مدينة الانطلاق)", Icons.location_on_rounded, (v) => controller.fromCity.value = v),
            const Divider(),
            _buildField("إلى (الوجهة المقصودة)", Icons.navigation_rounded, (v) => controller.toCity.value = v),
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
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryGreen),
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
        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: const Text("بحث عن الرحلات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}