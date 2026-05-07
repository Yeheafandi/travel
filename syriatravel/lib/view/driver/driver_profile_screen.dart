import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/constants/app_colors.dart';
import 'package:syriatravel/view/dashboard/bus_company_dashboard.dart';


import '../../controllers/auth_controller.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    authController.fetchUserData();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "الملف الشخصي",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        foregroundColor: AppColors.foreground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 60, color: AppColors.onPrimary),
            ),
            const SizedBox(height: 24),
            Obx(
              () => _buildInfoCard(
                icon: Icons.person_outline,
                label: "الاسم",
                value: authController.name.value.isNotEmpty
                    ? authController.name.value
                    : "تحميل...",
              ),
            ),
            Obx(
              () => _buildInfoCard(
                icon: Icons.phone_android,
                label: "رقم الهاتف",
                value: authController.phone.value.isNotEmpty
                    ? authController.phone.value
                    : "غير محدد",
              ),
            ),
            Obx(
              () => _buildInfoCard(
                icon: Icons.email_outlined,
                label: "البريد الإلكتروني",
                value: authController.email.value.isNotEmpty
                    ? authController.email.value
                    : "جاري التحميل...",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusCompanyDashboard(),
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard, color: Colors.white),
                label: const Text(
                  "لوحة التحكم ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(authController),
                icon: const Icon(Icons.logout, color: AppColors.onPrimary),
                label: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BusCompanyDashboard()),
          );
        },
        child: Icon(Icons.dashboard),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.foregroundMuted,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.foreground,
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(AuthController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text("تنبيه"),
        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          TextButton(
            onPressed: () => controller.logout(),
            child: const Text("خروج", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
