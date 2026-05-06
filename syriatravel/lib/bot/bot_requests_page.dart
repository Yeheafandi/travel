import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/bot/bot_requests_controller.dart';

class BotRequestsPage extends StatelessWidget {
  const BotRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BotRequestsController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('طلبات البوت'),
            actions: [
              IconButton(
                onPressed: controller.isLoading
                    ? null
                    : controller.fetchBookings,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Builder(
            builder: (_) {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (controller.bookings.isEmpty) {
                return const Center(child: Text('لا توجد طلبات حالياً'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = controller.bookings[index];
                  final isSavingThis = controller.isBookingSaving(booking);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.passengerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('الهاتف: ${booking.phone}'),
                          Text('من: ${booking.from}'),
                          Text('إلى: ${booking.to}'),
                          Text(
                            'الرحلة: ${booking.tripId.isEmpty ? 'غير محددة بعد' : booking.tripId}',
                          ),
                          Text('الحالة: ${booking.status}'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSavingThis
                                  ? null
                                  : () => controller.approveBooking(booking),
                              child: Text(
                                isSavingThis ? 'جارٍ الحفظ...' : 'اعتماد وحفظ',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
