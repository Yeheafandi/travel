import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/controllers/navigation_controller.dart';
import 'package:syriatravel/view/passenger/main_passenger_screen.dart';
import 'package:syriatravel/view/passenger/my_bookings_screen.dart';
import 'package:syriatravel/view/passenger/profile_screen.dart'; 

class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final NavigationController navController = Get.find<NavigationController>();

  final List<Widget> screens = [
    PassengerHomeScreen(),
    const Center(child: Text("صفحة البحث")),
    const MyBookingsScreen(), 
    const ProfileScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: navController.selectedIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Obx(() => _buildBottomNav(primaryGreen)),
    );
  }

  Widget _buildBottomNav(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.person_outline, Icons.person, 3, "بروفايل"),
          _navItem(Icons.bookmark_border_rounded, Icons.bookmark, 2, "حجوزاتي"),
          _navItem(Icons.search, Icons.search, 1, "البحث"),
          _navItem(Icons.home_outlined, Icons.home, 0, "الرئيسية"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, int index, String label) {
    bool isActive = navController.selectedIndex.value == index;
    Color activeColor = const Color(0xFF1B5E20);

    return GestureDetector(
      onTap: () => navController.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : Colors.grey,
              size: 26,
            ),
            if (isActive)
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
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