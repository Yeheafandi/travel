import 'dart:async';

import 'package:flutter/material.dart';

import 'bot/bot_runner.dart';
import 'services/telegram_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.autoStart = true});

  final bool autoStart;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BotRunnerPage(autoStart: autoStart),
    );
  }
}

class BotRunnerPage extends StatefulWidget {
  const BotRunnerPage({super.key, this.autoStart = true});

  final bool autoStart;

  @override
  State<BotRunnerPage> createState() => _BotRunnerPageState();
}

class _BotRunnerPageState extends State<BotRunnerPage> {
  late final TelegramApiService telegramApiService;
  late final BotRunner botRunner;

  String logText = '';

  @override
  void initState() {
    super.initState();
    telegramApiService = TelegramApiService();
    botRunner = BotRunner(telegramApiService);

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startBot();
      });
    }
  }

  Future<void> _startBot() async {
    if (botRunner.isRunning || botRunner.isStarting) return;

    // show immediate auto-start message and rebuild so status text updates
    setState(() {
      logText = 'Auto start';
    });

    unawaited(
      botRunner.start((message) {
        if (!mounted) return;
        setState(() {
          // prepend new messages so recent logs appear on top
          logText = '$message\n\n$logText';
        });
      }),
    );

    // ensure UI updates right after initiating start (status uses botRunner.isRunning)
    if (mounted) setState(() {});
  }

  void _stopBot() {
    botRunner.stop();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    botRunner.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telegram Bot Runner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: (botRunner.isRunning || botRunner.isStarting)
                  ? null
                  : _startBot,
              child: Text(
                botRunner.isRunning || botRunner.isStarting
                    ? 'Bot Running'
                    : 'Start Bot',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: botRunner.isRunning ? _stopBot : null,
              child: const Text('Stop Bot'),
            ),
            const SizedBox(height: 20),
            Text(
              botRunner.isRunning ? 'Status: Running' : 'Status: Stopped',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Logs:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.black12,
                child: SingleChildScrollView(child: Text(logText)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
