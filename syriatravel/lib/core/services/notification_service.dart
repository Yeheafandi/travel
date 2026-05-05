// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';

// class NotificationService extends GetxService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();

//   Future<NotificationService> init() async {
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       String? token = await _messaging.getToken();
//       print("FCM Token: $token");

//       await _messaging.subscribeToTopic("new_trips");
//     }

//     _initLocalNotifications();
//     _configureMessageHandlers();

//     return this;
//   }

//   void _initLocalNotifications() {
//     const androidSetup = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSetup = DarwinInitializationSettings();
//     const setup = InitializationSettings(android: androidSetup, iOS: iosSetup);
//     _localNotifications.initialize(setup);
//   }

//   void _configureMessageHandlers() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;

//       if (notification != null && android != null) {
//         _localNotifications.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'high_importance_channel',
//               'High Importance Notifications',
//               importance: Importance.max,
//               priority: Priority.high,
//               icon: '@mipmap/ic_launcher',
//             ),
//           ),
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("تم الضغط على الإشعار: ${message.data}");
//     });
//   }

//   Future<void> saveTokenToFirestore(String userId) async {
//     String? token = await _messaging.getToken();
//     if (token != null) {
//       await FirebaseFirestore.instance.collection('users').doc(userId).set({
//         'fcmToken': token,
//       }, SetOptions(merge: true));
//     }
//   }
// }
