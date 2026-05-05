import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:syriatravel/controllers/auth_controller.dart';
import 'package:syriatravel/controllers/driver_controller.dart';
import 'package:syriatravel/models/trip_model.dart';

class DriverHomeScreen extends StatelessWidget {
  DriverHomeScreen({super.key});
  final AuthController authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: Column(
        children: [
          _buildDriverHeader(primaryGreen),

          Transform.translate(
            offset: const Offset(0, -30),
            child: _buildStatsCard(),
          ),

          _buildSectionTitle("طلبات الرحلات الجديدة"),

          Expanded(child: _buildEmptyState()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTripDialog(context),
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "إضافة رحلة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDriverHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 60),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderIcon(Icons.power_settings_new, () {
                _showLogoutConfirmation();
              }),
              Row(
                children: [
                  const Text(
                    "لوحة السائق",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.drive_eta, color: Colors.white),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: Colors.greenAccent,
                ),
                const Text(
                  "أنت الآن متصل",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.greenAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("4.9", "التقييم", Icons.star, Colors.orange),
          _buildVerticalDivider(),
          _buildStatItem("12", "رحلات اليوم", Icons.map, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.beach_access_rounded,
            size: 80,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 15),
          Text(
            "لا توجد طلبات رحلات حالياً\nاسترخِ قليلاً حتى يصلك تنبيه جديد",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.withOpacity(0.8), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  void _showAddTripDialog(BuildContext context) {
    final DriverController controller = Get.put(DriverController());
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final priceController = TextEditingController();
    final dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "إضافة رحلة جديدة",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: fromController,
              decoration: const InputDecoration(labelText: "من (المدينة)"),
            ),
            TextField(
              controller: toController,
              decoration: const InputDecoration(labelText: "إلى (المدينة)"),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "التاريخ (مثلاً: 2024-05-10)",
              ),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "السعر"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final String? currentDriverId =
                              FirebaseAuth.instance.currentUser?.uid;

                          if (fromController.text.isNotEmpty &&
                              toController.text.isNotEmpty) {
                            if (currentDriverId != null) {
                              if (controller.driverName.value.isEmpty) {
                                await controller.getDriverProfile(
                                  currentDriverId,
                                );
                              }

                              TripModel newTrip = TripModel(
                                fromCity: fromController.text,
                                toCity: toController.text,
                                date: dateController.text,
                                price: priceController.text,
                                driverName:
                                    controller.driverName.value.isNotEmpty
                                    ? controller.driverName.value
                                    : "كابتن",
                                driverId: currentDriverId, time: '', reservedSeats: [],
                              );

                              await controller.addTrip(newTrip);
                              Navigator.pop(context);
                            }
                          }
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "حفظ الرحلة",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.defaultDialog(
      title: "تنبيه",
      middleText: "هل أنت متأكد أنك تريد تسجيل الخروج؟",
      textConfirm: "خروج",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF1B5E20),
      onConfirm: () {
        authController.logout();
      },
    );
  }
}
