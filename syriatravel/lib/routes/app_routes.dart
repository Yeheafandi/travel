import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/helpful_functions/main_wrapper.dart';
import '../view/auth/login_screen.dart';
import '../view/auth/register_screen.dart';
import '../view/driver/driver_home.dart';
import '../view/onboarding/onboarding_screen.dart';
import '../view/role_selection_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String driverHome = '/driver-home';
  static const String mainWrapper = '/main-wrapper';

  static final routes = [
    GetPage(
      name: initial,
      page: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),

    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: roleSelection,
      page: () => RoleSelectionScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),

    GetPage(name: driverHome, page: () => DriverHomeScreen()),

    GetPage(
      name: mainWrapper,
      page: () => MainWrapper(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
