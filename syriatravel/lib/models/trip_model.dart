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
  final String busId;      // تم التأكد من وجودها
  final int totalSeats;    // تم التأكد من وجودها
  List<int> reservedSeats;

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
    required this.reservedSeats,
  });

  // تحويل البيانات القادمة من Firebase إلى كائن TripModel
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
      busId: data['busId'] ?? '', // أضفنا هذا السطر
      totalSeats: data['totalSeats'] ?? 0, // أضفنا هذا السطر
      reservedSeats: List<int>.from(data['reservedSeats'] ?? []),
    );
  }

  // تحويل الكائن إلى Map لحفظه في Firebase
  Map<String, dynamic> toMap() {
    return {
      'fromCity': fromCity,
      'toCity': toCity,
      'date': date,
      'time': time,
      'price': price,
      'driverId': driverId,
      'driverName': driverName,
      'busId': busId,           // أضفنا هذا السطر للحفظ
      'totalSeats': totalSeats, // أضفنا هذا السطر للحفظ
      'reservedSeats': reservedSeats,
      'createdAt': FieldValue.serverTimestamp(), // أفضل من DateTime.now() للسيرفر
    };
  }
}