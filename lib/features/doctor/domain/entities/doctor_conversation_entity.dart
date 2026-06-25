class DoctorConversationEntity {
  const DoctorConversationEntity({
    required this.id,
    required this.otherId,
    required this.name,
    required this.preview,
    required this.image,
    this.unreadCount = 0,
  });

  final String id;
  final String otherId;
  final String name;
  final String preview;
  final String image;
  final int unreadCount;
}

