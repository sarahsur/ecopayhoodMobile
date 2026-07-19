import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pickup_completion.dart';
import '../models/pickup_request.dart';
import 'supabase_service.dart';

class CollectorService {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<PickupRequest>> getScheduledPickups() async {
    final data = await _client
        .from('pickup_requests')
        .select()
        .eq('status', 'scheduled')
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(
      data,
    ).map(PickupRequest.fromMap).toList();
  }

  Future<List<PickupRequest>> getScheduledPickupsByWargaId(
    String wargaId,
  ) async {
    final data = await _client
        .from('pickup_requests')
        .select()
        .eq('user_id', wargaId)
        .eq('status', 'scheduled')
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(
      data,
    ).map(PickupRequest.fromMap).toList();
  }

  Future<List<PickupRequest>> getCompletedPickupsByCurrentCollector() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final data = await _client
        .from('pickup_requests')
        .select()
        .eq('collector_id', user.id)
        .eq('status', 'picked_up')
        .order('picked_up_at', ascending: false);

    return List<Map<String, dynamic>>.from(
      data,
    ).map(PickupRequest.fromMap).toList();
  }

  Future<int> getCurrentCollectorRewardPoints() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    final data = await _client
        .from('point_transactions')
        .select('points')
        .eq('collector_id', user.id)
        .eq('type', 'pickup_reward');

    return List<Map<String, dynamic>>.from(data).fold<int>(
      0,
      (total, row) =>
          total + (int.tryParse(row['points']?.toString() ?? '') ?? 0),
    );
  }

  Future<PickupCompletion> completePickupFromQr(String qrText) async {
    final wargaId = extractWargaId(qrText);

    if (wargaId == null || wargaId.isEmpty) {
      throw const FormatException('QR warga tidak valid');
    }

    final data = await _client
        .rpc('complete_pickup_by_qr', params: {'p_warga_id': wargaId})
        .single();

    return PickupCompletion.fromMap(Map<String, dynamic>.from(data));
  }

  Future<PickupCompletion> completeSelectedPickups({
    required String wargaId,
    required List<String> requestIds,
  }) async {
    if (requestIds.isEmpty) {
      throw const FormatException('Pilih minimal satu pengajuan');
    }

    final data = await _client
        .rpc(
          'complete_selected_pickups_by_qr',
          params: {'p_warga_id': wargaId, 'p_request_ids': requestIds},
        )
        .single();

    return PickupCompletion.fromMap(Map<String, dynamic>.from(data));
  }

  String? extractWargaId(String qrText) {
    final raw = qrText.trim();
    if (raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final type = decoded['type']?.toString();
        final uid = decoded['uid']?.toString();

        if (type == 'ECOPAYHOOD_WARGA' && uid != null) {
          return uid;
        }
      }
    } catch (_) {
      // Fallback for the older QR payload that used Map.toString().
    }

    final legacyMatch = RegExp(r'uid:\s*([^,}]+)').firstMatch(raw);
    return legacyMatch?.group(1)?.trim();
  }
}
