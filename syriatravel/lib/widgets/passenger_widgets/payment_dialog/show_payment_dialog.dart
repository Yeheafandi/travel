// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void showPaymentDialog(BuildContext context) {
//   final String paymentCode = DateTime.now().millisecondsSinceEpoch
//       .toString()
//       .substring(7);
//   final String shamCashNumber = "09xxxxxxxx";

//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("بيانات الدفع والتحويل", textAlign: TextAlign.center),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "يرجى التحويل إلى حساب شام كاش أدناه واستخدام رمز الدفع في الملاحظات",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 20),

//               const Text(
//                 "رقم حساب شام كاش:",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 10),
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.amber),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       shamCashNumber,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.copy, color: Colors.amber),
//                       onPressed: () {
//                         Clipboard.setData(ClipboardData(text: shamCashNumber));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("تم نسخ رقم الحساب")),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               const Text("رمز الدفع الخاص بك (أرسله للمسافر):"),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 10),
//                 padding: const EdgeInsets.all(15),
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.amber[50],
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.amber),
//                 ),
//                 child: Column(
//                   children: [
//                     SelectableText(
//                       paymentCode,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 2,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     const Text(
//                       "يجب وضعه في ملاحظات التحويل",
//                       style: TextStyle(fontSize: 10, color: Colors.red),
//                     ),
//                   ],
//                 ),
//               ),

//               const Divider(height: 30),

//               const Text("بعد التحويل، أدخل رقم العملية هنا:"),
//               const SizedBox(height: 10),
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: "رقم العملية (Transaction ID)",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("تأكيد الدفع"),
//           ),
//         ],
//       );
//     },
//   );
// }
