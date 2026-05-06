import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';

class TripListItem extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripListItem({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${trip.price} ل.س", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text("السائق: ${trip.driverName}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${trip.fromCity} ← ${trip.toCity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(trip.date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(width: 5),
                    const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 15),
            const CircleAvatar(
              backgroundColor: Color(0xFFF0F4F0),
              child: Icon(Icons.directions_bus, color: Color(0xFF1B5E20)),
            ),
          ],
        ),
      ),
    );
  }
}