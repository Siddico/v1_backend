import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';
import 'package:grad_imp_1/core/networking/local_storage.dart';
import 'package:grad_imp_1/core/enums/user_role.dart';

class ChatRemoteDataSource {
  final LocalStorage _storage;

  ChatRemoteDataSource(this._storage);

  String get _chatEndpoint {
    final role = _storage.getRole();
    return role == UserRole.doctor ? ApiConstants.doctorChat : ApiConstants.patientChat;
  }

  String get _chatReadEndpoint {
    final role = _storage.getRole();
    return role == UserRole.doctor ? ApiConstants.doctorChatRead : ApiConstants.patientChatRead;
  }

  Future<String> uploadAttachment({
    required File file,
    required String path,
  }) async {
    throw UnimplementedError('File upload not supported in backend mode');
  }

  Future<String?> getExistingConversation(String p1, String p2) async {
    return _generateConversationId(p1, p2);
  }

  Future<String> getOrCreateConversation(String p1, String p2) async {
    return _generateConversationId(p1, p2);
  }

  String _generateConversationId(String p1, String p2) {
    final id1 = int.tryParse(p1) ?? 0;
    final id2 = int.tryParse(p2) ?? 0;
    return '${min(id1, id2)}_${max(id1, id2)}';
  }

  Stream<List<Map<String, dynamic>>> getConversations(String userId) async* {
    final controller = StreamController<List<Map<String, dynamic>>>();

    Future<void> fetch() async {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(_chatEndpoint);

        if (response.statusCode == 200) {
          final List<dynamic> chats = ApiResponseParser.extractList(
            response.data is Map ? response.data['data'] : null,
          );
          final Map<String, Map<String, dynamic>> grouped = {};

          for (final chat in chats) {
            if (chat is! Map) continue;
            final senderId = chat['sender_id'].toString();
            final receiverId = chat['receiver_id'].toString();
            final otherUserId = senderId == userId ? receiverId : senderId;
            
            final sentAtStr = chat['sent_at'];
            if (sentAtStr == null) continue;
            
            final sentAt = DateTime.tryParse(sentAtStr.toString());
            if (sentAt == null) continue;

            if (!grouped.containsKey(otherUserId) || 
                DateTime.parse(grouped[otherUserId]!['last_message_at']).isBefore(sentAt)) {
              
              final otherUser = senderId == userId ? chat['receiver'] : chat['sender'];
              final otherUserName = (otherUser is Map) ? (otherUser['full_name'] ?? 'Unknown User') : 'Unknown User';

              grouped[otherUserId] = {
                'id': _generateConversationId(userId, otherUserId),
                'participant_1_id': userId,
                'participant_2_id': otherUserId,
                'last_message_at': sentAtStr,
                'last_message': chat['chat_message'],
                'other_user_name': otherUserName,
              };
            }
          }

          if (!controller.isClosed) {
            controller.add(grouped.values.toList()..sort((a, b) => 
                DateTime.parse(b['last_message_at']).compareTo(DateTime.parse(a['last_message_at']))));
          }
        }
      } catch (e) {
        debugPrint('Error fetching conversations: $e');
      }
    }

    fetch();
    final timer = Timer.periodic(const Duration(seconds: 30), (_) => fetch());

    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  Stream<List<Map<String, dynamic>>> getMessages(String conversationId) async* {
    final controller = StreamController<List<Map<String, dynamic>>>();
    
    // Extract participant IDs from conversationId
    final parts = conversationId.split('_');
    final p1 = parts.isNotEmpty ? parts[0] : '';
    final p2 = parts.length > 1 ? parts[1] : '';

    Future<void> fetch() async {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(_chatEndpoint);

        if (response.statusCode == 200) {
          final List<dynamic> chats = ApiResponseParser.extractList(
            response.data is Map ? response.data['data'] : null,
          );
          final List<Map<String, dynamic>> messages = [];

          for (final chat in chats) {
            if (chat is! Map) continue;
            final senderId = chat['sender_id'].toString();
            final receiverId = chat['receiver_id'].toString();

            if ((senderId == p1 && receiverId == p2) || (senderId == p2 && receiverId == p1)) {
              messages.add({
                'id': chat['id'].toString(),
                'sender_id': senderId,
                'receiver_id': receiverId,
                'content': chat['chat_message'],
                'created_at': chat['sent_at'],
                'is_read': chat['is_read'] ?? false,
                'message_type': chat['message_type'] ?? 'text',
              });
            }
          }

          if (!controller.isClosed) {
             controller.add(messages);
          }
        }
      } catch (e) {
        debugPrint('Error fetching messages: $e');
      }
    }

    fetch();
    final timer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());

    controller.onCancel = () {
      timer.cancel();
      controller.close();
    };

    yield* controller.stream;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required String content,
    String messageType = 'text',
    String? attachmentUrl,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post(
        _chatEndpoint,
        data: {
          'receiver_id': int.tryParse(recipientId),
          'message': content,
        },
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }
  
  Future<void> markAllAsRead() async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post(_chatReadEndpoint);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }
}
