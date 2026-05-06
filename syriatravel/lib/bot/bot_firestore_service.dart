import 'package:cloud_firestore/cloud_firestore.dart';

import 'bot_booking_model.dart';

class BotFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveRequest(BotBookingModel booking) async {
    final docRef = _firestore
        .collection('bot_requests')
        .doc(booking.externalId);

    final doc = await docRef.get();
    if (doc.exists) return;

    await docRef.set({
      ...booking.toFirestore(),
      'syncStatus': booking.tripId.isEmpty ? 'needs_trip_match' : 'ready',
      'savedAt': FieldValue.serverTimestamp(),
    });
  }
}
