import 'package:flutter/material.dart';

class TripTicket extends StatelessWidget {
  final Map<String, dynamic> trip;
  final Color primaryGreen;

  const TripTicket({super.key, required this.trip, required this.primaryGreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildRouteNode(trip['fromCity'] ?? "", "انطلاق"),
                _buildBusDivider(),
                _buildRouteNode(trip['toCity'] ?? "", "وصول"),
              ],
            ),
          ),
          _buildPriceFooter(),
        ],
      ),
    );
  }

  Widget _buildBusDivider() {
    return Expanded(
      child: Column(
        children: [
          Icon(Icons.directions_bus_rounded, color: primaryGreen, size: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(color: primaryGreen.withOpacity(0.2), thickness: 2),
          ),
          Text(trip['time'] ?? "--:--", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPriceFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(trip['driverName'] ?? "غير محدد", style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(12)),
            child: Text("${trip['price']} ل.س", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteNode(String city, String label) {
    return Column(
      children: [
        Text(city, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}