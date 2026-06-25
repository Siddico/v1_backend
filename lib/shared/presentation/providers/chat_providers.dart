import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../../core/networking/local_storage.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return ChatRemoteDataSource(localStorage);
});

final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, conversationId) {
  return ref.watch(chatRemoteDataSourceProvider).getMessages(conversationId);
});
