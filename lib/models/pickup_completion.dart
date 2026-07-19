class PickupCompletion {
  final String requestId;
  final String wargaId;
  final String collectorId;
  final int pointsAwarded;
  final int completedCount;
  final String status;

  const PickupCompletion({
    required this.requestId,
    required this.wargaId,
    required this.collectorId,
    required this.pointsAwarded,
    this.completedCount = 1,
    required this.status,
  });

  factory PickupCompletion.fromMap(Map<String, dynamic> map) {
    return PickupCompletion(
      requestId: map['request_id']?.toString() ?? '',
      wargaId: map['warga_id']?.toString() ?? '',
      collectorId: map['collector_id']?.toString() ?? '',
      pointsAwarded: int.tryParse(map['points_awarded']?.toString() ?? '') ?? 0,
      completedCount:
          int.tryParse(map['completed_count']?.toString() ?? '') ?? 1,
      status: map['status']?.toString() ?? '',
    );
  }
}
