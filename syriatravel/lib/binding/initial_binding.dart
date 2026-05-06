import 'package:get/get.dart';
import 'package:syriatravel/bot/trips_sync_service.dart';

import '../bot/bot_api_service.dart';
import '../bot/bot_firestore_service.dart';
import '../bot/bot_requests_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/navigation_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    Get.lazyPut<NavigationController>(
      () => NavigationController(),
      fenix: true,
    );

    Get.lazyPut<BotApiService>(
      () => BotApiService(
        baseUrl: 'https://talented-reprieve-production-8f46.up.railway.app',
      ),
      fenix: true,
    );

    Get.lazyPut<BotFirestoreService>(() => BotFirestoreService(), fenix: true);

    Get.lazyPut<BotRequestsController>(
      () => BotRequestsController(
        apiService: Get.find<BotApiService>(),
        firestoreService: Get.find<BotFirestoreService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<TripsSyncService>(() {
      final service = TripsSyncService(
        botUrl: 'https://talented-reprieve-production-8f46.up.railway.app',
      );
      service.autoSync();
      return service;
    }, fenix: true);
  }
}
