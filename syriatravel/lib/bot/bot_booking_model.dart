class BotBookingModel {
  final String externalId;
  final String passengerName;
  final String phone;
  final String from;
  final String to;
  final String tripId;
  final String status;
  final String source;
  final String? notes;
  final DateTime? createdAt;

  const BotBookingModel({
    required this.externalId,
    required this.passengerName,
    required this.phone,
    required this.from,
    required this.to,
    required this.tripId,
    this.status = 'pending',
    this.source = 'telegram_bot',
    this.notes,
    this.createdAt,
  });

  factory BotBookingModel.fromJson(Map<String, dynamic> json) {
    return BotBookingModel(
      externalId: (json['external_id'] ?? json['id'] ?? '').toString(),
      passengerName: (json['passenger_name'] ?? json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      from: (json['from'] ?? '').toString(),
      to: (json['to'] ?? '').toString(),
      tripId: (json['trip_id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      source: (json['source'] ?? 'telegram_bot').toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'externalId': externalId,
      'passengerName': passengerName,
      'phone': phone,
      'from': from,
      'to': to,
      'tripId': tripId,
      'status': status,
      'source': source,
      'notes': notes,
      'botCreatedAt': createdAt?.toIso8601String(),
    };
  }
}
