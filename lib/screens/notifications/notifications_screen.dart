import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '';
    final db = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => db.markAllNotificationsRead(userId),
            child: const Text('Mark all read', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.streamNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: AppColors.textHint.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text("You're all caught up!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, endIndent: 16),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isRead = notif['isRead'] as bool? ?? false;
              final title = notif['title'] as String? ?? '';
              final body = notif['body'] as String? ?? '';
              final createdAt = notif['createdAt'] != null
                  ? DateTime.tryParse(notif['createdAt'] as String)
                  : null;

              return Dismissible(
                key: Key(notif['id']),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => db.deleteNotification(userId: userId, notificationId: notif['id']),
                child: ListTile(
                  onTap: () {
                    if (!isRead) {
                      db.markNotificationRead(userId: userId, notificationId: notif['id']);
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: isRead
                        ? AppColors.surface
                        : AppColors.primary.withAlpha(30),
                    child: Icon(
                      isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: isRead ? AppColors.textHint : AppColors.primary,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(body, style: const TextStyle(color: AppColors.textSecondary)),
                      if (createdAt != null)
                        Text(
                          DateFormat('MMM d · h:mm a').format(createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                        ),
                    ],
                  ),
                  trailing: !isRead
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
