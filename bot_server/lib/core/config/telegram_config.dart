import 'dart:io';

class TelegramConfig {
  static String get botToken {
    final token = Platform.environment['BOT_TOKEN'];

    if (token == null || token.trim().isEmpty) {
      throw Exception(
        'BOT_TOKEN is not set. '
        'Set it as an environment variable before running the server.',
      );
    }

    return token.trim();
  }

  static String get baseUrl => 'https://api.telegram.org/bot$botToken';
}
