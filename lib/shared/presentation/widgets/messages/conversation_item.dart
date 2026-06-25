class ConversationItem {
  const ConversationItem({
    required this.name,
    required this.preview,
    required this.image,
    this.unreadCount = 0,
  });

  final String name;
  final String preview;
  final String image;
  final int unreadCount;
}
