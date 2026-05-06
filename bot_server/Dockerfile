# استخدم صورة Dart الرسمية
FROM dart:stable

# مجلد العمل داخل الحاوية
WORKDIR /app

# نسخ pubspec لحل الـ dependencies
COPY pubspec.* ./
RUN dart pub get

# نسخ باقي السورس
COPY . .

# حل الحزم مرة أخرى في وضع offline (يفيد الكاش)
RUN dart pub get --offline

# المنفذ الافتراضي الذي يستخدمه السيرفر (وممكن Railway يمرر PORT مختلف)
EXPOSE 8080

# أمر التشغيل: نفس ما كنت تشغله محلياً
CMD ["dart", "run", "bin/server.dart"]