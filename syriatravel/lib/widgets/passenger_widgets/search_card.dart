import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/constants/app_colors.dart';

class SearchCard extends StatelessWidget {
  const SearchCard({super.key});

  static const String _botHandle = '@TRANSPORT_BOOKING_DEMO_BOT';
  static const String _qrAsset =
      'assets/images/Screenshot 2026-05-06 232047.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildQrAndSteps(),
          const SizedBox(height: 14),
          _buildHandlePill(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "احجز رحلتك مع البوت",
                style: TextStyle(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "امسح الرمز لبدء محادثة على تيليجرام",
                style: TextStyle(
                  color: AppColors.foregroundMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQrAndSteps() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 130,
          height: 130,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              _qrAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.broken_image_outlined,
                color: AppColors.foregroundMuted,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(1, "افتح تيليجرام"),
              const SizedBox(height: 8),
              _buildStep(2, "امسح رمز QR"),
              const SizedBox(height: 8),
              _buildStep(3, "ابدأ الحجز فوراً"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.foregroundSoft,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandlePill(BuildContext context) {
    return InkWell(
      onTap: () => _copyHandle(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.alternate_email_rounded,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                _botHandle,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Icon(Icons.copy_rounded, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  void _copyHandle(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _botHandle));
    Get.snackbar(
      "تم النسخ",
      "تم نسخ اسم البوت إلى الحافظة",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: AppColors.onPrimary,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
    );
  }
}
