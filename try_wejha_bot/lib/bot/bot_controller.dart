import '../services/telegram_api_service.dart';

class BotController {
  BotController(this.telegramApiService);

  final TelegramApiService telegramApiService;

  final Map<int, Map<String, String>> bookingDrafts = {};
  final Map<int, List<Map<String, String>>> confirmedBookings = {};

  final List<Map<String, String>> availableTrips = [
    {
      'id': 'T101',
      'departure': 'دمشق',
      'destination': 'حمص',
      'time': '08:00',
      'status': 'متاحة',
      'seats': '12',
    },
    {
      'id': 'T102',
      'departure': 'حمص',
      'destination': 'طرطوس',
      'time': '10:30',
      'status': 'متاحة',
      'seats': '8',
    },
    {
      'id': 'T103',
      'departure': 'حلب',
      'destination': 'دمشق',
      'time': '13:00',
      'status': 'متاحة',
      'seats': '5',
    },
    {
      'id': 'T104',
      'departure': 'طرطوس',
      'destination': 'حمص',
      'time': '16:45',
      'status': 'متاحة',
      'seats': '10',
    },
  ];

  String mapDeparture(String callbackData) {
    switch (callbackData) {
      case 'dep_damascus':
        return 'دمشق';
      case 'dep_homs':
        return 'حمص';
      case 'dep_aleppo':
        return 'حلب';
      case 'dep_tartous':
        return 'طرطوس';
      default:
        return 'غير معروف';
    }
  }

  String mapDestination(String callbackData) {
    switch (callbackData) {
      case 'dest_damascus':
        return 'دمشق';
      case 'dest_homs':
        return 'حمص';
      case 'dest_aleppo':
        return 'حلب';
      case 'dest_tartous':
        return 'طرطوس';
      default:
        return 'غير معروف';
    }
  }

  String mapTime(String callbackData) {
    switch (callbackData) {
      case 'time_0800':
        return '08:00';
      case 'time_1030':
        return '10:30';
      case 'time_1300':
        return '13:00';
      case 'time_1645':
        return '16:45';
      default:
        return 'غير معروف';
    }
  }

