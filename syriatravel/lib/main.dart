import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:syriatravel/binding/initial_binding.dart';
import 'core/services/storage_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'وجهة',
      locale: const Locale('ar', 'SY'),
      fallbackLocale: const Locale('ar', 'SY'),
      supportedLocales: const [Locale('ar', 'SY')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialBinding: InitialBinding(),

      initialRoute: StorageService.hasRole()
          ? (StorageService.getUserRole() == 'driver'
                ? AppRoutes.driverHome
                : AppRoutes.mainWrapper)
          : AppRoutes.onboarding,

      getPages: AppRoutes.routes,

      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
    );
  }
}
