import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/doctor_conversation_entity.dart';
import '../../domain/entities/doctor_story_entity.dart';
import '../../data/datasources/doctor_message_remote_datasource.dart';
import '../../../auth/presentation/controllers/auth_providers.dart';
import '../../data/repositories/doctor_message_repository_impl.dart';
import '../../domain/repositories/doctor_message_repository.dart';

final doctorMessageRemoteDataSourceProvider =
    Provider<DoctorMessageRemoteDataSource>((ref) {
      final userId = ref.watch(authStateProvider).valueOrNull?.id ?? '';
      return BackendDoctorMessageDataSource(userId: userId);
    });

final doctorMessageRepositoryProvider = Provider<DoctorMessageRepository>((
  ref,
) {
  return DoctorMessageRepositoryImpl(
    ref.watch(doctorMessageRemoteDataSourceProvider),
  );
});

final doctorStoriesProvider = StreamProvider<List<DoctorStoryEntity>>((ref) {
  return ref.watch(doctorMessageRepositoryProvider).getStories();
});

final doctorConversationsProvider =
    StreamProvider<List<DoctorConversationEntity>>((ref) {
      return ref.watch(doctorMessageRepositoryProvider).getConversations();
    });
