import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> removeNotification(String id);
  Future<void> clearAll();
}
