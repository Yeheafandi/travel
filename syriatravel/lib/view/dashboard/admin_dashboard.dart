import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late TooltipBehavior _tooltipBehavior;
  final Color primaryGreen = const Color(0xFF1B5E20);
  final Color backgroundColor = const Color(0xFFF5F7F9);

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("📊 إحصائيات الرحلات الشهرية"),
                  _buildTripsChart(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("👥 توزيع المستخدمين"),
                  _buildUsersChart(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("🏙️ أعلى المدن المطلوبة"),
                  _buildCitiesChart(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("⚡ الإجراءات السريعة"),
                  _buildActionsSection(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "مرحباً بك",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "لوحة تحكم الإدارة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showLogoutConfirmation(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  "النظام يعمل بكفاءة عالية",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildStatCard(
          "المستخدمين",
          "1,245",
          Icons.people_alt_outlined,
          Colors.blue,
        ),
        _buildStatCard("الرحلات", "342", Icons.map_outlined, Colors.orange),
        _buildStatCard("الحجوزات", "892", Icons.bookmark_border, Colors.purple),
        _buildStatCard(
          "الإيرادات",
          "45,230",
          Icons.monetization_on_outlined,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTripsChart() {
    final List<ChartData> chartData = [
      ChartData('يناير', 35),
      ChartData('فبراير', 28),
      ChartData('مارس', 34),
      ChartData('أبريل', 32),
      ChartData('مايو', 40),
      ChartData('يونيو', 32),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: const TextStyle(fontSize: 12),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: const TextStyle(fontSize: 12),
          majorTickLines: const MajorTickLines(width: 0),
        ),
        tooltipBehavior: _tooltipBehavior,
        series: <CartesianSeries>[
          ColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            color: primaryGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersChart() {
    final List<UserTypeData> userTypeData = [
      UserTypeData('ركاب', 67, primaryGreen),
      UserTypeData('سائقين', 33, const Color(0xFF4CAF50)),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: SfCircularChart(
        tooltipBehavior: _tooltipBehavior,
        series: <CircularSeries>[
          DoughnutSeries<UserTypeData, String>(
            dataSource: userTypeData,
            xValueMapper: (UserTypeData data, _) => data.x,
            yValueMapper: (UserTypeData data, _) => data.y,
            pointColorMapper: (UserTypeData data, _) => data.color,
            innerRadius: '70%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesChart() {
    final List<CityData> cityData = [
      CityData('دمشق', 450),
      CityData('حلب', 380),
      CityData('حمص', 290),
      CityData('اللاذقية', 210),
      CityData('درعا', 160),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          labelStyle: const TextStyle(fontSize: 12),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: const TextStyle(fontSize: 12),
          majorTickLines: const MajorTickLines(width: 0),
        ),
        tooltipBehavior: _tooltipBehavior,
        series: <CartesianSeries>[
          BarSeries<CityData, String>(
            dataSource: cityData,
            xValueMapper: (CityData data, _) => data.city,
            yValueMapper: (CityData data, _) => data.bookings,
            color: primaryGreen,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildActionButton(
          "إدارة المستخدمين",
          Icons.people_alt_outlined,
          Colors.blue,
          () {},
        ),
        _buildActionButton(
          "إدارة الرحلات",
          Icons.map_outlined,
          Colors.orange,
          () {},
        ),
        _buildActionButton(
          "التقارير",
          Icons.bar_chart_outlined,
          Colors.purple,
          () {},
        ),
        _buildActionButton(
          "الدعم الفني",
          Icons.support_agent_outlined,
          Colors.teal,
          () {},
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
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
      buttonColor: primaryGreen,
      onConfirm: () {
        FirebaseAuth.instance.signOut();
        Get.offAllNamed('/roleSelection');
      },
    );
  }
}

// نماذج البيانات للرسوم البيانية
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class UserTypeData {
  UserTypeData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

class CityData {
  CityData(this.city, this.bookings);
  final String city;
  final double bookings;
}
