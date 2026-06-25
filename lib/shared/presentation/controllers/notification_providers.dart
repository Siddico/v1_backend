import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../features/auth/presentation/controllers/auth_providers.dart';
import '../../../core/networking/local_storage.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      final userId = ref.watch(authControllerProvider).valueOrNull?.id ??
          ref.watch(authStateProvider).valueOrNull?.id ??
          '';
      final storage = ref.watch(localStorageProvider);
      return BackendNotificationDataSource(userId: userId, storage: storage);
    });

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});

final notificationsProvider = StreamProvider<List<NotificationEntity>>((ref) {
  return ref.watch(notificationRepositoryProvider).getNotifications();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? [];
  return notifications.where((n) => n.isUnread).length;
});
