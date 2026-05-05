class TripModel {
  String? id;
  String fromCity;
  String toCity;
  String date;
  String price;
  String driverName;
  String driverId;

  TripModel({this.id, required this.fromCity, required this.toCity, required this.date, required this.price, required this.driverName,required this.driverId,});

  factory TripModel.fromMap(Map<String, dynamic> data, String id) {
    return TripModel(
      id: id,
      fromCity: data['fromCity'] ?? '',
      toCity: data['toCity'] ?? '',
      date: data['date'] ?? '',
      price: data['price'] ?? '',
      driverName: data['driverName'] ?? '',
      driverId: data['driverId'] ??''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromCity': fromCity,
      'toCity': toCity,
      'date': date,
      'price': price,
      'driverId': driverId,
      'driverName': driverName,
      'createdAt': DateTime.now(), 
    };
  }
}