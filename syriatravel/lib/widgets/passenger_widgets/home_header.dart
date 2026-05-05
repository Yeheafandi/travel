import 'package:flutter/material.dart';
import 'package:syriatravel/widgets/passenger_widgets/passenger_widgets.dart';

class HomeHeader extends StatelessWidget {
  final Color backgroundColor;
  final String userName;

  const HomeHeader({super.key, required this.backgroundColor, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 70),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PassengerWidgets.buildCircularAction(icon:Icons.notifications_none_rounded,onTap:  () {}),
              const Row(
                children: [
                  Text("سوريا ترافيل", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.directions_bus, color: Colors.white),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text("أهلاً بك يا $userName! 👋", style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const Text(
            "احجز رحلتك بسهولة\nوأمان عبر سوريا",
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.4),
          ),
        ],
      ),
    );
  }
}