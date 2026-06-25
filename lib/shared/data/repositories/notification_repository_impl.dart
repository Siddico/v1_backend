import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remoteDataSource);
  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Stream<List<NotificationEntity>> getNotifications() {
    return _remoteDataSource.getNotifications().map(
      (list) => list.map((json) {
        // Handle ISO string (createdAt) from API
        DateTime createdAt = DateTime.now();
        if (json['createdAt'] != null) {
          createdAt = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
        } else if (json['created_at'] != null) {
          createdAt = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
        }

        return NotificationEntity(
          id: json['id']?.toString() ?? '',
          title: (json['title'] as String?) ?? 'Notification',
          // Fallback to 'message' if 'subtitle' is missing
          subtitle: (json['subtitle'] as String?) ?? (json['message'] as String?) ?? '',
          time: _formatRelative(createdAt),
          // Fallback to 'is_unread' if 'isUnread' is missing
          isUnread: (json['isUnread'] as bool?) ?? (json['is_unread'] as bool?) ?? true,
          createdAt: createdAt,
          senderImage: json['sender_image']?.toString() ?? json['senderImage']?.toString(),
          conversationId: json['conversation_id']?.toString() ?? json['conversationId']?.toString(),
          senderId: json['sender_id']?.toString() ?? json['senderId']?.toString() ?? json['patient_id']?.toString(),
        );
      }).toList(),
    );
  }

  @override
  Future<void> markAsRead(String id) {
    return _remoteDataSource.markAsRead(id);
  }

  @override
  Future<void> removeNotification(String id) {
    return _remoteDataSource.removeNotification(id);
  }

  @override
  Future<void> clearAll() {
    return _remoteDataSource.clearAll();
  }

  String _formatRelative(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
