import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_textstyle.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationProvider _notificationProvider = NotificationProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _notificationProvider.loadNotifications();
      await _notificationProvider.markAllAsRead();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: ListenableBuilder(
          listenable: _notificationProvider,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifikasi',
                  style: AppTextStyle.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (_notificationProvider.unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_notificationProvider.unreadCount}',
                        style: AppTextStyle.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_notificationProvider.isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          // Pickup notifications (no group label for new notifications)
          _buildPickupNotifications(),
          
          const SizedBox(height: 24),
          
          // Motivational notifications with group labels
          _buildGroupedNotifications(),
        ],
      ),
    );
  }

  Widget _buildPickupNotifications() {
    final notifications = _notificationProvider.notifications
        .where((n) => n.iconType == 'pickup')
        .toList();
    
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: notifications.map((notification) {
        return NotificationTile(notification: notification);
      }).toList(),
    );
  }

  Widget _buildGroupedNotifications() {
    final groups = ['Kemarin', '1 Bulan Lalu', '2 Bulan Lalu'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) {
        final groupNotifications = _notificationProvider.getNotificationsByGroup(group);
        if (groupNotifications.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                group,
                style: AppTextStyle.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ...groupNotifications.map((notification) {
              return NotificationTile(notification: notification);
            }),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }
}


class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyle.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification.time,
                      style: AppTextStyle.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.description,
                  style: AppTextStyle.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          _getIconData(),
          color: AppColors.darkGreen,
          size: 24,
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (notification.iconType) {
      case 'pickup':
        return Icons.local_shipping;
      case 'motivation':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }
}
