import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syriatravel/bot/bot_booking_model.dart';

class BotFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> requestExists(String externalId) async {
    final query = await _firestore
        .collection('bot_requests')
        .where('externalId', isEqualTo: externalId)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> saveRequest(BotBookingModel booking) async {
    final exists = await requestExists(booking.externalId);
    if (exists) return;

    await _firestore.collection('bot_requests').add({
      ...booking.toFirestore(),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }
}
