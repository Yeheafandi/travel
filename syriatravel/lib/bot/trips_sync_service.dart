import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'trip_model.dart';

class TripsSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String botUrl;

  TripsSyncService({required this.botUrl});

  Future<List<TripModel>> getAvailableTrips() async {
    // جلب كل الرحلات حاليًا للاختبار
    final snapshot = await _firestore.collection('trips').get();

    return snapshot.docs
        .map((doc) => TripModel.fromFirestore(doc.data()))
        .where((trip) => trip.availableSeats > 0) // فقط المتاحة
        .toList();
  }

  Future<bool> syncTripsWithBot() async {
    try {
      final trips = await getAvailableTrips();
      print('Found ${trips.length} available trips');

      final cleanBotUrl = botUrl.endsWith('/')
          ? botUrl.substring(0, botUrl.length - 1)
          : botUrl;

      final uri = Uri.parse('$cleanBotUrl/sync-trips');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(trips.map((t) => t.toJson()).toList()),
      );

      print('Bot response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Synced ${result['count']} trips to bot');
        return true;
      }

      print('❌ Sync failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      print('❌ Sync error: $e');
      return false;
    }
  }

  void autoSync() {
    syncTripsWithBot(); // أول مرة عند التشغيل

    // كل ساعة
    Timer.periodic(const Duration(hours: 1), (timer) {
      syncTripsWithBot();
    });
  }
}
