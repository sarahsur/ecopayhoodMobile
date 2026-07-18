import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pickup_request.dart';
import 'supabase_service.dart';

class PickupRequestService {
  final SupabaseClient _client = SupabaseService.client;

  Future<PickupRequest> createPickupRequest({
    required String category,
    required String amount,
    required String unit,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AuthException('User belum login');
    }

    final data = await _client
        .from('pickup_requests')
        .insert({
          'user_id': user.id,
          'category': category,
          'amount': amount,
          'unit': unit,
          'status': 'scheduled',
        })
        .select()
        .single();

    return PickupRequest.fromMap(Map<String, dynamic>.from(data));
  }

  Future<List<PickupRequest>> getCurrentUserRequests() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client
        .from('pickup_requests')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data)
        .map(PickupRequest.fromMap)
        .toList();
  }
}
