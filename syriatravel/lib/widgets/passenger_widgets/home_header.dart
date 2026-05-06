import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syriatravel/view/passenger/notifications_screen.dart';
import 'package:syriatravel/widgets/passenger_widgets/passenger_widgets.dart';

class HomeHeader extends StatelessWidget {
  final Color backgroundColor;
  final String userName;

  const HomeHeader({
    super.key,
    required this.backgroundColor,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 70,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.directions_bus, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "وجهة",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const _NotificationBell(),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            "أهلاً بك يا $userName! 👋",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Text(
            "احجز رحلتك بسهولة\nوأمان عبر سوريا",
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    final bell = PassengerWidgets.buildCircularAction(
      icon: Icons.notifications_none_rounded,
      onTap: () => Get.to(() => const NotificationsScreen()),
    );

    if (uid == null) return bell;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final int unread = snapshot.data?.docs.length ?? 0;
        if (unread == 0) return bell;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            bell,
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unread > 9 ? "9+" : "$unread",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
