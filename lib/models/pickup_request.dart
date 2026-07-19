class PickupRequest {
  final String id;
  final String userId;
  final String category;
  final String amount;
  final String unit;
  final String status;
  final String? collectorId;
  final DateTime? pickedUpAt;
  final DateTime createdAt;

  const PickupRequest({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.unit,
    required this.status,
    this.collectorId,
    this.pickedUpAt,
    required this.createdAt,
  });

  factory PickupRequest.fromMap(Map<String, dynamic> map) {
    return PickupRequest(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      category: map['category'] ?? '',
      amount: map['amount']?.toString() ?? '',
      unit: map['unit'] ?? '',
      status: map['status'] ?? 'scheduled',
      collectorId: map['collector_id'],
      pickedUpAt: DateTime.tryParse(map['picked_up_at']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
