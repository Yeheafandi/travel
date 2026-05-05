import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/trip_model.dart';

class PassengerHomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TripModel>> get tripsStream => _firestore
      .collection('trips')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  TripModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
            )
            .toList(),
      );
}
