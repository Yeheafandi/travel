import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/telegram_config.dart';

class TelegramApiService {
  Map<String, dynamic> _decodeResponse(
      http.Response response, String methodName) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final description = data['description']?.toString() ?? 'Unknown error';
      throw Exception('Failed to call $methodName: $description');
    }

    final ok = data['ok'] == true;
    if (!ok) {
      final description = data['description']?.toString() ?? 'Unknown error';
      throw Exception('Telegram API error in $methodName: $description');
    }

    return data;
  }

  Future<Map<String, dynamic>> _post(
    String method, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('${TelegramConfig.baseUrl}/$method');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );

    return _decodeResponse(response, method);
  }

  Future<Map<String, dynamic>> _get(
    String method, {
    Map<String, String>? queryParameters,
  }) async {
    final url = Uri.parse(
      '${TelegramConfig.baseUrl}/$method',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(url);

    return _decodeResponse(response, method);
  }

  Future<Map<String, dynamic>> getUpdates({
    int? offset,
    int timeout = 30,
    List<String>? allowedUpdates,
  }) async {
    final queryParameters = <String, String>{
      'timeout': timeout.toString(),
      if (offset != null) 'offset': offset.toString(),
      if (allowedUpdates != null) 'allowed_updates': jsonEncode(allowedUpdates),
    };

    return _get('getUpdates', queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> setMyCommands() async {
    final body = {
      'commands': [
        {'command': 'start', 'description': 'بدء تشغيل البوت'},
        {'command': 'book', 'description': 'حجز رحلة جديدة'},
        {'command': 'trips', 'description': 'عرض الرحلات المتاحة'},
        {'command': 'mybookings', 'description': 'عرض حجوزاتي'},
        {'command': 'cancelbooking', 'description': 'إلغاء حجز مؤكد'},
      ],
    };

    return _post('setMyCommands', body: body);
  }

  Future<Map<String, dynamic>> sendMessage({
    required int chatId,
    required String text,
    Map<String, dynamic>? replyMarkup,
    String? parseMode,
  }) async {
    final body = {
      'chat_id': chatId,
      'text': text,
      if (replyMarkup != null) 'reply_markup': replyMarkup,
      if (parseMode != null) 'parse_mode': parseMode,
    };

    return _post('sendMessage', body: body);
  }

  Future<Map<String, dynamic>> sendMainMenu({required int chatId}) async {
    return sendMessage(
      chatId: chatId,
      text: 'مرحباً بك في بوت حجز النقل.\nاختر خدمة من القائمة التالية:',
      replyMarkup: {
        'keyboard': [
          [
            {'text': 'حجز رحلة'},
            {'text': 'الرحلات المتاحة'},
          ],
          [
            {'text': 'الاستعلام عن رحلة'},
            {'text': 'حجوزاتي'},
          ],
          [
            {'text': 'إلغاء حجز مؤكد'},
            {'text': 'القائمة'},
          ],
        ],
        'resize_keyboard': true,
        'one_time_keyboard': false,
      },
    );
  }

  Future<Map<String, dynamic>> removeReplyKeyboard({
    required int chatId,
    required String text,
  }) async {
    return sendMessage(
      chatId: chatId,
      text: text,
      replyMarkup: {'remove_keyboard': true},
    );
  }

  Future<Map<String, dynamic>> sendDepartureOptions({
    required int chatId,
  }) async {
    return sendMessage(
      chatId: chatId,
      text: 'اختر مدينة الانطلاق:',
      replyMarkup: {
        'inline_keyboard': [
          [
            {'text': 'دمشق', 'callback_data': 'dep_damascus'},
            {'text': 'حمص', 'callback_data': 'dep_homs'},
          ],
          [
            {'text': 'حلب', 'callback_data': 'dep_aleppo'},
            {'text': 'طرطوس', 'callback_data': 'dep_tartous'},
          ],
          [
            {'text': 'رجوع للقائمة', 'callback_data': 'back_main'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendDestinationOptions({
    required int chatId,
    required int messageId,
    required String departure,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: 'تم اختيار مدينة الانطلاق: $departure\nاختر الوجهة:',
      replyMarkup: {
        'inline_keyboard': [
          [
            {'text': 'دمشق', 'callback_data': 'dest_damascus'},
            {'text': 'حمص', 'callback_data': 'dest_homs'},
          ],
          [
            {'text': 'حلب', 'callback_data': 'dest_aleppo'},
            {'text': 'طرطوس', 'callback_data': 'dest_tartous'},
          ],
          [
            {'text': 'رجوع', 'callback_data': 'back_departure'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendTimeOptions({
    required int chatId,
    required int messageId,
    required String departure,
    required String destination,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: 'الانطلاق: $departure\n'
          'الوجهة: $destination\n'
          'اختر موعد الرحلة:',
      replyMarkup: {
        'inline_keyboard': [
          [
            {'text': '08:00', 'callback_data': 'time_0800'},
            {'text': '10:30', 'callback_data': 'time_1030'},
          ],
          [
            {'text': '13:00', 'callback_data': 'time_1300'},
            {'text': '16:45', 'callback_data': 'time_1645'},
          ],
          [
            {'text': 'رجوع', 'callback_data': 'back_destination'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendBookingConfirmation({
    required int chatId,
    required int messageId,
    required String departure,
    required String destination,
    required String time,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: 'راجع تفاصيل الحجز:\n'
          'من: $departure\n'
          'إلى: $destination\n'
          'الوقت: $time\n\n'
          'هل تريد تأكيد الحجز؟',
      replyMarkup: {
        'inline_keyboard': [
          [
            {'text': 'تأكيد الحجز', 'callback_data': 'confirm_booking'},
          ],
          [
            {'text': 'إلغاء', 'callback_data': 'cancel_booking'},
            {'text': 'رجوع', 'callback_data': 'back_time'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendTripsList({
    required int chatId,
    required List<Map<String, String>> trips,
    required String mode,
  }) async {
    final keyboard = trips.map((trip) {
      return [
        {
          'text':
              '${trip['departure']} → ${trip['destination']} | ${trip['time']}',
          'callback_data': '$mode:${trip['id']}',
        },
      ];
    }).toList();

    keyboard.add([
      {'text': 'رجوع للقائمة', 'callback_data': 'back_main'},
    ]);

    return sendMessage(
      chatId: chatId,
      text: mode == 'view'
          ? 'اختر رحلة لعرض تفاصيلها:'
          : 'اختر رحلة للاستعلام عن تفاصيلها:',
      replyMarkup: {'inline_keyboard': keyboard},
    );
  }

  Future<Map<String, dynamic>> sendTripDetailsWithActions({
    required int chatId,
    required int messageId,
    required String text,
    required String tripId,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: text,
      replyMarkup: {
        'inline_keyboard': [
          [
            {'text': 'احجز هذه الرحلة', 'callback_data': 'book_trip:$tripId'},
          ],
          [
            {'text': 'رجوع للرحلات', 'callback_data': 'back_trips'},
            {'text': 'القائمة', 'callback_data': 'back_main'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendInquiryTripDetails({
    required int chatId,
    required int messageId,
    required String text,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: text,
      replyMarkup: {
        'inline_keyboard': [
          [
            {'text': 'رجوع للاستعلام', 'callback_data': 'back_inquiry'},
            {'text': 'القائمة', 'callback_data': 'back_main'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendCancelableBookings({
    required int chatId,
    required List<Map<String, String>> bookings,
  }) async {
    final keyboard = bookings.map((booking) {
      return [
        {
          'text':
              '${booking['departure']} → ${booking['destination']} | ${booking['time']}',
          'callback_data': 'cancel_select:${booking['bookingId']}',
        },
      ];
    }).toList();

    keyboard.add([
      {'text': 'خروج', 'callback_data': 'back_main'},
    ]);

    return sendMessage(
      chatId: chatId,
      text: 'اختر الحجز الذي تريد إلغاءه:',
      replyMarkup: {'inline_keyboard': keyboard},
    );
  }

  Future<Map<String, dynamic>> sendCancelBookingConfirmation({
    required int chatId,
    required int messageId,
    required Map<String, String> booking,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: 'هل تريد إلغاء هذا الحجز؟\n'
          'رقم الحجز: ${booking['bookingId']}\n'
          'من: ${booking['departure']}\n'
          'إلى: ${booking['destination']}\n'
          'الوقت: ${booking['time']}',
      replyMarkup: {
        'inline_keyboard': [
          [
            {
              'text': 'تأكيد الإلغاء',
              'callback_data': 'cancel_confirm:${booking['bookingId']}',
            },
          ],
          [
            {'text': 'رجوع', 'callback_data': 'cancel_back_list'},
            {'text': 'خروج', 'callback_data': 'back_main'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendBookingsListWithActions({
    required int chatId,
    required List<Map<String, String>> bookings,
  }) async {
    if (bookings.isEmpty) {
      return sendMessage(chatId: chatId, text: 'لا توجد حجوزات مؤكدة حالياً.');
    }

    final keyboard = bookings.map((booking) {
      return [
        {
          'text':
              '${booking['departure']} → ${booking['destination']} | ${booking['time']}',
          'callback_data': 'booking_view:${booking['bookingId']}',
        },
      ];
    }).toList();

    keyboard.add([
      {'text': 'إلغاء حجز', 'callback_data': 'open_cancel_bookings'},
      {'text': 'القائمة', 'callback_data': 'back_main'},
    ]);

    return sendMessage(
      chatId: chatId,
      text: 'حجوزاتك الحالية، اختر حجزًا لعرضه:',
      replyMarkup: {'inline_keyboard': keyboard},
    );
  }

  Future<Map<String, dynamic>> sendSingleBookingDetails({
    required int chatId,
    required int messageId,
    required Map<String, String> booking,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: 'تفاصيل الحجز:\n'
          'رقم الحجز: ${booking['bookingId']}\n'
          'من: ${booking['departure']}\n'
          'إلى: ${booking['destination']}\n'
          'الوقت: ${booking['time']}\n'
          'الحالة: ${booking['status']}',
      replyMarkup: {
        'inline_keyboard': [
          [
            {
              'text': 'إلغاء هذا الحجز',
              'callback_data': 'cancel_select:${booking['bookingId']}',
            },
          ],
          [
            {'text': 'رجوع لحجوزاتي', 'callback_data': 'back_bookings'},
            {'text': 'القائمة', 'callback_data': 'back_main'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> answerCallbackQuery({
    required String callbackQueryId,
    String? text,
  }) async {
    final body = {
      'callback_query_id': callbackQueryId,
      if (text != null) 'text': text,
    };

    return _post('answerCallbackQuery', body: body);
  }

  Future<Map<String, dynamic>> editMessageText({
    required int chatId,
    required int messageId,
    required String text,
    Map<String, dynamic>? replyMarkup,
  }) async {
    final body = {
      'chat_id': chatId,
      'message_id': messageId,
      'text': text,
      if (replyMarkup != null) 'reply_markup': replyMarkup,
    };

    return _post('editMessageText', body: body);
  }

  Future<Map<String, dynamic>> sendPersonalInfoStep({
    required int chatId,
    required String step,
  }) async {
    return sendMessage(
      chatId: chatId,
      text: step == 'name'
          ? 'أرسل اسم المسافر الكامل:'
          : step == 'phone'
              ? 'أرسل رقم الجوال (مثال: 093xxxxxxxx):'
              : 'أرسل الرقم الوطني (10 أرقام):',
      replyMarkup: {'remove_keyboard': true},
    );
  }

  Future<Map<String, dynamic>> sendPersonalInfoConfirmation({
    required int chatId,
    required int messageId,
    required String departure,
    required String destination,
    required String time,
    required String name,
    required String phone,
    required String nationalId,
  }) async {
    return sendMessage(
      chatId: chatId,
      text: '📋 مراجعة الحجز:\n\n'
          '🚗 من: $departure\n'
          '📍 إلى: $destination\n'
          '🕐 الوقت: $time\n\n'
          '👤 اسم المسافر: $name\n'
          '📱 الجوال: $phone\n'
          '🆔 الرقم الوطني: $nationalId\n\n'
          'هل تريد تأكيد الحجز؟',
      replyMarkup: {
        'inline_keyboard': [
          [
            {'text': 'تأكيد الحجز ✅', 'callback_data': 'confirm_booking'},
          ],
          [
            {'text': 'إلغاء', 'callback_data': 'cancel_booking'},
            {'text': 'رجوع للمعلومات', 'callback_data': 'back_personal'},
          ],
        ],
      },
    );
  }

  Future<Map<String, dynamic>> sendBookingsWithPersonalInfo({
    required int chatId,
    required List<Map<String, String>> bookings,
  }) async {
    if (bookings.isEmpty) {
      return sendMessage(chatId: chatId, text: 'لا توجد حجوزات حالياً.');
    }

    final keyboard = bookings.map((booking) {
      return [
        {
          'text':
              '${booking['departure']} → ${booking['destination']} | ${booking['time']} | ${booking['name']}',
          'callback_data': 'booking_view:${booking['bookingId']}',
        },
      ];
    }).toList();

    keyboard.add([
      {'text': 'إلغاء حجز', 'callback_data': 'open_cancel_bookings'},
      {'text': 'القائمة الرئيسية', 'callback_data': 'back_main'},
    ]);

    return sendMessage(
      chatId: chatId,
      text: 'حجوزاتك الحالية (مع أسماء المسافرين):',
      replyMarkup: {'inline_keyboard': keyboard},
    );
  }

  Future<Map<String, dynamic>> sendSingleBookingWithPersonalInfo({
    required int chatId,
    required int messageId,
    required Map<String, String> booking,
  }) async {
    return editMessageText(
      chatId: chatId,
      messageId: messageId,
      text: 'تفاصيل الحجز:\n\n'
          '🆔 رقم الحجز: ${booking['bookingId']}\n'
          '🚗 من: ${booking['departure']}\n'
          '📍 إلى: ${booking['destination']}\n'
          '🕐 الوقت: ${booking['time']}\n'
          '👤 اسم المسافر: ${booking['name']}\n'
          '📱 الجوال: ${booking['phone']}\n'
          '🆔 الرقم الوطني: ${booking['nationalId']}\n'
          '📊 الحالة: ${booking['status']}',
      replyMarkup: {
        'inline_keyboard': [
          [
            {
              'text': 'إلغاء هذا الحجز',
              'callback_data': 'cancel_select:${booking['bookingId']}',
            },
          ],
          [
            {'text': 'رجوع لحجوزاتي', 'callback_data': 'back_bookings'},
            {'text': 'القائمة الرئيسية', 'callback_data': 'back_main'},
          ],
        ],
      },
    );
  }
}
