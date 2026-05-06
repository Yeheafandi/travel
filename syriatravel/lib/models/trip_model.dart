import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  String? id;
  String fromCity;
  String toCity;
  String date;
  String time;
  String price;
  String driverName;
  String driverId;
  final String busId;
  final int totalSeats;
  List<int> bookedSeats;

  TripModel({
    this.id,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.time,
    required this.price,
    required this.driverName,
    required this.driverId,
    required this.busId,
    required this.totalSeats,
    required this.bookedSeats,
  });

  factory TripModel.fromMap(Map<String, dynamic> data, String id) {
    return TripModel(
      id: id,
      fromCity: data['fromCity'] ?? '',
      toCity: data['toCity'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      price: data['price'] ?? '',
      driverName: data['driverName'] ?? '',
      driverId: data['driverId'] ?? '',
      busId: data['busId'] ?? '',
      totalSeats: data['totalSeats'] ?? 0,
      bookedSeats: List<int>.from(data['bookedSeats'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromCity': fromCity,
      'toCity': toCity,
      'date': date,
      'time': time,
      'price': price,
      'driverId': driverId,
      'driverName': driverName,
      'busId': busId,
      'totalSeats': totalSeats,
      'bookedSeats': bookedSeats,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
