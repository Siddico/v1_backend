import '../entities/doctor_conversation_entity.dart';
import '../entities/doctor_story_entity.dart';

abstract class DoctorMessageRepository {
  Stream<List<DoctorStoryEntity>> getStories();
  Stream<List<DoctorConversationEntity>> getConversations();
}
