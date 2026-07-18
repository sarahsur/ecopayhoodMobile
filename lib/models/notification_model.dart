class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final String iconType;
  final bool isRead;
  final DateTime createdAt;
  final String? category;
  final String? groupLabel;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.iconType,
    this.isRead = false,
    required this.createdAt,
    this.category,
    this.groupLabel,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    String? iconType,
    bool? isRead,
    DateTime? createdAt,
    String? category,
    String? groupLabel,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      iconType: iconType ?? this.iconType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      groupLabel: groupLabel ?? this.groupLabel,
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '') ??
        DateTime.now();

    return NotificationModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      time: map['time_label'] ?? _formatTimeLabel(createdAt),
      iconType: map['icon_type'] ?? 'notification',
      isRead: map['is_read'] ?? false,
      createdAt: createdAt,
      category: map['category'],
      groupLabel: map['group_label'],
    );
  }

  Map<String, dynamic> toInsertMap({required String userId}) {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'time_label': time,
      'icon_type': iconType,
      'is_read': isRead,
      'category': category,
      'group_label': groupLabel,
    };
  }

  static String _formatTimeLabel(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 1) return 'Baru';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 30) return '${diff.inDays} hari lalu';

    return '${(diff.inDays / 30).floor()} bulan lalu';
  }
}