  String generateBookingId(int chatId) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = now.substring(now.length - 6);
    return 'BK-$chatId-$suffix';
  }

  Map<String, String>? findTripById(String tripId) {
    try {
      return availableTrips.firstWhere((trip) => trip['id'] == tripId);
    } catch (_) {
      return null;
    }
  }

  Map<String, String>? findBookingById(int chatId, String bookingId) {
    final userBookings = confirmedBookings[chatId] ?? [];
    try {
      return userBookings.firstWhere(
        (booking) => booking['bookingId'] == bookingId,
      );
    } catch (_) {
      return null;
    }
  }

  String buildTripDetailsText(Map<String, String> trip) {
    return 'تفاصيل الرحلة:\n'
        'رقم الرحلة: ${trip['id']}\n'
        'من: ${trip['departure']}\n'
        'إلى: ${trip['destination']}\n'
        'الوقت: ${trip['time']}\n'
        'المقاعد المتاحة: ${trip['seats']}\n'
        'الحالة: ${trip['status']}';
  }

  String buildInquiryTripText(Map<String, String> trip) {
    return 'نتيجة الاستعلام عن الرحلة:\n'
        'رقم الرحلة: ${trip['id']}\n'
        'الانطلاق: ${trip['departure']}\n'
        'الوجهة: ${trip['destination']}\n'
        'موعد المغادرة: ${trip['time']}\n'
        'المقاعد المتبقية: ${trip['seats']}\n'
        'حالة الرحلة: ${trip['status']}';
  }

  Future<void> openTripsList(int chatId) async {
    await telegramApiService.sendTripsList(
      chatId: chatId,
      trips: availableTrips,
      mode: 'view',
    );
  }

  Future<void> openInquiryList(int chatId) async {
    await telegramApiService.sendTripsList(
      chatId: chatId,
      trips: availableTrips,
      mode: 'inquiry',
    );
  }

  Future<void> openBookingsList(int chatId) async {
    final bookings = confirmedBookings[chatId] ?? [];
    await telegramApiService.sendBookingsWithPersonalInfo(
      chatId: chatId,
      bookings: bookings,
    );
  }

  Future<void> openCancelableBookings(int chatId) async {
    final bookings = confirmedBookings[chatId] ?? [];

    if (bookings.isEmpty) {
      await telegramApiService.sendMessage(
        chatId: chatId,
        text: 'لا توجد حجوزات مؤكدة لإلغائها.',
      );
      return;
    }

    await telegramApiService.sendCancelableBookings(
      chatId: chatId,
      bookings: bookings,
    );
  }

  Future<void> handleUpdate(Map<String, dynamic> update) async {
    final message = update['message'] as Map<String, dynamic>?;
    final callbackQuery = update['callback_query'] as Map<String, dynamic>?;

    if (message != null) {
      await _handleMessage(message);
    } else if (callbackQuery != null) {
      await _handleCallback(callbackQuery);
    }
  }

  Future<void> _handleMessage(Map<String, dynamic> message) async {
    final chat = message['chat'] as Map<String, dynamic>;
    final chatId = chat['id'] as int;
    final text = (message['text'] ?? '').toString().trim();

    bookingDrafts.putIfAbsent(chatId, () => <String, String>{});
    final draft = bookingDrafts[chatId]!;
    final waitingFor = draft['waitingFor'];

    if (waitingFor != null) {
      if (waitingFor == 'name') {
        draft['name'] = text;
        draft['waitingFor'] = 'phone';

        await telegramApiService.sendPersonalInfoStep(
          chatId: chatId,
          step: 'phone',
        );
        return;
      }

      if (waitingFor == 'phone') {
        draft['phone'] = text;
        draft['waitingFor'] = 'nationalId';

        await telegramApiService.sendPersonalInfoStep(
          chatId: chatId,
          step: 'nationalId',
        );
        return;
      }

      if (waitingFor == 'nationalId') {
        draft['nationalId'] = text;
        draft.remove('waitingFor');

        final departure = draft['departure'] ?? 'غير محدد';
        final destination = draft['destination'] ?? 'غير محدد';
        final time = draft['time'] ?? 'غير محدد';
        final name = draft['name'] ?? 'غير محدد';
        final phone = draft['phone'] ?? 'غير محدد';
        final nationalId = draft['nationalId'] ?? 'غير محدد';

        await telegramApiService.sendMessage(
          chatId: chatId,
          text:
              '📋 مراجعة الحجز:\n\n'
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
        return;
      }
    }

    if (text == '/start' || text == '/menu' || text == 'القائمة') {
      bookingDrafts.remove(chatId);
      await telegramApiService.sendMainMenu(chatId: chatId);
    } else if (text == '/book' || text == 'حجز رحلة') {
      bookingDrafts[chatId] = {};
      await telegramApiService.sendDepartureOptions(chatId: chatId);
    } else if (text == '/trips' || text == 'الرحلات المتاحة') {
      await openTripsList(chatId);
    } else if (text == 'الاستعلام عن رحلة') {
      await openInquiryList(chatId);
    } else if (text == '/mybookings' || text == 'حجوزاتي') {
      await openBookingsList(chatId);
    } else if (text == '/cancelbooking' || text == 'إلغاء حجز مؤكد') {
      await openCancelableBookings(chatId);
    } else {
      final lowerText = text.toLowerCase().trim();

      if (lowerText.contains('حجز') ||
          lowerText.contains('book') ||
          lowerText.contains('حج') ||
          lowerText == '1') {
        bookingDrafts[chatId] = {};
        await telegramApiService.sendDepartureOptions(chatId: chatId);
      } else if (lowerText.contains('رحل') ||
          lowerText.contains('trip') ||
          lowerText == '2') {
        await openTripsList(chatId);
      } else if (lowerText.contains('استعلام') ||
          lowerText.contains('inquir') ||
          lowerText == '3') {
        await openInquiryList(chatId);
      } else if (lowerText.contains('حجوز') ||
          lowerText.contains('booking') ||
          lowerText == '4') {
        await openBookingsList(chatId);
      } else if (lowerText.contains('إلغاء') ||
          lowerText.contains('cancel') ||
          lowerText == '5') {
        await openCancelableBookings(chatId);
      } else {
        await telegramApiService.sendMainMenu(chatId: chatId);
      }
    }
  }

  Future<void> _handleCallback(Map<String, dynamic> callbackQuery) async {
    final callbackQueryId = callbackQuery['id'].toString();
    final callbackData = callbackQuery['data'].toString();
    final callbackMessage = callbackQuery['message'] as Map<String, dynamic>;
    final chat = callbackMessage['chat'] as Map<String, dynamic>;
    final chatId = chat['id'] as int;
    final messageId = callbackMessage['message_id'] as int;

    bookingDrafts.putIfAbsent(chatId, () => <String, String>{});

    if (callbackData == 'back_main') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'عودة للقائمة الرئيسية',
      );

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text: 'تمت العودة إلى القائمة الرئيسية.',
      );
    } else if (callbackData == 'back_departure') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع لاختيار الانطلاق',
      );

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
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
    } else if (callbackData == 'back_destination') {
      final departure = bookingDrafts[chatId]!['departure'] ?? 'غير محدد';

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع لاختيار الوجهة',
      );

      await telegramApiService.sendDestinationOptions(
        chatId: chatId,
        messageId: messageId,
        departure: departure,
      );
    } else if (callbackData == 'back_time') {
      final departure = bookingDrafts[chatId]!['departure'] ?? 'غير محدد';
      final destination = bookingDrafts[chatId]!['destination'] ?? 'غير محدد';

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع لاختيار الوقت',
      );

      await telegramApiService.sendTimeOptions(
        chatId: chatId,
        messageId: messageId,
        departure: departure,
        destination: destination,
      );
    } else if (callbackData == 'back_personal') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع للمعلومات الشخصية',
      );

      final draft = bookingDrafts[chatId]!;
      draft['waitingFor'] = 'name';
      draft.remove('name');
      draft.remove('phone');
      draft.remove('nationalId');

      await telegramApiService.sendPersonalInfoStep(
        chatId: chatId,
        step: 'name',
      );
    } else if (callbackData == 'back_trips') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع لقائمة الرحلات',
      );

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text: 'اختر رحلة لعرض تفاصيلها:',
        replyMarkup: {
          'inline_keyboard': [
            for (final trip in availableTrips)
              [
                {
                  'text':
                      '${trip['departure']} → ${trip['destination']} | ${trip['time']}',
                  'callback_data': 'view:${trip['id']}',
                },
              ],
            [
              {'text': 'رجوع للقائمة', 'callback_data': 'back_main'},
            ],
          ],
        },
      );
    } else if (callbackData == 'back_inquiry') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع لقائمة الاستعلام',
      );

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text: 'اختر رحلة للاستعلام عن تفاصيلها:',
        replyMarkup: {
          'inline_keyboard': [
            for (final trip in availableTrips)
              [
                {
                  'text':
                      '${trip['departure']} → ${trip['destination']} | ${trip['time']}',
                  'callback_data': 'inquiry:${trip['id']}',
                },
              ],
            [
              {'text': 'رجوع للقائمة', 'callback_data': 'back_main'},
            ],
          ],
        },
      );
    } else if (callbackData == 'back_bookings') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع لحجوزاتي',
      );

      final bookings = confirmedBookings[chatId] ?? [];

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text: 'حجوزاتك الحالية، اختر حجزًا لعرضه:',
        replyMarkup: {
          'inline_keyboard': [
            for (final booking in bookings)
              [
                {
                  'text':
                      '${booking['departure']} → ${booking['destination']} | ${booking['time']} | ${booking['name']}',
                  'callback_data': 'booking_view:${booking['bookingId']}',
                },
              ],
            [
              {'text': 'إلغاء حجز', 'callback_data': 'open_cancel_bookings'},
              {'text': 'القائمة', 'callback_data': 'back_main'},
            ],
          ],
        },
      );
    } else if (callbackData == 'cancel_back_list') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'رجوع لقائمة الإلغاء',
      );

      final bookings = confirmedBookings[chatId] ?? [];

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text: 'اختر الحجز الذي تريد إلغاءه:',
        replyMarkup: {
          'inline_keyboard': [
            for (final booking in bookings)
              [
                {
                  'text':
                      '${booking['departure']} → ${booking['destination']} | ${booking['time']} | ${booking['name']}',
                  'callback_data': 'cancel_select:${booking['bookingId']}',
                },
              ],
            [
              {'text': 'خروج', 'callback_data': 'back_main'},
            ],
          ],
        },
      );
    } else if (callbackData.startsWith('dep_')) {
      final selectedDeparture = mapDeparture(callbackData);
      bookingDrafts[chatId]!['departure'] = selectedDeparture;

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم اختيار $selectedDeparture',
      );

      await telegramApiService.sendDestinationOptions(
        chatId: chatId,
        messageId: messageId,
        departure: selectedDeparture,
      );
    } else if (callbackData.startsWith('dest_')) {
      final selectedDestination = mapDestination(callbackData);
      final departure = bookingDrafts[chatId]!['departure'] ?? 'غير محدد';

      bookingDrafts[chatId]!['destination'] = selectedDestination;

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم اختيار الوجهة $selectedDestination',
      );

      await telegramApiService.sendTimeOptions(
        chatId: chatId,
        messageId: messageId,
        departure: departure,
        destination: selectedDestination,
      );
    } else if (callbackData.startsWith('time_')) {
      final selectedTime = mapTime(callbackData);

      bookingDrafts[chatId]!['time'] = selectedTime;
      bookingDrafts[chatId]!['waitingFor'] = 'name';

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم اختيار الموعد $selectedTime',
      );

      await telegramApiService.sendPersonalInfoStep(
        chatId: chatId,
        step: 'name',
      );
    } else if (callbackData == 'confirm_booking') {
      final draft = bookingDrafts[chatId] ?? {};
      final departure = draft['departure'] ?? 'غير محدد';
      final destination = draft['destination'] ?? 'غير محدد';
      final time = draft['time'] ?? 'غير محدد';
      final name = draft['name'] ?? 'غير محدد';
      final phone = draft['phone'] ?? 'غير محدد';
      final nationalId = draft['nationalId'] ?? 'غير محدد';
      final bookingId = generateBookingId(chatId);

      final booking = {
        'bookingId': bookingId,
        'departure': departure,
        'destination': destination,
        'time': time,
        'name': name,
        'phone': phone,
        'nationalId': nationalId,
        'status': 'مؤكد',
      };

      confirmedBookings.putIfAbsent(chatId, () => []);
      confirmedBookings[chatId]!.add(booking);

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم تأكيد الحجز بنجاح',
      );

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text:
            '✅ تم الحجز بنجاح!\n\n'
            '🆔 رقم الحجز: $bookingId\n'
            '🚗 $departure → $destination\n'
            '🕐 $time\n'
            '👤 $name\n'
            '📱 $phone\n'
            '🆔 $nationalId\n\n'
            'الحجز محفوظ في حجوزاتك.',
      );

      bookingDrafts.remove(chatId);

      await telegramApiService.sendMessage(
        chatId: chatId,
        text: 'يمكنك الآن حجز رحلة أخرى أو عرض حجوزاتك.',
      );
    } else if (callbackData == 'cancel_booking') {
      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم إلغاء العملية',
      );

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text: 'تم إلغاء الحجز.',
      );

      bookingDrafts.remove(chatId);

      await telegramApiService.sendMessage(
        chatId: chatId,
        text: 'تم إلغاء العملية. يمكنك اختيار خدمة أخرى من القائمة.',
      );
    } else if (callbackData.startsWith('view:')) {
      final tripId = callbackData.split(':').last;
      final trip = findTripById(tripId);

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم فتح تفاصيل الرحلة',
      );

      if (trip == null) {
        await telegramApiService.editMessageText(
          chatId: chatId,
          messageId: messageId,
          text: 'لم يتم العثور على الرحلة المطلوبة.',
        );
      } else {
        await telegramApiService.sendTripDetailsWithActions(
          chatId: chatId,
          messageId: messageId,
          text: buildTripDetailsText(trip),
          tripId: tripId,
        );
      }
    } else if (callbackData.startsWith('inquiry:')) {
      final tripId = callbackData.split(':').last;
      final trip = findTripById(tripId);

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم تنفيذ الاستعلام',
      );

      if (trip == null) {
        await telegramApiService.editMessageText(
          chatId: chatId,
          messageId: messageId,
          text: 'تعذر العثور على بيانات الرحلة.',
        );
      } else {
        await telegramApiService.sendInquiryTripDetails(
          chatId: chatId,
          messageId: messageId,
          text: buildInquiryTripText(trip),
        );
      }
    } else if (callbackData.startsWith('book_trip:')) {
      final tripId = callbackData.split(':').last;
      final trip = findTripById(tripId);

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم تحويل الرحلة إلى نموذج الحجز',
      );

      if (trip == null) {
        await telegramApiService.editMessageText(
          chatId: chatId,
          messageId: messageId,
          text: 'تعذر بدء الحجز لهذه الرحلة.',
        );
      } else {
        bookingDrafts[chatId] = {
          'departure': trip['departure'] ?? 'غير محدد',
          'destination': trip['destination'] ?? 'غير محدد',
          'time': trip['time'] ?? 'غير محدد',
          'waitingFor': 'name',
        };

        await telegramApiService.sendPersonalInfoStep(
          chatId: chatId,
          step: 'name',
        );
      }
    } else if (callbackData == 'open_cancel_bookings') {
      final bookings = confirmedBookings[chatId] ?? [];

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'فتح قائمة إلغاء الحجوزات',
      );

      if (bookings.isEmpty) {
        await telegramApiService.editMessageText(
          chatId: chatId,
          messageId: messageId,
          text: 'لا توجد حجوزات مؤكدة لإلغائها.',
        );
      } else {
        await telegramApiService.editMessageText(
          chatId: chatId,
          messageId: messageId,
          text: 'اختر الحجز الذي تريد إلغاءه:',
          replyMarkup: {
            'inline_keyboard': [
              for (final booking in bookings)
                [
                  {
                    'text':
                        '${booking['departure']} → ${booking['destination']} | ${booking['time']} | ${booking['name']}',
                    'callback_data': 'cancel_select:${booking['bookingId']}',
                  },
                ],
              [
                {'text': 'خروج', 'callback_data': 'back_main'},
              ],
            ],
          },
        );
      }
    } else if (callbackData.startsWith('booking_view:')) {
      final bookingId = callbackData.split(':').last;
      final booking = findBookingById(chatId, bookingId);

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم فتح تفاصيل الحجز',
      );

      if (booking == null) {
        await telegramApiService.editMessageText(
          chatId: chatId,
          messageId: messageId,
          text: 'لم يتم العثور على الحجز المطلوب.',
        );
      } else {
        await telegramApiService.sendSingleBookingWithPersonalInfo(
          chatId: chatId,
          messageId: messageId,
          booking: booking,
        );
      }
    } else if (callbackData.startsWith('cancel_select:')) {
      final bookingId = callbackData.split(':').last;
      final booking = findBookingById(chatId, bookingId);

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'اخترت حجزًا للإلغاء',
      );

      if (booking == null) {
        await telegramApiService.editMessageText(
          chatId: chatId,
          messageId: messageId,
          text: 'تعذر العثور على الحجز المحدد.',
        );
      } else {
        await telegramApiService.sendCancelBookingConfirmation(
          chatId: chatId,
          messageId: messageId,
          booking: booking,
        );
      }
    } else if (callbackData.startsWith('cancel_confirm:')) {
      final bookingId = callbackData.split(':').last;
      final bookings = confirmedBookings[chatId] ?? [];

      bookings.removeWhere((booking) => booking['bookingId'] == bookingId);

      await telegramApiService.answerCallbackQuery(
        callbackQueryId: callbackQueryId,
        text: 'تم إلغاء الحجز المؤكد',
      );

      await telegramApiService.editMessageText(
        chatId: chatId,
        messageId: messageId,
        text: 'تم إلغاء الحجز رقم $bookingId بنجاح.',
      );

      await telegramApiService.sendMessage(
        chatId: chatId,
        text: 'تم تحديث حجوزاتك بعد الإلغاء.',
      );
    }
  }
}
