import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/controllers/navigation_controller.dart';
import 'package:syriatravel/core/constants/app_colors.dart';
import 'package:syriatravel/view/passenger/bot_qr_screen.dart';
import 'package:syriatravel/view/passenger/main_passenger_screen.dart';
import 'package:syriatravel/view/passenger/my_bookings_screen.dart';
import 'package:syriatravel/view/passenger/profile_screen.dart';
import 'package:syriatravel/view/passenger/search_trip_screen.dart';

class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final NavigationController navController = Get.find<NavigationController>();

  final List<Widget> screens = [
    PassengerHomeScreen(),
    SearchTripScreen(),
    const BotQrScreen(),
    const MyBookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
           
          index: navController.selectedIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: SafeArea(child: Obx(() => _buildBottomNav())),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.primaryForeground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.person_outline, Icons.person, 4, "بروفايل"),
          _navItem(Icons.bookmark_border_rounded, Icons.bookmark, 3, "حجوزاتي"),
          _navItem(Icons.smart_toy_outlined, Icons.smart_toy, 2, "البوت"),
          _navItem(Icons.search_rounded, Icons.search, 1, "البحث"),
          _navItem(Icons.home_outlined, Icons.home, 0, "الرئيسية"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, int index, String label) {
    final bool isActive = navController.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => navController.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.grey500,
              size: 26,
            ),
            if (isActive)
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
