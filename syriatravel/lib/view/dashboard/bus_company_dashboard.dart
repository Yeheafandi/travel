import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syriatravel/core/constants/app_colors.dart';

class BusCompanyDashboard extends StatefulWidget {
  const BusCompanyDashboard({super.key});

  @override
  State<BusCompanyDashboard> createState() => _BusCompanyDashboardState();
}

class _BusCompanyDashboardState extends State<BusCompanyDashboard> {
  late final TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color deepGreen = Color(0xFF123A17);

  final List<RevenuePoint> _revenueData = const [
    RevenuePoint('السبت', 42),
    RevenuePoint('الأحد', 38),
    RevenuePoint('الاثنين', 55),
    RevenuePoint('الثلاثاء', 48),
    RevenuePoint('الأربعاء', 67),
    RevenuePoint('الخميس', 61),
    RevenuePoint('الجمعة', 74),
  ];

  final List<FleetStatusData> _fleetData = const [
    FleetStatusData('فعالة', 14, Color(0xFF1B5E20)),
    FleetStatusData('صيانة', 3, Color(0xFFF59E0B)),
    FleetStatusData('متوقفة', 5, Color(0xFF94A3B8)),
  ];

  final List<RouteLoadData> _routeData = const [
    RouteLoadData('دمشق - حمص', 92),
    RouteLoadData('دمشق - حلب', 86),
    RouteLoadData('حمص - اللاذقية', 74),
    RouteLoadData('دمشق - طرطوس', 68),
    RouteLoadData('حلب - حماة', 61),
  ];

  final List<LiveActivity> _activities = const [
    LiveActivity(
      'انطلاق الباص رقم 14',
      'منذ دقيقتين',
      Icons.directions_bus_filled,
    ),
    LiveActivity('تم حجز 12 مقعداً', 'منذ 8 دقائق', Icons.event_seat),
    LiveActivity('اعتماد خط جديد', 'منذ 21 دقيقة', Icons.route),
    LiveActivity('اكتمال الصيانة', 'منذ 45 دقيقة', Icons.build_circle_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroHeader(),
              Transform.translate(
                offset: const Offset(0, -26),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _buildOverviewStrip(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('الأداء اليومي'),
                    const SizedBox(height: 12),
                    _buildRevenueCard(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('توزيع الأسطول'),
                    const SizedBox(height: 12),
                    _buildFleetCard(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('أعلى الخطوط حسب الإشغال'),
                    const SizedBox(height: 12),
                    _buildRoutesCard(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('الإجراءات السريعة'),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 18),
                    _buildSectionTitle('النشاط المباشر'),
                    const SizedBox(height: 12),
                    _buildActivityFeed(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, deepGreen],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.directions_bus_filled, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لوحة شركة النقل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'عرض تشغيلي يساعد على اتخاذ القرارات اليومية',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _headerIcon(Icons.notifications_none_outlined),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.summarize_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملخص اليوم',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'الإيرادات ارتفعت 18% ونسبة الإشغال مستقرة.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.trending_up, color: Colors.greenAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStrip() {
    return Row(
      children: [
        Expanded(
          child: _compactStat(
            label: 'الإيراد',
            value: '34.2K',
            icon: Icons.payments_outlined,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _compactStat(
            label: 'الرحلات',
            value: '128',
            icon: Icons.route_outlined,
            color: const Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _compactStat(
            label: 'الإشغال',
            value: '87%',
            icon: Icons.event_seat_outlined,
            color: const Color(0xFF0EA5E9),
          ),
        ),
      ],
    );
  }

  Widget _compactStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildRevenueCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill('أسبوعي', Colors.green.shade50, primaryGreen),
              const Spacer(),
              const Icon(Icons.more_horiz, color: AppColors.mutedForeground),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(fontSize: 11),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.grey.withOpacity(0.12),
                ),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(fontSize: 11),
              ),
              series: <CartesianSeries<RevenuePoint, String>>[
                SplineAreaSeries<RevenuePoint, String>(
                  dataSource: _revenueData,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.value,
                  color: primaryGreen.withOpacity(0.18),
                  borderColor: primaryGreen,
                  borderWidth: 3,
                  markerSettings: const MarkerSettings(isVisible: true),
                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'يرتفع الإيراد منتصف الأسبوع ويبلغ ذروته يوم الجمعة.',
            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill('حالة الأسطول', Colors.green.shade50, primaryGreen),
              const Spacer(),
              const Text(
                '22 باصاً',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: SfCircularChart(
              tooltipBehavior: _tooltipBehavior,
              legend: const Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
              ),
              series: <CircularSeries<FleetStatusData, String>>[
                DoughnutSeries<FleetStatusData, String>(
                  dataSource: _fleetData,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  pointColorMapper: (d, _) => d.color,
                  innerRadius: '68%',
                  radius: '95%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _pill('أعلى الخطوط', Colors.green.shade50, primaryGreen),
              const Spacer(),
              const Text(
                'نسبة الإشغال',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: const TextStyle(fontSize: 11),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 20,
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.grey.withOpacity(0.12),
                ),
              ),
              series: <CartesianSeries<RouteLoadData, String>>[
                BarSeries<RouteLoadData, String>(
                  dataSource: _routeData,
                  xValueMapper: (d, _) => d.route,
                  yValueMapper: (d, _) => d.load,
                  color: primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _ActionItem(
        'إضافة رحلة',
        Icons.add_road_outlined,
        const Color(0xFF2563EB),
      ),
      _ActionItem(
        'إدارة الأسطول',
        Icons.directions_bus_outlined,
        const Color(0xFF0EA5E9),
      ),
      _ActionItem('التسعير', Icons.sell_outlined, const Color(0xFF7C3AED)),
      _ActionItem(
        'التقارير',
        Icons.analytics_outlined,
        const Color(0xFFF59E0B),
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (_, index) {
        final item = actions[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
                fontSize: 13,
              ),
            ),
            subtitle: const Text(
              'فتح',
              style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityFeed() {
    return _DashboardCard(
      child: Column(
        children: _activities
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item.icon, color: primaryGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_left,
                      color: AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _pill(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class RevenuePoint {
  const RevenuePoint(this.day, this.value);
  final String day;
  final double value;
}

class FleetStatusData {
  const FleetStatusData(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class RouteLoadData {
  const RouteLoadData(this.route, this.load);
  final String route;
  final double load;
}

class LiveActivity {
  const LiveActivity(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class _ActionItem {
  const _ActionItem(this.title, this.icon, this.color);
  final String title;
  final IconData icon;
  final Color color;
}
