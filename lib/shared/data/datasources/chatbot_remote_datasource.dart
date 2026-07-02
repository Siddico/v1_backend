import 'package:flutter/foundation.dart';
import 'package:grad_imp_1/core/networking/api_constants.dart';
import 'package:grad_imp_1/core/networking/api_response_parser.dart';
import 'package:grad_imp_1/core/networking/dio_factory.dart';

class ChatbotRemoteDataSource {
  /// Fetch all chatbot sessions for a patient
  static Future<List<Map<String, dynamic>>> getSessions() async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(ApiConstants.chatbotSessions);
      final list = ApiResponseParser.extractList(response.data is Map ? response.data['data'] : null);
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching chatbot sessions: $e');
      rethrow;
    }
  }

  /// Create a new chatbot session
  static Future<String> createSession(String title) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        ApiConstants.chatbotSessions,
        data: {'title': title},
      );
      final data = response.data is Map ? response.data['data'] : null;
      if (data is Map) {
        if (data.containsKey('session') && data['session'] is Map) {
          return data['session']['id']?.toString() ?? '';
        }
        return data['id']?.toString() ?? '';
      }
      return '';
    } catch (e) {
      debugPrint('Error creating chatbot session: $e');
      rethrow;
    }
  }

  /// Fetch messages for a specific session
  static Future<List<Map<String, dynamic>>> getMessages(
    String sessionId,
  ) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.get(
        '${ApiConstants.chatbotSessions}/$sessionId/messages',
      );
      final list = ApiResponseParser.extractList(response.data is Map ? response.data['data'] : null);
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching chatbot messages: $e');
      rethrow;
    }
  }

  /// Send a message to the chatbot
  static Future<Map<String, dynamic>?> sendMessage(String sessionId, String content) async {
    try {
      final dio = await DioFactory.getDio();
      final response = await dio.post(
        '${ApiConstants.chatbotSessions}/$sessionId/messages',
        data: {'content': content},
      );
      return response.data is Map ? response.data['data'] : null;
    } catch (e) {
      debugPrint('Error sending chatbot message: $e');
      rethrow;
    }
  }

  /// Delete a chatbot session
  static Future<void> deleteSession(String sessionId) async {
    try {
      final dio = await DioFactory.getDio();
      await dio.delete('${ApiConstants.chatbotSessions}/$sessionId');
    } catch (e) {
      debugPrint('Error deleting chatbot session: $e');
      rethrow;
    }
  }
}
