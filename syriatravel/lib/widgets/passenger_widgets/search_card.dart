import 'package:flutter/material.dart';
import 'package:syriatravel/widgets/passenger_widgets/passenger_widgets.dart';

class SearchCard extends StatelessWidget {
  final Color primaryColor;

  const SearchCard({super.key, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text("ابحث عن رحلتك", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          PassengerWidgets.buildLocationField(label:"من",value:  "دمشق",icon: Icons.radio_button_checked,iconColor: primaryColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: CircleAvatar(
              backgroundColor: primaryColor,
              radius: 18,
              child: const Icon(Icons.swap_vert, color: Colors.white, size: 20),
            ),
          ),
          PassengerWidgets.buildLocationField(label:"إلى",value: "حلب",icon: Icons.location_on,iconColor: Colors.redAccent),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: PassengerWidgets.buildInfoBox(label:"تاريخ السفر",value: "غداً",icon: Icons.calendar_month)),
              const SizedBox(width: 15),
              Expanded(child: PassengerWidgets.buildInfoBox(label:"المسافرون",value: "3 مسافرون",icon: Icons.person_outline)),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search),
              label: const Text("البحث عن رحلات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}