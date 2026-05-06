import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syriatravel/core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "الإشعارات",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        foregroundColor: AppColors.foreground,
      ),
      body: uid == null
          ? const Center(child: Text("يرجى تسجيل الدخول"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "تعذر تحميل الإشعارات: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return _NotificationTile(
                      docId: doc.id,
                      data: doc.data() as Map<String, dynamic>,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColors.grey300,
          ),
          SizedBox(height: 15),
          Text(
            "لا توجد إشعارات",
            style: TextStyle(color: AppColors.foregroundMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const _NotificationTile({required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isRead = data['read'] == true;
    final String title = data['title'] ?? '';
    final String body = data['body'] ?? '';
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;
    final String type = data['type'] ?? '';

    IconData icon = Icons.notifications;
    if (type == 'trip_cancelled') icon = Icons.event_busy_outlined;

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        color: AppColors.errorAccent,
        child: const Icon(Icons.delete_outline, color: AppColors.onPrimary),
      ),
      onDismissed: (_) {
        FirebaseFirestore.instance
            .collection('notifications')
            .doc(docId)
            .delete();
      },
      child: InkWell(
        onTap: isRead
            ? null
            : () => FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(docId)
                  .update({'read': true}),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? AppColors.surface : AppColors.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: AppColors.shadowLight, blurRadius: 10),
            ],
            border: Border.all(
              color: isRead ? Colors.transparent : AppColors.primary,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isRead
                                  ? AppColors.foreground
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.foregroundSoft,
                      ),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        DateFormat(
                          'yyyy/MM/dd - HH:mm',
                        ).format(createdAt.toDate()),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.foregroundMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
