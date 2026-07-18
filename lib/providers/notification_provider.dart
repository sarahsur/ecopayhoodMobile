import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  static final NotificationProvider _instance = NotificationProvider._internal();

  factory NotificationProvider() => _instance;

  NotificationProvider._internal();

  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getCurrentUserNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPickupNotification({
    required String category,
    required String amount,
    required String unit,
  }) async {
    final notification = await _notificationService.createPickupNotification(
      category: category,
      amount: amount,
      unit: unit,
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  List<NotificationModel> getNotificationsByGroup(String groupLabel) {
    return _notifications.where((n) => n.groupLabel == groupLabel).toList();
  }
}
