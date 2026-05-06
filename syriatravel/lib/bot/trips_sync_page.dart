import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'trips_sync_service.dart';

class TripsSyncPage extends StatelessWidget {
  const TripsSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = Get.find<TripsSyncService>();

    return Scaffold(
      appBar: AppBar(title: const Text('مزامنة الرحلات مع البوت')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final success = await syncService.syncTripsWithBot();
            if (success) {
              Get.snackbar(
                'نجحت المزامنة',
                'تم إرسال الرحلات للبوت',
                snackPosition: SnackPosition.TOP,
              );
            } else {
              Get.snackbar(
                'فشل المزامنة',
                'تحقق من حالة البوت',
                snackPosition: SnackPosition.TOP,
              );
            }
          },
          icon: const Icon(Icons.sync),
          label: const Text('مزامنة الرحلات الآن'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
    );
  }
}
