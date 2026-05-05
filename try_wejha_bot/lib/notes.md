متفقين.

1) بالنسبة لتنظيف المعمارية backend الخفيف  
   الفكرة التي سنعتمدها لاحقًا (احفظها كـ baseline للفريق):

- **طبقة Telegram bot**:
    - كلاس `BotRunner` مسؤول عن:
        - long polling (`getUpdates` + offset).
        - تمرير كل update إلى `BotController.handleUpdate`. [core.telegram](https://core.telegram.org/bots/api)
    - كلاس `BotController` مسؤول عن:
        - تفكيك الـ update (message, callback_query).
        - توجيهها إلى:
            - `MessageHandler` (أوامر ونصوص).
            - `CallbackHandler` (inline keyboard). [github](https://github.com/python-telegram-bot/python-telegram-bot/wiki/Architecture)

- **طبقة Domain مشتركة** (يستخدمها البوت والتطبيق):
    - `BookingService`:
        - `createDraft`, `updateDraftStep`, `confirmBooking`, `cancelBooking`, `getUserBookings`.
    - `BookingSessionManager`:
        - يدير `Map<userId, BookingSession>` (مسودات الحجز).
    - `BookingRepository` (interface عام):
        - `Future<List<Booking>> getBookings(userId)`
        - `Future<void> addBooking(Booking)`
        - `Future<void> cancelBooking(bookingId)`
    - Implementations:
        - `InMemoryBookingRepository` للهاكاثون (داخل السيرفر / البوت).
        - لاحقًا `ApiBookingRepository` لو ربطنا مع backend حقيقي. [goo](https://goo.by/blog/telegram-developer-guide)

- **التطبيق Flutter**:
    - يستخدم نفس الـ `BookingService` لكن مع implementation مناسب:
        - إما local-only (للنسخة الحالية).
        - أو HTTP repository مشترك مع البوت عندما نضيف API.

- **backend بسيط مشترك** (عندما تقررون):
    - REST صغير (Node / Dart / Python) فيه endpoints:
        - `GET /trips`
        - `GET /bookings?userId=...`
        - `POST /bookings` (إنشاء حجز).
        - `DELETE /bookings/{id}` (إلغاء).
    - Telegram bot يستدعي هذا الـ backend عبر HTTP.
    - التطبيق Flutter يستدعي نفس الـ backend.
    - Dashboard (Flutter Web أو صفحة HTML) تقرأ من نفس الـ backend. [merge](https://merge.rocks/blog/how-to-build-a-telegram-mini-app-your-telegram-mini-apps-guide)

هذا نمط قياسي: البوت مجرد عميل (client) يتكلم مع backend، وليس هو نفسه مصدر البيانات النهائي. [davidloor](https://davidloor.com/en/blog/telegram-bot-prosody-analysis-backend-architecture)

2) عن موضوع الحفظ  
   أنا ما أملك "ذاكرة طويلة الأمد" خارج هذه الجلسة، لكنك تقدر تضمن أننا لا نضيع هذه القرارات بهذه الطرق:

- احتفظ بهذه النقاط في:
    - ملف `README` داخل مشروعكم.
    - أو `notes.md` تكتب فيه:
        - Architecture plan.
        - TODO: extract BotController, BookingService, BookingRepository.
        - TODO: design simple backend if time allows.
- غدًا عندما ترجع، انسخ لي النص أو أهم أجزاءه، أو قل لي:
    - "نطبق الخطة اللي اتفقنا عليها أمس: BotRunner + BotController + BookingService + Backend بسيط"  
      وسأبني الكود والمعمارية مباشرة على هذا الأساس.

الخلاصة:
- اتفقنا أن:
    - `main.dart` لن يبقى محشوًا بكل منطق البوت، بل سنفصله إلى طبقة bot + domain.
    - سنعتبر backend بسيط خيار مستهدف، ونربط عليه التطبيق + البوت + dashboard عندما يسمح الوقت، بدل محاولة تهكير مشاركة البيانات بدون نقطة مركزية. [core.telegram](https://core.telegram.org)

غدًا عندما ترجع:
- نبدأ بـ خطوة واحدة واضحة:  
  نعمل refactor لأول جزء: استخراج `BotController` + `MessageHandler` + `CallbackHandler` من `main.dart`، بدون تغيير سلوك البوت.  
  بعدها ننظر في شكل الـ backend البسيط الأنسب لكم (Dart ولا Node ولا Python) حسب ما يناسب فريقك.