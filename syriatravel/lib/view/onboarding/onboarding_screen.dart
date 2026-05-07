import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/core/constants/app_colors.dart';
import 'package:syriatravel/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      icon: Icons.directions_bus_rounded,
      title: 'أهلاً بك في وجهة',
      subtitle: 'تطبيقك الأول لحجز الرحلات داخل سوريا بكل سهولة وأمان.',
    ),
    _OnboardingPageData(
      icon: Icons.travel_explore_rounded,
      title: 'ابحث عن رحلتك بسهولة',
      subtitle:
          'اكتشف الرحلات المتاحة بين المحافظات واختر المقعد المناسب لك بضغطة واحدة.',
    ),
    _OnboardingPageData(
      icon: Icons.verified_user_rounded,
      title: 'احجز بثقة وأمان',
      subtitle: 'احصل على تذكرتك إلكترونياً وتابع رحلاتك وإشعاراتك في أي وقت.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToRoleSelection() {
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  void _onNextPressed() {
    if (_currentPage == _pages.length - 1) {
      _goToRoleSelection();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextButton(
                    onPressed: _goToRoleSelection,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text(
                      'تخطي',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildPageIndicator(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 4,
                      shadowColor: AppColors.shadowMedium,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isLastPage ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final bool isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(data.icon, size: 96, color: AppColors.primary),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.foregroundSoft,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
