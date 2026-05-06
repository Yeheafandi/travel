import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:syriatravel/bot/bot_booking_model.dart';

class BotApiService {
  final String baseUrl;

  BotApiService({required this.baseUrl});

  Future<List<BotBookingModel>> fetchBookings() async {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final uri = Uri.parse('$cleanBaseUrl/bookings');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch bot bookings: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .map((e) => BotBookingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((e) => BotBookingModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Unexpected API response format');
  }
}
