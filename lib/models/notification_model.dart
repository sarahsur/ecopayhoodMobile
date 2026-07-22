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
}
