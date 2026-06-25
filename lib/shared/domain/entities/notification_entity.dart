class NotificationEntity {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isUnread = false,
    required this.createdAt,
    this.senderImage,
    this.conversationId,
    this.senderId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;
  final DateTime createdAt;
  final String? senderImage;
  final String? conversationId;
  final String? senderId;

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      isUnread: json['isUnread'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      senderImage: json['sender_image']?.toString() ?? json['senderImage']?.toString(),
      conversationId: json['conversation_id']?.toString() ?? json['conversationId']?.toString(),
      senderId: json['sender_id']?.toString() ?? json['senderId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'isUnread': isUnread,
      'createdAt': createdAt.toIso8601String(),
      'sender_image': senderImage,
      'conversation_id': conversationId,
      'sender_id': senderId,
    };
  }
}
