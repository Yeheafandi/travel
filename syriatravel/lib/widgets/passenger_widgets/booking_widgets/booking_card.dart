import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'status_badge.dart';
import 'booking_details_helper.dart';

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String bookingId;
  final Color primaryGreen;

  const BookingCard({
    super.key,
    required this.booking,
    required this.bookingId,
    required this.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    List<dynamic> seats = booking['selectedSeats'] ?? [];
    double totalPrice = _parsePrice(booking['price']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: booking['status'] ?? 'pending'),
                    _buildPriceInfo(totalPrice, seats.length),
                  ],
                ),
                const Divider(height: 30, thickness: 0.8),
                _buildRouteRow(),
                const SizedBox(height: 20),
                _buildDateTimeRow(),
                const SizedBox(height: 20),
                _buildSeatsIndicator(seats.join(' , ')),
              ],
            ),
          ),
          _buildCancelButton(context, seats),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(double price, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$price ل.س",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryGreen,
          ),
        ),
        Text(
          "إجمالي $count مقاعد",
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRouteRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BookingDetailsHelper.buildRouteDetail(
          "من",
          booking['fromCity'] ?? 'غير محدد',
          Icons.location_on_outlined,
          primaryGreen,
        ),
        Icon(Icons.arrow_back, size: 16, color: primaryGreen.withOpacity(0.5)),
        BookingDetailsHelper.buildRouteDetail(
          "إلى",
          booking['toCity'] ?? 'غير محدد',
          Icons.flag_outlined,
          primaryGreen,
        ),
      ],
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        BookingDetailsHelper.buildInfoTile(
          Icons.calendar_today,
          "التاريخ",
          booking['date'] ?? '--',
        ),
        const SizedBox(width: 20),
        BookingDetailsHelper.buildInfoTile(
          Icons.access_time,
          "الوقت",
          booking['time'] ?? '--',
        ),
      ],
    );
  }

  Widget _buildSeatsIndicator(String seatsText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreen.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.chair_alt, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "أرقام المقاعد: ${seatsText.isEmpty ? 'غير محدد' : seatsText}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, List<dynamic> seats) {
    return InkWell(
      onTap: () =>
          _showCancelDialog(context, bookingId, booking['tripId'], seats),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: const Text(
          "إلغاء هذا الحجز",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  double _parsePrice(dynamic priceData) {
    if (priceData is String) return double.tryParse(priceData) ?? 0.0;
    if (priceData is num) return priceData.toDouble();
    return 0.0;
  }

  void _showCancelDialog(
    BuildContext context,
    String bId,
    String tId,
    List<dynamic> seats,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الإلغاء"),
        content: const Text(
          "عند إلغاء الحجز سيتم إتاحة المقاعد للآخرين مرة أخرى.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تراجع"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.runTransaction((tx) async {
                  final tripRef = FirebaseFirestore.instance
                      .collection('trips')
                      .doc(tId);
                  final bookingRef = FirebaseFirestore.instance
                      .collection('bookings')
                      .doc(bId);

                  final tripSnap = await tx.get(tripRef);
                  if (tripSnap.exists) {
                    final currentSeats = List<int>.from(
                      (tripSnap.data()?['bookedSeats'] ?? []) as List,
                    );
                    final seatsToRemove = seats
                        .map((s) => s is int ? s : int.tryParse(s.toString()))
                        .whereType<int>()
                        .toSet();
                    final newSeats = currentSeats
                        .where((s) => !seatsToRemove.contains(s))
                        .toList();
                    tx.update(tripRef, {'bookedSeats': newSeats});
                  }
                  tx.delete(bookingRef);
                });
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("فشل الإلغاء: $e")));
                }
                return;
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              "تأكيد الإلغاء",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
