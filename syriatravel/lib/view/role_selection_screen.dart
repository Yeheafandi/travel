import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/constants/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.directions_bus_rounded,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 40),

                        const Text(
                          "وجهة",
                          style: TextStyle(
                            color: AppColors.foreground,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "احجز رحلتك بكل سهولة وأمان",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.mutedForeground,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 60),

                        _buildRoleCard(
                          title: "أنا سائق",
                          subtitle: "أريد إضافة رحلات ونقل الركاب",
                          icon: Icons.drive_eta_rounded,
                          onTap: () =>
                              Get.toNamed('/login', arguments: 'driver'),
                          isPrimary: false,
                        ),

                        const SizedBox(height: 20),

                        _buildRoleCard(
                          title: "أنا مسافر",
                          subtitle: "أبحث عن رحلات لحجز مقعد",
                          icon: Icons.person_pin_circle_rounded,
                          onTap: () =>
                              Get.toNamed('/login', arguments: 'passenger'),
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white : AppColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isPrimary ? Colors.white : AppColors.foreground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isPrimary
                          ? Colors.white70
                          : AppColors.mutedForeground,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? Colors.white : AppColors.mutedForeground,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
