import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'supabase_service.dart';

class UserService {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentAuthUser => _client.auth.currentUser;

  Future<AppUser?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return getUser(user.id);
  }

  Future<AppUser?> getUser(String uid) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (data == null) return null;

    return AppUser.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> saveBasicUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _client.from('profiles').upsert({
      'id': uid,
      'name': name,
      'email': email,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveCurrentUserProfile({
    required String name,
    required String phone,
  }) async {
    final user = _requireCurrentUser();

    await _client.from('profiles').upsert({
      'id': user.id,
      'name': name,
      'email': user.email ?? '',
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveCurrentUserAddress({
    required String name,
    required String phone,
    required String address,
    required String addressDetail,
  }) async {
    final user = _requireCurrentUser();

    await _client.from('profiles').upsert({
      'id': user.id,
      'name': name,
      'email': user.email ?? '',
      'phone': phone,
      'address': address,
      'address_detail': addressDetail,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  User _requireCurrentUser() {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw AuthException('User belum login');
    }

    return user;
  }
}
