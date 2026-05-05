class TripModel {
  String? id;
  String fromCity;
  String toCity;
  String date;
  String time; // أضفنا الوقت
  String price;
  String driverName;
  String driverId;
  List<int> reservedSeats; // أضفنا قائمة المقاعد المحجوزة

  TripModel({
    this.id,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.time,
    required this.price,
    required this.driverName,
    required this.driverId,
    required this.reservedSeats, // مطلوبة عند إنشاء الكائن
  });

  factory TripModel.fromMap(Map<String, dynamic> data, String id) {
    return TripModel(
      id: id,
      fromCity: data['fromCity'] ?? '',
      toCity: data['toCity'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '', // جلب الوقت من قاعدة البيانات
      price: data['price'] ?? '',
      driverName: data['driverName'] ?? '',
      driverId: data['driverId'] ?? '',
      // تحويل القائمة القادمة من قاعدة البيانات إلى List<int>
      reservedSeats: List<int>.from(data['reservedSeats'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromCity': fromCity,
      'toCity': toCity,
      'date': date,
      'time': time, // حفظ الوقت
      'price': price,
      'driverId': driverId,
      'driverName': driverName,
      'reservedSeats': reservedSeats, // حفظ قائمة المقاعد
      'createdAt': DateTime.now(),
    };
  }
}