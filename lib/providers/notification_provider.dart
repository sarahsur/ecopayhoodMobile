import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  static final NotificationProvider _instance = NotificationProvider._internal();
  factory NotificationProvider() => _instance;
  NotificationProvider._internal() {
    _initializeMotivationalNotifications();
  }

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void _initializeMotivationalNotifications() {
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Keren banget! 👏👏',
        description: 'Bulan ini kamu sudah berhasil\nmengumpulkan\n\n12 kg plastik.\n\nAyo terus kumpulkan\nbersama Greenie!\n\nKarena sampahmu memiliki\nnilai dan membantu\nlingkungan.',
        time: 'Kemarin',
        iconType: 'motivation',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        groupLabel: 'Kemarin',
      ),
      NotificationModel(
        id: '2',
        title: 'Keren banget! 👏👏',
        description: 'Kamu sudah berhasil\nmengumpulkan\n\n16 liter minyak.\n\nTerus semangat menjaga\nlingkungan.',
        time: '1 Bulan Lalu',
        iconType: 'motivation',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        groupLabel: '1 Bulan Lalu',
      ),
    ];
  }

  void addPickupNotification({
    required String category,
    required String amount,
    required String unit,
  }) {
    final now = DateTime.now();
    
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Permintaan penjemputan berhasil dijadwalkan',
      description: 'Permintaan penjemputan kategori $category berhasil dibuat.\n\nGreenie akan segera menuju lokasi sesuai jadwal yang dipilih.',
      time: 'Baru',
      iconType: 'pickup',
      isRead: false,
      createdAt: now,
      category: category,
    );

    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }

  List<NotificationModel> getNotificationsByGroup(String groupLabel) {
    return _notifications.where((n) => n.groupLabel == groupLabel).toList();
  }
}
