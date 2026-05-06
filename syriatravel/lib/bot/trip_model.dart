class TripModel {
  final String id;
  final String fromCity;
  final String toCity;
  final String time;
  final String status;
  final int totalSeats;
  final int availableSeats;

  const TripModel({
    required this.id,
    required this.fromCity,
    required this.toCity,
    required this.time,
    required this.status,
    required this.totalSeats,
    required this.availableSeats,
  });

  factory TripModel.fromFirestore(Map<String, dynamic> json) {
    final bookedSeats = (json['bookedSeats'] as List?)?.length ?? 0;
    final totalSeats = (json['totalSeats'] as num?)?.toInt() ?? 0;

    return TripModel(
      id: (json['id'] ?? json['busId'] ?? '').toString(),
      fromCity: (json['fromCity'] ?? '').toString(),
      toCity: (json['toCity'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      status: (json['tripStatus'] ?? 'متاحة').toString(),
      totalSeats: totalSeats,
      availableSeats: totalSeats - bookedSeats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'departure': fromCity,
      'destination': toCity,
      'time': time,
      'status': status,
      'seats': availableSeats.toString(),
    };
  }
}
