import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_model.dart';
import 'supabase_service.dart';

class NotificationService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<NotificationModel>> getCurrentUserNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data)
        .map(NotificationModel.fromMap)
        .toList();
  }

  Future<NotificationModel> createPickupNotification({
    required String category,
    required String amount,
    required String unit,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AuthException('User belum login');
    }

    final notification = NotificationModel(
      id: '',
      title: 'Permintaan penjemputan berhasil dijadwalkan',
      description:
          'Permintaan penjemputan kategori $category berhasil dibuat.\n\n'
          'Greenie akan segera menuju lokasi sesuai jadwal yang dipilih.',
      time: 'Baru',
      iconType: 'pickup',
      isRead: false,
      createdAt: DateTime.now(),
      category: category,
    );

    final data = await _client
        .from('notifications')
        .insert(notification.toInsertMap(userId: user.id))
        .select()
        .single();

    return NotificationModel.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id);
  }
}
