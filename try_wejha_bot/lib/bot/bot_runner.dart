import '../services/telegram_api_service.dart';
import 'bot_controller.dart';

class BotRunner {
  BotRunner(this.telegramApiService)
    : botController = BotController(telegramApiService);

  final TelegramApiService telegramApiService;
  final BotController botController;

  bool _isRunning = false;
  bool _isStarting = false;
  bool _isProcessing = false;
  int? _lastUpdateId;
  final Set<int> _processedUpdateIds = {};

  bool get isRunning => _isRunning;
  bool get isStarting => _isStarting;

  Future<void> initializeOffset() async {
    final response = await telegramApiService.getUpdates(
      timeout: 0,
      allowedUpdates: ['message', 'callback_query'],
    );

    final updates = response['result'] as List<dynamic>;
    if (updates.isNotEmpty) {
      final lastUpdate = updates.last as Map<String, dynamic>;
      _lastUpdateId = lastUpdate['update_id'] as int;
    }

    try {
      await telegramApiService.setMyCommands();
    } catch (_) {}
  }

  Future<void> start(void Function(String log) onLog) async {
    if (_isRunning || _isStarting) {
      onLog('Bot already running or starting, skipping...');
      return; // ← هذا يحل أي تكرار
    }

    _isStarting = true;
    onLog('Bot is starting automatically...');

    await initializeOffset();

    _isRunning = true;
    _isStarting = false;

    onLog(
      'Bot started...\n'
      'Initial offset: $_lastUpdateId\n'
      'Waiting for new updates...',
    );

    while (_isRunning) {
      try {
        final response = await telegramApiService.getUpdates(
          offset: _lastUpdateId != null ? _lastUpdateId! + 1 : null,
          timeout: 30,
          allowedUpdates: ['message', 'callback_query'],
        );

        final updates = response['result'] as List<dynamic>;

        if (updates.isEmpty) {
          continue;
        }

        for (final update in updates) {
          if (!_isRunning) break;

          final updateMap = update as Map<String, dynamic>;
          final currentUpdateId = updateMap['update_id'] as int;

          if (_processedUpdateIds.contains(currentUpdateId)) {
            continue;
          }

          _processedUpdateIds.add(currentUpdateId);
          _lastUpdateId = currentUpdateId;

          if (_isProcessing) {
            continue;
          }

          _isProcessing = true;
          try {
            await botController.handleUpdate(updateMap);
          } finally {
            _isProcessing = false;
          }
        }
      } catch (e) {
        onLog('Polling error: $e');
      }
    }

    onLog('Bot stopped.');
  }

  void stop() {
    _isRunning = false;
  }
}
