import '../../domain/entities/doctor_conversation_entity.dart';
import '../../domain/entities/doctor_story_entity.dart';
import '../../domain/repositories/doctor_message_repository.dart';
import '../datasources/doctor_message_remote_datasource.dart';

class DoctorMessageRepositoryImpl implements DoctorMessageRepository {
  DoctorMessageRepositoryImpl(this._remoteDataSource);
  final DoctorMessageRemoteDataSource _remoteDataSource;

  @override
  Stream<List<DoctorStoryEntity>> getStories() {
    // Stories feature is not used — always return empty list.
    return const Stream.empty();
  }

  @override
  Stream<List<DoctorConversationEntity>> getConversations() {
    return _remoteDataSource.getInboxData().map((data) {
      final raw = data?['conversations'];
      if (raw is! List) return [];

      return raw.whereType<Map>().map((item) {
        return DoctorConversationEntity(
          id: (item['id'] as String?) ?? '',
          otherId: (item['otherId'] as String?) ?? '',
          name: (item['name'] as String?) ?? 'Conversation',
          preview: (item['preview'] as String?) ?? '',
          image: (item['image'] as String?) ?? '',
          unreadCount: (item['unreadCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    });
  }
}
