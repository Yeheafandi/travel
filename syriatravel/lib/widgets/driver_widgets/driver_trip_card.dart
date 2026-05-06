import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../controllers/driver_controller.dart';

class DriverTripCard extends StatelessWidget {
  final TripModel trip;
  final DriverController controller;

  const DriverTripCard({
    super.key,
    required this.trip,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final int passengerCount = trip.bookedSeats.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildLocationNode(trip.fromCity, "انطلاق"),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_bus_rounded,
                        color: Colors.green,
                        size: 28,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Colors.green.withOpacity(0.2),
                          thickness: 2,
                        ),
                      ),
                      Text(
                        trip.time,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildLocationNode(trip.toCity, "وصول"),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.green.shade900.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),
                ),

                Row(
                  children: [
                    _buildStatChip(Icons.calendar_today_rounded, trip.date),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.people_rounded,
                      "$passengerCount ركاب",
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationNode(String city, String label) {
    return Column(
      children: [
        Text(
          city,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? Colors.green : Colors.green.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isPrimary ? Colors.white : Colors.green),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("تأكيد الحذف", textAlign: TextAlign.center),
        content: const Text(
          "هل أنت متأكد من حذف هذه الرحلة؟",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: StadiumBorder(),
            ),
            onPressed: () {
              controller.deleteTrip(trip.id!);
              Navigator.pop(context);
            },
            child: const Text(
              "حذف الآن",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
