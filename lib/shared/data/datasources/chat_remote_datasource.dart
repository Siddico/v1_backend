import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
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

  // Upload an attachment (image or audio) to Cloudinary and return its download URL.
  Future<String> uploadAttachment({
    required File file,
    required String path,
  }) async {
    try {
      final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'grad_storage';
      
      final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].any((ext) => file.path.toLowerCase().endsWith(ext));
      final resourceType = isImage ? 'image' : 'raw';
      
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      request.fields['public_id'] = path;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload file to Cloudinary: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      return data['secure_url'];
    } catch (e) {
      debugPrint('Attachment upload failed: $e');
      return '';
    }
  }

  Future<String?> getExistingConversation(String p1, String p2) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get('${ApiConstants.baseUrl}/chat/conversation/$p1/$p2');
      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data']['id']?.toString();
      }
    } catch (e) {
      debugPrint('Error getting existing conversation: $e');
    }
    return null;
  }

  Future<String> getOrCreateConversation(String p1, String p2) async {
    final existing = await getExistingConversation(p1, p2);
    if (existing != null) return existing;

    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}/chat/conversation',
        data: {'participant_1_id': p1, 'participant_2_id': p2},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data']['id']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error creating conversation: $e');
    }
    return '${p1}_$p2'; // Fallback
  }

  Stream<List<Map<String, dynamic>>> getConversations(String userId) async* {
    while (true) {
      try {
        final dio = await DioFactory.getDio();
        final response = await dio.get(_chatEndpoint);
        
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final List<dynamic> data = response.data['data'] ?? [];
          // Grouping or returning as is depending on backend.
          // For now, we return the raw list assuming the backend provides conversations.
          yield data.map((d) => d as Map<String, dynamic>).toList();
        }
      } catch (e) {
        debugPrint('Error fetching conversations: $e');
      }
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String conversationId) async* {
    while (true) {
      try {
        final dio = await DioFactory.getDio();
        // The backend might expect a query parameter like ?receiver_id=... or just returns all chats
        // Since we don't have a specific endpoint for a conversation, we fetch all chats and filter if needed.
        // Or if the backend expects the conversationId (which is the other user's ID here):
        final response = await dio.get('$_chatEndpoint/$conversationId');
        
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          final List<dynamic> data = response.data['data'] ?? [];
          yield data.map((d) => d as Map<String, dynamic>).toList();
        }
      } catch (e) {
        debugPrint('Error fetching messages: $e');
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required String content,
    String messageType = 'text', // 'text', 'image', 'audio'
    String? attachmentUrl,
  }) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.post(
        _chatEndpoint,
        data: {
          'receiver_id': recipientId,
          'message': content,
          'message_type': messageType, // In case backend supports it
          'attachment_url': attachmentUrl,
        },
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }
}
