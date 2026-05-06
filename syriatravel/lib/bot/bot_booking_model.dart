class BotBookingModel {
  final String id;
  final String externalId;
  final String bookingId;
  final int chatId;
  final String passengerName;
  final String phone;
  final String nationalId;
  final String from;
  final String to;
  final String time;
  final String tripId;
  final String status;
  final String source;

  const BotBookingModel({
    required this.id,
    required this.externalId,
    required this.bookingId,
    required this.chatId,
    required this.passengerName,
    required this.phone,
    required this.nationalId,
    required this.from,
    required this.to,
    required this.time,
    required this.tripId,
    required this.status,
    required this.source,
  });

  factory BotBookingModel.fromJson(Map<String, dynamic> json) {
    return BotBookingModel(
      id: (json['id'] ?? '').toString(),
      externalId: (json['external_id'] ?? '').toString(),
      bookingId: (json['booking_id'] ?? '').toString(),
      chatId: (json['chat_id'] ?? 0) is int
          ? (json['chat_id'] ?? 0) as int
          : int.tryParse(json['chat_id'].toString()) ?? 0,
      passengerName: (json['passenger_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      nationalId: (json['national_id'] ?? '').toString(),
      from: (json['from'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      tripId: (json['trip_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'externalId': externalId,
      'bookingId': bookingId,
      'chatId': chatId,
      'passengerName': passengerName,
      'phone': phone,
      'nationalId': nationalId,
      'from': from,
      'to': to,
      'time': time,
      'tripId': tripId,
      'status': status,
      'source': source,
    };
  }
}