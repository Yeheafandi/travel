class TripModel {
  final String id;
  final String departure;
  final String destination;
  final String time;
  final String status;
  final String seats;

  const TripModel({
    required this.id,
    required this.departure,
    required this.destination,
    required this.time,
    required this.status,
    required this.seats,
  });

  factory TripModel.fromFirestore(Map<String, dynamic> json) {
    return TripModel(
      id: (json['id'] ?? '').toString(),
      departure: (json['departure'] ?? '').toString(),
      destination: (json['destination'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      status: (json['status'] ?? 'متاحة').toString(),
      seats: (json['seats'] ?? '0').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departure': departure,
      'destination': destination,
      'time': time,
      'status': status,
      'seats': seats,
    };
  }
}
