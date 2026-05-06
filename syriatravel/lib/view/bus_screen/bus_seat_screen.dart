import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/widgets/passenger_widgets/action_panel.dart';
import 'package:syriatravel/widgets/passenger_widgets/seat_legend.dart';
import 'package:syriatravel/widgets/passenger_widgets/seat_widget.dart';
import '../../controllers/bus_seat_controller.dart';
import '../../models/trip_model.dart';

class BusSeatScreen extends StatefulWidget {
  final TripModel trip;

  const BusSeatScreen({super.key, required this.trip});

  @override
  State<BusSeatScreen> createState() => _BusSeatScreenState();
}

class _BusSeatScreenState extends State<BusSeatScreen>
    with SingleTickerProviderStateMixin {
  final Color primaryGreen = const Color(0xFF1B5E20);

  late final BusSeatController controller;
  late final AnimationController _intro;
  late final Animation<double> _seatsFade;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      BusSeatController(
        tripId: widget.trip.id.toString(),
        tripPrice: double.tryParse(widget.trip.price.toString()) ?? 0.0,
      ),
      tag: widget.trip.id,
    );

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    _seatsFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text(
          "اختيار المقاعد",
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryGreen),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _seatsFade,
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: primaryGreen),
                );
              }
              return Column(
                children: [
                  SeatLegend(primaryGreen: primaryGreen),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      itemCount: controller.rowCount,
                      itemBuilder: (context, index) =>
                          _buildRow(index, controller),
                    ),
                  ),
                  ActionPanel(
                    controller: controller,
                    trip: widget.trip,
                    primaryGreen: primaryGreen,
                  ),
                ],
              );
            }),
          ),
          _buildBusIntro(),
        ],
      ),
    );
  }

  Widget _buildBusIntro() {
    return AnimatedBuilder(
      animation: _intro,
      builder: (context, _) {
        if (_intro.value >= 0.7) return const SizedBox.shrink();
        final width = MediaQuery.of(context).size.width;
        final t = (_intro.value / 0.7).clamp(0.0, 1.0);
        final eased = Curves.easeInOut.transform(t);
        final dx = width * (1 - 2 * eased);
        final dy = math.sin(t * math.pi * 10) * 3;

        return IgnorePointer(
          child: Center(
            child: Transform.translate(
              offset: Offset(dx, dy),
              child: SizedBox(
                width: 220,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(top: 30, right: 0, child: _motionLine(24, 1.0)),
                    Positioned(top: 55, right: 6, child: _motionLine(40, 0.7)),
                    Positioned(top: 80, right: 0, child: _motionLine(24, 0.5)),
                    Transform.flip(
                      flipX: true,
                      child: Icon(
                        Icons.airport_shuttle,
                        size: 120,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _motionLine(double width, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: 3,
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildRow(int rowIndex, BusSeatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSeatPair(rowIndex * 4 + 1, rowIndex * 4 + 2, controller),
          const Spacer(),
          _buildSeatPair(rowIndex * 4 + 3, rowIndex * 4 + 4, controller),
        ],
      ),
    );
  }

  Widget _buildSeatPair(int s1, int s2, BusSeatController controller) {
    return Row(
      children: [
        SeatWidget(
          seatNumber: s1,
          controller: controller,
          primaryGreen: primaryGreen,
        ),
        const SizedBox(width: 12),
        SeatWidget(
          seatNumber: s2,
          controller: controller,
          primaryGreen: primaryGreen,
        ),
      ],
    );
  }
}
