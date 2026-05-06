import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/bot/bot_controller.dart';
import '../lib/services/telegram_api_service.dart';

void main() async {
  final telegramApiService = TelegramApiService();
  final botController = BotController(telegramApiService);

  try {
    await telegramApiService.setMyCommands();
  } catch (e) {
    print('Failed to set commands: $e');
  }

  final router = Router();

  router.get('/', (Request request) {
    return Response.ok('Bot server is running');
  });

  router.post('/webhook', (Request request) async {
    try {
      final body = await request.readAsString();
      final update = jsonDecode(body) as Map<String, dynamic>;

      await botController.handleUpdate(update);

      return Response.ok('OK');
    } catch (e) {
      print('Webhook error: $e');
      return Response.internalServerError(body: 'Error: $e');
    }
  });

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final server = await serve(handler, InternetAddress.anyIPv4, port);

  print('Server running on port ${server.port}');
}
